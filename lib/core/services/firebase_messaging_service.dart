import 'dart:convert';
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
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
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
        debugPrint('❌ Firebase Core is not initialized. Cannot initialize Firebase Messaging.');
        debugPrint('⚠️  Please ensure Firebase.initializeApp() is called in main.dart');
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
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      debugPrint('📱 Notification permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
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

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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
      return null;
    }
  }

  /// Force update FCM token on login (handles multi-device login)
  Future<void> updateTokenOnLogin(String authToken) async {
    try {
      // Delete old token
      await _firebaseMessaging.deleteToken();
      
      // Get new token
      String? newToken = await _firebaseMessaging.getToken();
      
      if (newToken != null) {
        debugPrint('🔄 New FCM token on login: $newToken');
        _fcmToken = newToken;
        await _saveTokenToPreferences(newToken);
        await _sendTokenToServer(newToken, authToken: authToken);
      }
    } catch (e) {
      debugPrint('❌ Error updating token on login: $e');
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
        debugPrint('❌ Failed to send FCM token to server: ${response.statusCode}');
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
}

