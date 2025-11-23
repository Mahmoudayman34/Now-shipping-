import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📱 Handling background message: ${message.messageId}');
  debugPrint('📱 Message data: ${message.data}');
  debugPrint('📱 Message notification: ${message.notification?.title}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ Firebase Messaging already initialized');
      return;
    }

    try {
      // Check if Firebase Core is initialized
      try {
        Firebase.app();
      } catch (e) {
        debugPrint(
            '❌ Firebase Core is not initialized. Cannot initialize Firebase Messaging.');
        debugPrint(
            '⚠️  Please ensure Firebase.initializeApp() is called in main.dart');
        return;
      }

      // Request notification permissions
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and save FCM token
      await getAndSaveToken();

      // Setup message handlers
      _setupForegroundMessageHandlers();
      _setupBackgroundMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _saveTokenToPreferences(newToken);
        _sendTokenToServer(newToken);
      });

      _isInitialized = true;
      debugPrint('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase Messaging: $e');
      rethrow;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      debugPrint(
          '📱 Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permissions');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️  User granted provisional notification permissions');
      } else {
        debugPrint('❌ User declined notification permissions');
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on notification data
  }

  /// Setup foreground message handlers
  void _setupForegroundMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📱 Received foreground message: ${message.messageId}');
      debugPrint('📱 Notification: ${message.notification?.toMap()}');
      debugPrint('📱 Data: ${message.data}');

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification opened app: ${message.messageId}');
      // TODO: Navigate to appropriate screen
    });
  }

  /// Setup background message handlers
  void _setupBackgroundMessageHandlers() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xfff29620),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: json.encode(message.data),
      );
    }
  }

  /// Get and save FCM token
  Future<String?> getAndSaveToken() async {
    try {
      // On iOS, ensure APNS token is available before getting FCM token
      if (Platform.isIOS) {
        // Check notification permission status first
        NotificationSettings settings =
            await _firebaseMessaging.getNotificationSettings();

        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          debugPrint(
              '⚠️  Notification permissions not granted. Cannot get FCM token on iOS.');
          debugPrint('📱 Permission status: ${settings.authorizationStatus}');
          debugPrint(
              '💡 User needs to grant notification permissions in Settings to receive push notifications.');
          return null;
        }

        // Wait for APNS token to be available (with longer timeout for first time)
        String? apnsToken = await _waitForAPNSToken(maxWaitSeconds: 15);

        if (apnsToken == null) {
          debugPrint(
              '⚠️  APNS Token not available after waiting. This may be due to:');
          debugPrint('   1. Notification permissions not granted');
          debugPrint(
              '   2. App running on simulator (APNS tokens only work on real devices)');
          debugPrint('   3. Network connectivity issues');
          debugPrint(
              '   4. APNS certificate/key not configured in Firebase Console');
          debugPrint(
              '   5. Bundle ID mismatch between app and Firebase project');
          debugPrint(
              '   6. APNS environment mismatch (development vs production)');
          return null;
        }

        debugPrint('✅ APNS Token available: ${apnsToken.substring(0, 20)}...');

        // Additional wait to ensure APNS token is fully processed by Firebase
        await Future.delayed(const Duration(milliseconds: 500));
      }

      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        debugPrint('📱 FCM Token: $token');
        _fcmToken = token;
        await _saveTokenToPreferences(token);
        await _sendTokenToServer(token);
        return token;
      } else {
        debugPrint('❌ Failed to get FCM token');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      debugPrint('🔍 Error type: ${e.runtimeType}');
      debugPrint('🔍 Error details: ${e.toString()}');

      // If it's the APNS token error, try waiting for it
      if ((e.toString().contains('apns-token-not-set') ||
              e.toString().contains('APNS') ||
              e.toString().contains('third-party-auth-error')) &&
          Platform.isIOS) {
        debugPrint(
            '🔄 APNS token issue detected, waiting for it to become available...');
        String? apnsToken = await _waitForAPNSToken(maxWaitSeconds: 10);

        if (apnsToken != null) {
          // Additional wait to ensure APNS token is fully processed
          await Future.delayed(const Duration(milliseconds: 500));

          try {
            String? token = await _firebaseMessaging.getToken();
            if (token != null) {
              debugPrint('📱 FCM Token (after APNS wait): $token');
              _fcmToken = token;
              await _saveTokenToPreferences(token);
              await _sendTokenToServer(token);
              return token;
            }
          } catch (retryError) {
            debugPrint(
                '❌ Error getting FCM token after APNS wait: $retryError');
            debugPrint(
                '🔍 This might indicate an APNS configuration issue in Firebase Console');
          }
        } else {
          debugPrint('❌ APNS token still not available after retry');
          debugPrint('💡 Please check:');
          debugPrint(
              '   1. Firebase Console has APNS Authentication Key configured');
          debugPrint('   2. Bundle ID matches: co.nowshipping.now');
          debugPrint(
              '   3. APNS environment matches (production for release builds)');
          debugPrint('   4. App is running on a real device (not simulator)');
        }
      }
      return null;
    }
  }

  /// Wait for APNS token to become available
  Future<String?> _waitForAPNSToken({int maxWaitSeconds = 10}) async {
    const checkInterval = Duration(milliseconds: 500);
    final maxAttempts = (maxWaitSeconds * 1000) ~/ 500;

    debugPrint('⏳ Waiting for APNS token (max ${maxWaitSeconds}s)...');

    for (int i = 0; i < maxAttempts; i++) {
      try {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          debugPrint('✅ APNS token received after ${(i + 1) * 500}ms');
          return apnsToken;
        }
      } catch (e) {
        // Log error but continue polling
        if (i == 0 || i % 10 == 0) {
          debugPrint(
              '⏳ Still waiting for APNS token... (attempt ${i + 1}/$maxAttempts)');
        }
      }

      if (i < maxAttempts - 1) {
        await Future.delayed(checkInterval);
      }
    }

    debugPrint('❌ APNS token not received after ${maxWaitSeconds}s');
    return null;
  }

  /// Force update FCM token on login (handles multi-device login)
  Future<void> updateTokenOnLogin(String authToken) async {
    try {
      // Delete old token
      await _firebaseMessaging.deleteToken();

      // On iOS, ensure APNS token is available before getting FCM token
      if (Platform.isIOS) {
        // Check notification permission status first
        NotificationSettings settings =
            await _firebaseMessaging.getNotificationSettings();

        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          debugPrint(
              '⚠️  Notification permissions not granted. Cannot update FCM token on iOS.');
          return;
        }

        // Wait for APNS token (longer timeout for login scenario)
        String? apnsToken = await _waitForAPNSToken(maxWaitSeconds: 10);
        if (apnsToken == null) {
          debugPrint('⚠️  APNS Token not available. Cannot update FCM token.');
          debugPrint(
              '💡 This may indicate an APNS configuration issue in Firebase Console');
          return;
        }

        // Additional wait to ensure APNS token is fully processed
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Get new token
      String? newToken = await _firebaseMessaging.getToken();

      if (newToken != null) {
        debugPrint('🔄 New FCM token on login: $newToken');
        _fcmToken = newToken;
        await _saveTokenToPreferences(newToken);
        await _sendTokenToServer(newToken, authToken: authToken);
      } else {
        debugPrint('⚠️  Failed to get new FCM token on login');
      }
    } catch (e) {
      debugPrint('❌ Error updating token on login: $e');
      debugPrint('🔍 Error type: ${e.runtimeType}');

      // Retry if APNS token error
      if ((e.toString().contains('apns-token-not-set') ||
              e.toString().contains('APNS') ||
              e.toString().contains('third-party-auth-error')) &&
          Platform.isIOS) {
        debugPrint('🔄 APNS token issue detected, waiting for it...');
        String? apnsToken = await _waitForAPNSToken(maxWaitSeconds: 10);

        if (apnsToken != null) {
          // Additional wait to ensure APNS token is fully processed
          await Future.delayed(const Duration(milliseconds: 500));

          try {
            String? newToken = await _firebaseMessaging.getToken();
            if (newToken != null) {
              debugPrint(
                  '🔄 New FCM token on login (after APNS wait): $newToken');
              _fcmToken = newToken;
              await _saveTokenToPreferences(newToken);
              await _sendTokenToServer(newToken, authToken: authToken);
            }
          } catch (retryError) {
            debugPrint('❌ Error updating token after APNS wait: $retryError');
            debugPrint(
                '🔍 This might indicate an APNS configuration issue in Firebase Console');
          }
        }
      }
    }
  }

  /// Save token to SharedPreferences
  Future<void> _saveTokenToPreferences(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      debugPrint('💾 FCM token saved to preferences');
    } catch (e) {
      debugPrint('❌ Error saving token to preferences: $e');
    }
  }

  /// Send token to server
  Future<void> _sendTokenToServer(String token, {String? authToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAuthToken = authToken ?? prefs.getString('auth_token');

      if (savedAuthToken == null) {
        debugPrint('⚠️  No auth token available, skipping token sync');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/business/update-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $savedAuthToken',
        },
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token sent to server successfully');
      } else {
        debugPrint(
            '❌ Failed to send FCM token to server: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error sending token to server: $e');
    }
  }

  /// Get current FCM token
  String? get currentToken => _fcmToken;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Retry getting FCM token (useful when permissions are granted later)
  Future<String?> retryGetToken() async {
    debugPrint('🔄 Retrying FCM token retrieval...');
    return await getAndSaveToken();
  }

  /// Check if notification permissions are granted
  Future<bool> hasNotificationPermissions() async {
    if (!Platform.isIOS) {
      return true; // Android doesn't require this check
    }

    try {
      NotificationSettings settings =
          await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('❌ Error checking notification permissions: $e');
      return false;
    }
  }
}
