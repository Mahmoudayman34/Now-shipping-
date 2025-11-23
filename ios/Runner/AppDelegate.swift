import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var apnsTokenData: Data?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase - This is critical for APNS token handling
    // Note: Firebase is also initialized in Dart, but we need it here for native token handling
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
      print("✅ Firebase initialized in AppDelegate")
    }
    
    // Initialize Google Maps
    GMSServices.provideAPIKey("AIzaSyCGxSkL--7poxqkFZJg9c3v_0Y3czMIiOI")
    
    // Set up notification center delegate
    // Note: Permission requests are handled by Flutter/Firebase Messaging
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    // Register for remote notifications (this is needed to receive APNS token)
    // The actual permission request is handled by Flutter/Firebase Messaging
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNS token registration
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Store the APNS token data
    apnsTokenData = deviceToken
    
    // Convert device token to string for logging
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("✅ APNS Device Token received: \(token.prefix(20))...")
    
    // Set APNS token for Firebase Messaging
    // This must be set before getting FCM token
    Messaging.messaging().apnsToken = deviceToken
    
    // Verify Firebase is initialized
    if FirebaseApp.app() != nil {
      print("✅ APNS token set for Firebase Messaging (Firebase initialized)")
    } else {
      print("⚠️ APNS token set but Firebase not yet initialized")
    }
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Handle APNS token registration failure
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // Handle notification tap when app is in background/terminated
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([[.banner, .badge, .sound]])
  }
}
