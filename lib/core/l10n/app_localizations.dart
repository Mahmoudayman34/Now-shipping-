import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return localizations ?? AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Logistics App',
      'loginTitle': 'Login',
      'registerTitle': 'Register',
      'emailLabel': 'Email',
      'passwordLabel': 'Password',
      'nameLabel': 'Full Name',
      'phoneLabel': 'Phone Number',
      'loginButton': 'Login',
      'registerButton': 'Register',
      'createAccountPrompt': 'Create an account',
      'alreadyHaveAccountPrompt': 'Already have an account? Login',
      'businessOwnerLabel': 'Business Owner',
      'deliveryPersonLabel': 'Delivery Person',
      'accountTypeLabel': 'Account Type:',
      'businessDashboardTitle': 'Business Dashboard',
      'deliveryDashboardTitle': 'Delivery Dashboard',
      'activeShipmentsLabel': 'Active Shipments',
      'deliveredLabel': 'Delivered',
      'recentShipmentsLabel': 'Recent Shipments',
      'assignedShipmentsLabel': 'Assigned Shipments',
      'createShipmentButton': 'Create Shipment',
      'updateButton': 'Update',
      'scanShipmentButton': 'Scan Shipment',
      'noShipmentsMessage': 'No shipments yet. Create your first shipment!',
      'noAssignedShipmentsMessage': 'No shipments assigned to you yet.',
      'createShipmentTitle': 'Create Shipment',
      'packageDescriptionLabel': 'Package Description',
      'receiverInfoLabel': 'Receiver Information',
      'receiverNameLabel': 'Receiver Name',
      'receiverPhoneLabel': 'Receiver Phone',
      'deliveryAddressLabel': 'Delivery Address',
      'shipmentCreatedSuccess': 'Shipment created successfully!',
      'shipmentDetailsTitle': 'Shipment Details',
      'statusLabel': 'Status',
      'trackingNumberLabel': 'Tracking #',
      'createdLabel': 'Created',
      'descriptionLabel': 'Description',
      'recipientLabel': 'Recipient',
      'addressLabel': 'Address',
      'updateStatusLabel': 'Update Status:',
      'inTransitStatus': 'In Transit',
      'deliveredStatus': 'Delivered',
      'captureProofButton': 'Capture Proof of Delivery',
      'assignShipmentButton': 'Assign to Delivery Person',
      'deleteShipmentButton': 'Delete Shipment',
      'deleteConfirmation': 'Are you sure you want to delete this shipment?',
      'cancelButton': 'Cancel',
      'deleteButton': 'Delete',
      'assignButton': 'Assign',
      'assignShipmentTitle': 'Assign Shipment',
      'shipmentAssignedSuccess': 'Shipment assigned successfully',
      'shipmentDeletedSuccess': 'Shipment deleted successfully',
      'statusUpdatedSuccess': 'Status updated successfully',
      'languageTitle': 'Language',
      'currentLanguage': 'Current Language',
      'activeLanguage': 'Active Language',
      'doneButton': 'Done',
      'changeLanguage': 'Change Language',
      'changeLanguageConfirmation': 'Are you sure you want to change the language to {language}?',
      'confirmButton': 'Confirm',
      'languageChangedSuccess': 'Language changed to {language}',
      'english': 'English',
      'arabic': 'العربية',
      'applicationSettings': 'Application Settings',
      'support': 'Support',
      'contactUs': 'Contact Us',
      'about': 'About',
      'personalInfo': 'Personal Information',
      'security': 'Security',
      'notifications': 'Notifications',
      'helpCenter': 'Help Center',
      'deleteAccount': 'Delete Account',
      'logout': 'Logout',
      'profile': 'Profile',
      'settings': 'Settings',
      'termsOfService': 'Terms of Service',
      'privacyPolicy': 'Privacy Policy',
      'lastUpdated': 'Last updated: June 15, 2023',
      'enterPhoneNumber': 'Enter phone number',
      'thisFieldIsRequired': 'This field is required',
      'whatsAppNote': "We'll contact you via WhatsApp for pickup coordination",
      'locationNote': 'Please provide the exact pickup address',
      'pickupDate': 'Pickup Date',
      'pickupAddress': 'Pickup Address',
      'contactNumber': 'Contact Number',
      'numberOfOrders': 'Number of Orders',
      'specialRequirements': 'Special Requirements',
      'fragileItem': 'Fragile Item',
      'largeItem': 'Large Item',
      'additionalNotes': 'Additional Notes',
      'schedulePickup': 'Schedule Pickup',
      'updatePickup': 'Update Pickup',
      'pickupScheduled': 'Pickup scheduled successfully!',
      'pickupUpdated': 'Pickup updated successfully!',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'selectDate': 'Select Date',
      'welcome': 'Welcome',
      'dashboard': 'Dashboard',
      'home': 'Home',
      'orders': 'Orders',
      'pickups': 'Pickups',
      'wallet': 'Wallet',
      'more': 'More',
      
      // Authentication screens
      'createAccount': 'Create Account',
      'fillInDetails': 'Fill in your details to get started',
      'welcomeBack': 'Welcome Back',
      'loginToAccount': 'Login to your account to continue',
      'dontHaveAccount': 'Don\'t have an account?',
      'signUp': 'Sign Up',
      'agreeToTerms': 'Please agree to terms and conditions',
      'verifyPhoneNumber': 'Please verify your phone number',
      'resendCode': 'Resend Code',
      'verificationCode': 'Verification Code',
      'enterVerificationCode': 'Enter the verification code sent to your phone',
      'wantStorage': 'Do you need storage services?',
      'termsAndConditions': 'I agree to the Terms and Conditions',
      
      // Dashboard and Home
      'hello': 'Hello',
      'moreFunctionalities': 'More functionalities?',
      'visitDashboard': 'Visit Dashboard',
      'checkingProfileStatus': 'Checking profile status...',
      'notLoggedIn': 'Not logged in',
      'error': 'Error',
      'retry': 'Retry',
      'welcomeUser': 'Welcome',
      'completeProfile': 'Please complete your profile to access all features',
      'todaysOverview': 'Today\'s Overview',
      'inHubPackages': 'In Hub Packages',
      'headingToCustomer': 'Heading to Customer',
      'awaitingAction': 'Awaiting Action',
      'successfulOrders': 'Successful Orders',
      'unsuccessfulOrders': 'Unsuccessful Orders',
      'headingToYou': 'Heading to You',
      'newOrders': 'New Orders',
      'successRate': 'Success Rate',
      'unsuccessRate': 'Unsuccess Rate',
      
      // Order preparation workflow
      'preparingYourOrders': 'Preparing Your Orders',
      'followProfessionalSteps': 'Follow these professional steps for successful shipping',
      'readyToPrepare': 'Ready to Prepare',
      'verifyOrderInformation': 'Verify Order Information',
      'doubleCheckCustomerDetails': 'Double-check all customer details, addresses, and product specifications for accuracy',
      'selectProperPackaging': 'Select Proper Packaging',
      'chooseAppropriatePackaging': 'Choose appropriate packaging materials based on product fragility, weight, and dimensions',
      'securePackageContents': 'Secure Package Contents',
      'useProperCushioning': 'Use proper cushioning materials and ensure products are securely positioned to prevent damage',
      'applyShippingLabel': 'Apply Shipping Label',
      'printAndAffixLabels': 'Print and affix shipping labels clearly on the package, ensuring barcodes are scannable',
      'arrangeForPickup': 'Arrange for pickup through the app or prepare to drop off at an authorized shipping location',
      
      // Financial/Cash collection
      'expectedCash': 'Expected Cash',
      'collectedCash': 'Collected Cash',
      'egp': 'EGP',
      'youHaveCreatedOrders': 'You have created {count} new Orders',
      'prepareOrders': 'Prepare orders',
      
      // Orders
      'createNewOrder': 'Create New Order',
      'areYouSureExit': 'Are you sure you want to exit?',
      'changesWontBeSaved': 'Changes to the order won\'t be saved if you exit',
      'orderDataWontBeSaved': 'Order data and updates won\'t be saved if you decided to exit',
      'errorLoadingOrders': 'Error loading orders',
      'checkConnectionRetry': 'Please check your connection and try again',
      'noOrdersYet': 'You didn\'t create orders yet!',
      'noOrdersWithStatus': 'No orders with status',
      'customerDetails': 'Customer Details',
      'deliveryType': 'Delivery Type',
      'deliver': 'Deliver',
      'cashCollection': 'Cash Collection',
      'productDescription': 'Product Description',
      'orderValue': 'Order Value',
      'shippingFees': 'Shipping Fees',
      'totalAmount': 'Total Amount',
      
      // Pickups
      'createPickup': 'Create PickUP',
      'editPickup': 'Edit PickUP',
      'clear': 'Clear',
      'pickupDetails': 'Pickup Details',
      'placeOfPickup': 'Place of Pickup',
      'savedPickupAddress': 'Your saved pickup address will be used for this order.',
      'whatsappAvailable': 'Please ensure this number is available on WhatsApp for delivery updates.',
      'pickupNotes': 'Pickup Notes',
      'noUpcomingPickups': 'No upcoming pickups',
      'noPickupHistory': 'No pickup history',
      'createFirstPickup': 'Create your first pickup to get started',
      'completedPickupsHere': 'Completed pickups will appear here',
      'cancelPickup': 'Cancel Pickup',
      'cancelPickupConfirmation': 'Are you sure you want to cancel pickup #{number}? This action cannot be undone.',
      'no': 'No',
      'yesCancelPickup': 'Yes, Cancel',
      'pickupCancellationSoon': 'Pickup cancellation feature coming soon',
      'upcoming': 'Upcoming',
      'history': 'History',
      
      // More Screen
      'accountSettings': 'Account Settings',
      'accountActions': 'Account Actions',
      
      // Common UI Elements
      'close': 'Close',
      'undo': 'Undo',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'loading': 'Loading',
      'pleaseWait': 'Please wait...',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Information',
      'tryAgain': 'Try Again',
      'refresh': 'Refresh',
      'refreshFailed': 'Refresh failed',
      
      // Onboarding
      'effortlessShipping': 'Effortless Shipping,\nAnytime',
      'effortlessShippingDesc': 'Create and manage shipments with just a few taps. Simple, fast, and reliable.',
      'trackDeliveries': 'Track Deliveries in Real Time',
      'trackDeliveriesDesc': 'Stay updated with live tracking, order statuses, and delivery progress.',
      'securePayments': 'Secure & Seamless Payments',
      'securePaymentsDesc': 'Manage cash transactions with confidence. Collect, track, and confirm every payment.',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get Started',
      'youHaveInOurHubs': 'You have in our hubs',
      'packages': 'Packages',
      'create': 'Create',
      'singleOrder': 'Single Order',
      'createOrdersOneByOne': 'Create orders one by one.',
      'schedulePickupTitle': 'Schedule Pickup',
      'requestPickupDescription': 'Request a pickup to pick your orders.',
      'personalInformation': 'Personal Information',
      'profilePicture': 'Profile Picture',
      'basicInformation': 'Basic Information',
      'fullName': 'Full Name',
      'email': 'Email',
      'phone': 'Phone',
      'businessInformation': 'Business Information',
      'businessName': 'Business Name',
      'role': 'Role',
      'storageNeeded': 'Storage Needed',
      'accountStatus': 'Account Status',
      'registeredDate': 'Registered Date',
      'editInformation': 'Edit Information',
      'editPersonalInformation': 'Edit Personal Information',
      'active': 'Active',
      'pendingVerification': 'Pending Verification',
      'inactive': 'Inactive',
      'noUserDataAvailable': 'No user data available',
      'tapToChangeProfilePicture': 'Tap to change profile picture',
      'pleaseEnterYourName': 'Please enter your name',
      'pleaseEnterYourEmail': 'Please enter your email',
      'pleaseEnterValidEmail': 'Please enter a valid email',
      'pleaseEnterYourPhoneNumber': 'Please enter your phone number',
      'pleaseEnterYourBusinessName': 'Please enter your business name',
      'saveChanges': 'Save Changes',
      'deleteYourAccount': 'Delete Your Account?',
      'deleteAccountWarning': 'This action cannot be undone. Once you delete your account:',
      'deletePersonalInfo': 'All your personal information will be permanently deleted',
      'loseDataAccess': 'You will lose access to all your data and activity history',
      'cancelSubscriptions': 'Any active subscriptions will be canceled',
      'needNewAccount': 'You will need to create a new account if you want to use the app again',
      'confirmDeletion': 'Confirm Deletion',
      'securityVerification': 'Security Verification',
      'securityPasswordPrompt': 'For security reasons, please enter your password to confirm account deletion.',
      'password': 'Password',
      'pleaseEnterPassword': 'Please enter your password',
      'continueAction': 'Continue',
      'areYouSureLogout': 'Are you sure you want to logout?',
      'allOrders': 'All',
      'newStatus': 'New',
      'pickedUpStatus': 'Picked Up',
      'inStockStatus': 'In Stock',
      'inProgressStatus': 'In Progress',
      'headingToCustomerStatus': 'Heading To Customer',
      'headingToYouStatus': 'Heading To You',
      'completedStatus': 'Completed',
      'canceledStatus': 'Canceled',
      'rejectedStatus': 'Rejected',
      'returnedStatus': 'Returned',
      'terminatedStatus': 'Terminated',
      'filterByDeliveryType': 'Filter by Delivery Type',
      'deliverType': 'Deliver',
      'exchangeType': 'Exchange',
      'returnType': 'Return',
      'cashCollectionType': 'Cash Collection',
      'applyFilter': 'Apply Filter',
      'orderNumber': 'Order #',
      'cashOnDeliveryText': 'Cash on delivery',
      'pullDownToRefresh': 'Pull down to refresh',
      'releaseToRefresh': 'Release to refresh',
      'refreshingText': 'Refreshing...',
      'refreshCompleted': 'Refresh completed',
      'refreshFailedText': 'Refresh failed',
      'tracking': 'Tracking',
      'orderDetails': 'Order Details',
      'scanSmartSticker': 'Scan Smart Sticker',
      'customer': 'Customer',
      'shippingInformation': 'Shipping Information',
      'deliverItemsToCustomer': 'Deliver items to customer',
      'exchangeItemsWithCustomer': 'Exchange items with customer',
      'returnItemsFromCustomer': 'Return items from customer',
      'deliveryDetails': 'Delivery Details',
      'packageType': 'Package Type',
      'parcel': 'Parcel',
      'numberOfItems': 'Number of Items',
      'packageDescription': 'Package Description',
      'allowCustomerInspect': 'Allow customer to inspect package',
      'expressShipping': 'Express Shipping',
      'additionalDetails': 'Additional Details',
      'specialInstructions': 'Special Instructions',
      'referenceNumber': 'Reference Number',
      'dateCreated': 'Date Created',
      'status': 'Status',
      'orderCreatedSuccess': 'You successfully created the order.',
      'pickedUpTitle': 'Picked up',
      'pickedUpDescription': 'We got your order! It should be at our warehouses by the end of day.',
      'inStockTitle': 'In Stock',
      'inStockDescription': 'Your order is now in our warehouse.',
      'headingToCustomerTitle': 'Heading to customer',
      'headingToCustomerDescription': 'We shipped the order for delivery to your customer.',
      'successfulTitle': 'Successful',
      'successfulDescription': 'Order delivered successfully to your customer 🎉',
      'orderActions': 'Order Actions',
      'viewDetails': 'View Details',
      'printAirwaybill': 'Print Airwaybill',
      'editOrder': 'Edit order',
      'trackOrder': 'Track Order',
      'deleteOrder': 'Delete order',

      // Create Order Screen
      'addCustomerDetails': 'Add Customer Details',
      'selectDeliveryTypeDescription': 'Select delivery type and provide shipping details',
      'orderType': 'Order Type',
      'cashCollect': 'Cash Collect',
      'describeProductsPlaceholder': 'Describe the products being delivered',
      'additionalOptions': 'Additional Options',
      'specialRequirementsDescription': 'Specify any special requirements for this order',
      'allowOpeningPackage': 'Allow opening package',
      'specialInstructionsPlaceholder': 'Add any special delivery instructions or notes',
      'referralNumberOptional': 'Referral Number (Optional)',
      'referralCodePlaceholder': 'Enter referral code if available',
      'deliveryFeeSummary': 'Delivery Fee Summary',
      'totalDeliveryFee': 'Total Delivery Fee',
      'confirmOrder': 'Confirm Order',
      
      // Customer Details Screen
      'phoneNumber': 'Phone Number',
      'addSecondaryNumber': 'Add secondary number',
      'namePlaceholder': 'name',
      'address': 'Address',
      'cityArea': 'City - Area',
      'addressDetails': 'Address details',
      'apartment': '...Apartm',
      'floor': 'Floor',
      'building': 'Building',
      'landmark': 'Landmark',
      'thisIsWorkingAddress': 'This is working address',

      // City names
      'cairo': 'Cairo',
      'alexandria': 'Alexandria',
      'giza': 'Giza',
      'portSaid': 'Port Said',
      'suez': 'Suez',
      'luxor': 'Luxor',
      'aswan': 'Aswan',
      'hurghada': 'Hurghada',
      'sharmElSheikh': 'Sharm El Sheikh',

      // Cash on Delivery
      'cashOnDelivery': 'Cash on Delivery',
      'cashOnDeliveryAmount': 'Cash on Delivery Amount',
      'enterAmount': 'Enter amount',

      // Dialog buttons
      'exit': 'Exit',

      // Print dialog
      'selectPaperSize': 'Select paper size for printing',
      'printA4': 'Print A4',
      'printA5': 'Print A5',
      'ok': 'OK',

      // Edit order dialog
      'changesNotSaved': 'Changes to the order won\'t be saved if you exit',

      // Login form
      'emailOrPhoneNumber': 'Email or Phone Number',
      'emailOrPhonePlaceholder': 'johndoe@email.com or 1234567890',
      'emailOrPhoneRequired': 'Email or phone number is required',
      'enterValidEmailOrPhone': 'Enter a valid email or phone number',
      'passwordPlaceholder': '********',
      'minCharacters': 'Min 6 characters',
      'rememberMe': 'Remember me',
      'forgotPassword': 'Forgot Password?',
      'forgotPasswordDescription': 'Enter your email address and we\'ll send you a link to reset your password',
      'emailAddress': 'Email Address',
      'sendResetLink': 'Send Reset Link',
      'emailSent': 'Email Sent!',
      'emailSentDescription': 'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.',
      'resendEmail': 'Resend Email',
      'backToLogin': 'Back to Login',
      'checkEmailForReset': 'Check your email for reset instructions',
      'enterOtpCode': 'Enter OTP Code',
      'otpCode': 'OTP Code',
      'otpCodePlaceholder': 'Enter 6-digit code',
      'verifyOtp': 'Verify OTP',
      'otpSentToEmail': 'We\'ve sent a 6-digit code to your email address',
      'resendOtp': 'Resend OTP',
      'otpVerified': 'OTP Verified!',
      'otpVerifiedDescription': 'Your OTP has been verified successfully. You can now reset your password.',
      'resetPassword': 'Reset Password',
      'resetPasswordDescription': 'Enter your new password below to complete the reset process',
      'newPassword': 'New Password',
      'newPasswordPlaceholder': 'Enter your new password',
      'confirmNewPassword': 'Confirm New Password',
      'confirmNewPasswordPlaceholder': 'Confirm your new password',
      'continueToResetPassword': 'Continue to Reset Password',
      'goToLogin': 'Go to Login',
      'passwordResetSuccessfully': 'Password Reset Successfully!',
      'passwordResetSuccessDescription': 'Your password has been successfully reset. You can now log in with your new password.',
      'otpVerifiedSuccessfully': 'OTP verified successfully',
      'otpSentSuccessfully': 'OTP sent to your email successfully',
      'otpResentSuccessfully': 'OTP resent successfully',
      'invalidOtpCode': 'Invalid OTP code. Please enter a 6-digit number.',
      'passwordResetSuccessfullyToast': 'Password reset successfully',

      // Signup form
      'enterFullName': 'Enter your full name',
      'enterEmailAddress': 'Enter your email address',
      'createPassword': 'Create a password',
      'iWantStorage': 'I want storage',
      'iAgreeToTerms': 'I agree to the terms and conditions',
      'login': 'Login',
      'verify': 'Verify',
      'verified': 'Verified',
      'alreadyHaveAccount': 'Already have an account',

      // Create Pickup Screen
      'enterNumberOfOrders': 'Enter number of orders',
      'pickupAddressHelper': 'Your registered pickup address from account creation is used for all pickups',
      'contactInfo': 'Contact Info',
      'whatsappHelper': 'Please ensure this number is available on WhatsApp for delivery updates',
      'pickUpDate': 'Pick Up Date',
      'enterPickupNotes': 'Enter any special instructions or notes for the pickup',
      'requiresLargerVehicle': 'Requires larger vehicle',
      'specialHandlingRequired': 'Special handling required',

      // Create Bottom Sheet
      'requestPickupToPickOrders': 'Request a pickup to pick your orders',

      // Language Settings
      'languageSettings': 'Language Settings',
      'choosePreferredLanguage': 'Choose your preferred language',
      'selectLanguage': 'Select Language',
      'tapLanguageOptionToChange': 'Tap on a language option to change',
      'changingLanguageWillRestart': 'Changing the language will restart the app to apply the new settings',
      'switchToEnglish': 'Switch to English?',
      'switchToArabic': 'Switch to Arabic?',
      'appWillRestartToApplyLanguage': 'The app will restart to apply the new language.',

      // Contact Us Screen
      'ourOffice': 'Our Office',
      'businessHours': 'Business Hours',
      'phoneAndEmail': 'Phone & Email',
      'sendUsMessage': 'Send us a message',
      'yourName': 'Your Name',
      'yourEmail': 'Your Email',
      'issueType': 'Issue Type',
      'generalInquiry': 'General Inquiry',
      'yourMessage': 'Your Message',
      'sendMessage': 'Send Message',

      // About Screen
      'aboutNowShipping': 'About Now Shipping',
      'aboutDescription': 'Now Shipping is a modern shipping management platform designed for businesses of all sizes. Our platform helps you manage your shipping operations efficiently, from creating orders to tracking deliveries',
      'keyFeatures': 'Key Features',
      'easyOrderCreation': 'Easy order creation and management',
      'realTimeTracking': 'Real-time shipment tracking',
      'integratedPayments': 'Integrated payment solutions',
      'addressManagement': 'Customer address management',
      'analyticsReporting': 'Analytics and reporting',
      'multiPlatformSupport': 'Multi-platform support',
      'companyInformation': 'Company Information',
      'founded': 'Founded',
      'headquarters': 'Headquarters',
      'website': 'Website',
      'legal': 'Legal',
      'allRightsReserved': 'Now Shipping. All rights reserved 2025 ©',
    },
    'ar': {
      'appTitle': 'تطبيق الخدمات اللوجستية',
      'loginTitle': 'تسجيل الدخول',
      'registerTitle': 'التسجيل',
      'emailLabel': 'البريد الإلكتروني',
      'passwordLabel': 'كلمة المرور',
      'nameLabel': 'الاسم الكامل',
      'phoneLabel': 'رقم الهاتف',
      'loginButton': 'تسجيل الدخول',
      'registerButton': 'التسجيل',
      'createAccountPrompt': 'إنشاء حساب',
      'alreadyHaveAccountPrompt': 'هل لديك حساب بالفعل؟ تسجيل الدخول',
      'businessOwnerLabel': 'صاحب عمل',
      'deliveryPersonLabel': 'موصل',
      'accountTypeLabel': 'نوع الحساب:',
      'businessDashboardTitle': 'لوحة تحكم الأعمال',
      'deliveryDashboardTitle': 'لوحة تحكم التوصيل',
      'activeShipmentsLabel': 'الشحنات النشطة',
      'deliveredLabel': 'تم التوصيل',
      'recentShipmentsLabel': 'الشحنات الأخيرة',
      'assignedShipmentsLabel': 'الشحنات المخصصة',
      'createShipmentButton': 'إنشاء شحنة',
      'updateButton': 'تحديث',
      'scanShipmentButton': 'مسح الشحنة',
      'noShipmentsMessage': 'لا توجد شحنات بعد. أنشئ أول شحنة لك!',
      'noAssignedShipmentsMessage': 'لا توجد شحنات مخصصة لك حتى الآن.',
      'createShipmentTitle': 'إنشاء شحنة',
      'packageDescriptionLabel': 'وصف الطرد',
      'receiverInfoLabel': 'معلومات المستلم',
      'receiverNameLabel': 'اسم المستلم',
      'receiverPhoneLabel': 'هاتف المستلم',
      'deliveryAddressLabel': 'عنوان التسليم',
      'shipmentCreatedSuccess': 'تم إنشاء الشحنة بنجاح!',
      'shipmentDetailsTitle': 'تفاصيل الشحنة',
      'statusLabel': 'الحالة',
      'trackingNumberLabel': 'رقم التتبع',
      'createdLabel': 'تم الإنشاء',
      'descriptionLabel': 'الوصف',
      'recipientLabel': 'المستلم',
      'addressLabel': 'العنوان',
      'updateStatusLabel': 'تحديث الحالة:',
      'inTransitStatus': 'قيد النقل',
      'deliveredStatus': 'تم التسليم',
      'captureProofButton': 'التقاط إثبات التسليم',
      'assignShipmentButton': 'تعيين للموصل',
      'deleteShipmentButton': 'حذف الشحنة',
      'deleteConfirmation': 'هل أنت متأكد من أنك تريد حذف هذه الشحنة؟',
      'cancelButton': 'إلغاء',
      'deleteButton': 'حذف',
      'assignButton': 'تعيين',
      'assignShipmentTitle': 'تعيين الشحنة',
      'shipmentAssignedSuccess': 'تم تعيين الشحنة بنجاح',
      'shipmentDeletedSuccess': 'تم حذف الشحنة بنجاح',
      'statusUpdatedSuccess': 'تم تحديث الحالة بنجاح',
      'languageTitle': 'اللغة',
      'currentLanguage': 'اللغة الحالية',
      'activeLanguage': 'اللغة النشطة',
      'doneButton': 'تم',
      'changeLanguage': 'تغيير اللغة',
      'changeLanguageConfirmation': 'هل أنت متأكد من أنك تريد تغيير اللغة إلى {language}؟',
      'confirmButton': 'تأكيد',
      'languageChangedSuccess': 'تم تغيير اللغة إلى {language}',
      'english': 'English',
      'arabic': 'العربية',
      'applicationSettings': 'إعدادات التطبيق',
      'support': 'الدعم',
      'contactUs': 'اتصل بنا',
      'about': 'حول',
      'personalInfo': 'المعلومات الشخصية',
      'security': 'الأمان',
      'notifications': 'الإشعارات',
      'helpCenter': 'مركز المساعدة',
      'deleteAccount': 'حذف الحساب',
      'logout': 'تسجيل الخروج',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'termsOfService': 'شروط الخدمة',
      'privacyPolicy': 'سياسة الخصوصية',
      'lastUpdated': 'آخر تحديث: 15 يونيو 2023',
      'enterPhoneNumber': 'أدخل رقم الهاتف',
      'thisFieldIsRequired': 'هذا الحقل مطلوب',
      'whatsAppNote': 'سنتواصل معك عبر الواتساب لتنسيق الاستلام',
      'locationNote': 'يرجى تقديم عنوان الاستلام الدقيق',
      'pickupDate': 'تاريخ الاستلام',
      'pickupAddress': 'عنوان الاستلام',
      'contactNumber': 'رقم الاتصال',
      'numberOfOrders': 'عدد الطلبات',
      'specialRequirements': 'المتطلبات الخاصة',
      'fragileItem': 'عنصر هش',
      'largeItem': 'عنصر كبير',
      'additionalNotes': 'ملاحظات إضافية',
      'schedulePickup': 'جدولة الاستلام',
      'updatePickup': 'تحديث الاستلام',
      'pickupScheduled': 'تم جدولة الاستلام بنجاح!',
      'pickupUpdated': 'تم تحديث الاستلام بنجاح!',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'selectDate': 'اختر التاريخ',
      'welcome': 'مرحباً',
      'dashboard': 'لوحة التحكم',
      'home': 'الرئيسية',
      'orders': 'الطلبات',
      'pickups': 'الاستلام',
      'wallet': 'المحفظة',
      'more': 'المزيد',
      
      // Authentication screens
      'createAccount': 'إنشاء حساب',
      'fillInDetails': 'املأ بياناتك للبدء',
      'welcomeBack': 'مرحباً بعودتك',
      'loginToAccount': 'سجل دخولك إلى حسابك للمتابعة',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'signUp': 'التسجيل',
      'agreeToTerms': 'يرجى الموافقة على الشروط والأحكام',
      'verifyPhoneNumber': 'يرجى التحقق من رقم هاتفك',
      'resendCode': 'إعادة إرسال الرمز',
      'verificationCode': 'رمز التحقق',
      'enterVerificationCode': 'أدخل رمز التحقق المرسل إلى هاتفك',
      'wantStorage': 'هل تحتاج خدمات التخزين؟',
      'termsAndConditions': 'أوافق على الشروط والأحكام',
      
      // Dashboard and Home
      'hello': 'مرحباً',
      'moreFunctionalities': 'المزيد من الوظائف؟',
      'visitDashboard': 'زيارة لوحة التحكم',
      'checkingProfileStatus': 'فحص حالة الملف الشخصي...',
      'notLoggedIn': 'غير مسجل الدخول',
      'error': 'خطأ',
      'retry': 'إعادة المحاولة',
      'welcomeUser': 'مرحباً',
      'completeProfile': 'يرجى إكمال ملفك الشخصي للوصول إلى جميع الميزات',
      'todayOverview': 'نظرة عامة اليوم',
      'todaysOverview': 'نظرة عامة على اليوم',
      'inHubPackages': 'الطرود في المركز',
      'headingToCustomer': 'في طريقها للعميل',
      'awaitingAction': 'في انتظار الإجراء',
      'successfulOrders': 'الطلبات الناجحة',
      'unsuccessfulOrders': 'الطلبات غير الناجحة',
      'headingToYou': 'في طريقها إليك',
      'newOrders': 'الطلبات الجديدة',
      'successRate': 'معدل النجاح',
      'unsuccessRate': 'معدل عدم النجاح',
      
      // Order preparation workflow
      'preparingYourOrders': 'تحضير طلباتك',
      'followProfessionalSteps': 'اتبع هذه الخطوات المهنية للشحن الناجح',
      'readyToPrepare': 'جاهز للتحضير',
      'verifyOrderInformation': 'التحقق من معلومات الطلب',
      'doubleCheckCustomerDetails': 'تحقق مرة أخرى من جميع تفاصيل العميل والعناوين ومواصفات المنتج للتأكد من الدقة',
      'selectProperPackaging': 'اختر التغليف المناسب',
      'chooseAppropriatePackaging': 'اختر مواد التغليف المناسبة بناءً على هشاشة المنتج ووزنه وأبعاده',
      'securePackageContents': 'تأمين محتويات الطرد',
      'useProperCushioning': 'استخدم مواد التبطين المناسبة وتأكد من تثبيت المنتجات بشكل آمن لمنع التلف',
      'applyShippingLabel': 'تطبيق ملصق الشحن',
      'printAndAffixLabels': 'اطبع وألصق ملصقات الشحن بوضوح على الطرد، مع التأكد من قابلية مسح الرموز الشريطية',
      'arrangeForPickup': 'رتب للاستلام من خلال التطبيق أو استعد للتسليم في موقع شحن معتمد',
      
      // Financial/Cash collection
      'expectedCash': 'النقد المتوقع',
      'collectedCash': 'النقد المحصل',
      'egp': 'جنيه مصري',
      'youHaveCreatedOrders': 'لقد أنشأت {count} طلبات جديدة',
      'prepareOrders': 'تحضير الطلبات',
      
      // Orders
      'createNewOrder': 'إنشاء طلب جديد',
      'areYouSureExit': 'هل أنت متأكد من أنك تريد الخروج؟',
      'changesWontBeSaved': 'لن يتم حفظ التغييرات على الطلب إذا خرجت',
      'orderDataWontBeSaved': 'لن يتم حفظ بيانات الطلب والتحديثات إذا قررت الخروج',
      'errorLoadingOrders': 'خطأ في تحميل الطلبات',
      'checkConnectionRetry': 'يرجى فحص اتصالك والمحاولة مرة أخرى',
      'noOrdersYet': 'لم تقم بإنشاء طلبات بعد!',
      'noOrdersWithStatus': 'لا توجد طلبات بحالة',
      'customerDetails': 'تفاصيل العميل',
      'deliveryType': 'نوع التوصيل',
      'deliver': 'توصيل',
      'cashCollection': 'تحصيل نقدي',
      'productDescription': 'وصف المنتج',
      'orderValue': 'قيمة الطلب',
      'shippingFees': 'رسوم الشحن',
      'totalAmount': 'المبلغ الإجمالي',
      
      // Pickups
      'createPickup': 'إنشاء استلام',
      'editPickup': 'تعديل الاستلام',
      'clear': 'مسح',
      'pickupDetails': 'تفاصيل الاستلام',
      'placeOfPickup': 'مكان الاستلام',
      'savedPickupAddress': 'سيتم استخدام عنوان الاستلام المحفوظ لهذا الطلب.',
      'whatsappAvailable': 'يرجى التأكد من أن هذا الرقم متاح على الواتساب لتحديثات التسليم.',
      'pickupNotes': 'ملاحظات الاستلام',
      'noUpcomingPickups': 'لا توجد عمليات استلام قادمة',
      'noPickupHistory': 'لا يوجد تاريخ استلام',
      'createFirstPickup': 'أنشئ أول عملية استلام للبدء',
      'completedPickupsHere': 'ستظهر عمليات الاستلام المكتملة هنا',
      'cancelPickup': 'إلغاء الاستلام',
      'cancelPickupConfirmation': 'هل أنت متأكد من أنك تريد إلغاء الاستلام #{number}؟ هذا الإجراء لا يمكن التراجع عنه.',
      'no': 'لا',
      'yesCancelPickup': 'نعم، إلغاء',
      'pickupCancellationSoon': 'ميزة إلغاء الاستلام قريباً',
      'upcoming': 'القادمة',
      'history': 'التاريخ',
      
      // More Screen
      'accountSettings': 'إعدادات الحساب',
      'accountActions': 'إجراءات الحساب',
      
      // Common UI Elements
      'close': 'إغلاق',
      'undo': 'تراجع',
      'save': 'حفظ',
      'edit': 'تعديل',
      'delete': 'حذف',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'yes': 'نعم',
      'loading': 'جاري التحميل',
      'pleaseWait': 'يرجى الانتظار...',
      'success': 'نجح',
      'warning': 'تحذير',
      'info': 'معلومات',
      'tryAgain': 'حاول مرة أخرى',
      'refresh': 'تحديث',
      'refreshFailed': 'فشل التحديث',
      
      // Onboarding
      'effortlessShipping': 'شحن سهل،\nفي أي وقت',
      'effortlessShippingDesc': 'أنشئ وأدر الشحنات بنقرات قليلة. بسيط وسريع وموثوق.',
      'trackDeliveries': 'تتبع التسليم في الوقت الفعلي',
      'trackDeliveriesDesc': 'ابق محدثاً بالتتبع المباشر وحالات الطلبات وتقدم التسليم.',
      'securePayments': 'مدفوعات آمنة وسلسة',
      'securePaymentsDesc': 'أدر المعاملات النقدية بثقة. اجمع وتتبع وأكد كل دفعة.',
      'skip': 'تخطي',
      'next': 'التالي',
      'getStarted': 'البدء',
      'youHaveInOurHubs': 'لديك في مراكزنا',
      'packages': 'الطرود',
      'create': 'إنشاء',
      'singleOrder': 'طلب واحد',
      'createOrdersOneByOne': 'إنشاء الطلبات واحداً تلو الآخر.',
      'schedulePickupTitle': 'جدولة الاستلام',
      'requestPickupDescription': 'طلب استلام لأخذ طلباتك.',
      'personalInformation': 'المعلومات الشخصية',
      'profilePicture': 'صورة الملف الشخصي',
      'basicInformation': 'المعلومات الأساسية',
      'fullName': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'phone': 'الهاتف',
      'businessInformation': 'معلومات العمل',
      'businessName': 'اسم الشركة',
      'role': 'الدور',
      'storageNeeded': 'التخزين المطلوب',
      'accountStatus': 'حالة الحساب',
      'registeredDate': 'تاريخ التسجيل',
      'editInformation': 'تعديل المعلومات',
      'editPersonalInformation': 'تعديل المعلومات الشخصية',
      'active': 'نشط',
      'pendingVerification': 'في انتظار التحقق',
      'inactive': 'غير نشط',
      'noUserDataAvailable': 'لا توجد بيانات مستخدم متاحة',
      'tapToChangeProfilePicture': 'انقر لتغيير صورة الملف الشخصي',
      'pleaseEnterYourName': 'يرجى إدخال اسمك',
      'pleaseEnterYourEmail': 'يرجى إدخال بريدك الإلكتروني',
      'pleaseEnterValidEmail': 'يرجى إدخال بريد إلكتروني صحيح',
      'pleaseEnterYourPhoneNumber': 'يرجى إدخال رقم هاتفك',
      'pleaseEnterYourBusinessName': 'يرجى إدخال اسم شركتك',
      'saveChanges': 'حفظ التغييرات',
      'deleteYourAccount': 'حذف حسابك؟',
      'deleteAccountWarning': 'لا يمكن التراجع عن هذا الإجراء. بمجرد حذف حسابك:',
      'deletePersonalInfo': 'ستتم إزالة جميع معلوماتك الشخصية نهائياً',
      'loseDataAccess': 'ستفقد الوصول إلى جميع بياناتك وسجل نشاطك',
      'cancelSubscriptions': 'سيتم إلغاء أي اشتراكات نشطة',
      'needNewAccount': 'ستحتاج إلى إنشاء حساب جديد إذا كنت تريد استخدام التطبيق مرة أخرى',
      'confirmDeletion': 'تأكيد الحذف',
      'securityVerification': 'التحقق الأمني',
      'securityPasswordPrompt': 'لأسباب أمنية، يرجى إدخال كلمة المرور لتأكيد حذف الحساب.',
      'password': 'كلمة المرور',
      'pleaseEnterPassword': 'يرجى إدخال كلمة المرور',
      'continueAction': 'متابعة',
      'areYouSureLogout': 'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
      'allOrders': 'الكل',
      'newStatus': 'جديد',
      'pickedUpStatus': 'تم الاستلام',
      'inStockStatus': 'في المخزن',
      'inProgressStatus': 'قيد التنفيذ',
      'headingToCustomerStatus': 'في طريقها للعميل',
      'headingToYouStatus': 'في طريقها إليك',
      'completedStatus': 'مكتمل',
      'canceledStatus': 'ملغي',
      'rejectedStatus': 'مرفوض',
      'returnedStatus': 'مرتجع',
      'terminatedStatus': 'منتهي',
      'filterByDeliveryType': 'تصفية حسب نوع التوصيل',
      'deliverType': 'توصيل',
      'exchangeType': 'استبدال',
      'returnType': 'إرجاع',
      'cashCollectionType': 'تحصيل نقدي',
      'applyFilter': 'تطبيق التصفية',
      'orderNumber': 'طلب رقم',
      'cashOnDeliveryText': 'الدفع عند الاستلام',
      'pullDownToRefresh': 'اسحب لأسفل للتحديث',
      'releaseToRefresh': 'اتركه للتحديث',
      'refreshingText': 'جاري التحديث...',
      'refreshCompleted': 'اكتمل التحديث',
      'refreshFailedText': 'فشل التحديث',
      'tracking': 'التتبع',
      'orderDetails': 'تفاصيل الطلب',
      'scanSmartSticker': 'مسح الملصق الذكي',
      'customer': 'العميل',
      'shippingInformation': 'معلومات الشحن',
      'deliverItemsToCustomer': 'توصيل العناصر للعميل',
      'exchangeItemsWithCustomer': 'استبدال العناصر مع العميل',
      'returnItemsFromCustomer': 'إرجاع العناصر من العميل',
      'deliveryDetails': 'تفاصيل التوصيل',
      'packageType': 'نوع الطرد',
      'parcel': 'طرد',
      'numberOfItems': 'عدد العناصر',
      'packageDescription': 'وصف الطرد',
      'allowCustomerInspect': 'السماح للعميل بفحص الطرد',
      'expressShipping': 'الشحن السريع',
      'additionalDetails': 'تفاصيل إضافية',
      'specialInstructions': 'تعليمات خاصة',
      'referenceNumber': 'رقم المرجع',
      'dateCreated': 'تاريخ الإنشاء',
      'status': 'الحالة',
      'orderCreatedSuccess': 'تم إنشاء الطلب بنجاح.',
      'pickedUpTitle': 'تم الاستلام',
      'pickedUpDescription': 'تم استلام طلبك! يجب أن يصل إلى مستودعاتنا بحلول نهاية اليوم.',
      'inStockTitle': 'في المخزن',
      'inStockDescription': 'طلبك الآن في مستودعنا.',
      'headingToCustomerTitle': 'في طريقه للعميل',
      'headingToCustomerDescription': 'تم شحن الطلب للتوصيل إلى عميلك.',
      'successfulTitle': 'مكتمل',
      'successfulDescription': 'تم توصيل الطلب بنجاح إلى عميلك 🎉',
      'orderActions': 'إجراءات الطلب',
      'viewDetails': 'عرض التفاصيل',
      'printAirwaybill': 'طباعة بوليصة الشحن',
      'editOrder': 'تعديل الطلب',
      'trackOrder': 'تتبع الطلب',
      'deleteOrder': 'حذف الطلب',

      // Create Order Screen
      'addCustomerDetails': 'إضافة تفاصيل العميل',
      'selectDeliveryTypeDescription': 'اختر نوع التسليم وقدم تفاصيل الشحن',
      'orderType': 'نوع الطلب',
      'cashCollect': 'تحصيل نقدي',
      'describeProductsPlaceholder': 'وصف المنتجات المراد توصيلها',
      'additionalOptions': 'خيارات إضافية',
      'specialRequirementsDescription': 'حدد أي متطلبات خاصة لهذا الطلب',
      'allowOpeningPackage': 'السماح بفتح الطرد',
      'specialInstructionsPlaceholder': 'أضف أي تعليمات توصيل خاصة أو ملاحظات',
      'referralNumberOptional': 'رقم الإحالة (اختياري)',
      'referralCodePlaceholder': 'أدخل رمز الإحالة إذا كان متاحًا',
      'deliveryFeeSummary': 'ملخص رسوم التوصيل',
      'totalDeliveryFee': 'إجمالي رسوم التوصيل',
      'confirmOrder': 'تأكيد الطلب',
      
      // Customer Details Screen
      'phoneNumber': 'رقم الهاتف',
      'addSecondaryNumber': 'إضافة رقم ثانوي',
      'namePlaceholder': 'الاسم',
      'address': 'العنوان',
      'cityArea': 'المدينة - المنطقة',
      'addressDetails': 'تفاصيل العنوان',
      'apartment': '...الشقة',
      'floor': 'الطابق',
      'building': 'المبنى',
      'landmark': 'معلم مميز',
      'thisIsWorkingAddress': 'هذا عنوان العمل',

      // City names
      'cairo': 'القاهرة',
      'alexandria': 'الإسكندرية',
      'giza': 'الجيزة',
      'portSaid': 'بورسعيد',
      'suez': 'السويس',
      'luxor': 'الأقصر',
      'aswan': 'أسوان',
      'hurghada': 'الغردقة',
      'sharmElSheikh': 'شرم الشيخ',

      // Cash on Delivery
      'cashOnDelivery': 'الدفع عند الاستلام',
      'cashOnDeliveryAmount': 'مبلغ الدفع عند الاستلام',
      'enterAmount': 'أدخل المبلغ',

      // Dialog buttons
      'exit': 'خروج',

      // Print dialog
      'selectPaperSize': 'اختر حجم الورق للطباعة',
      'printA4': 'طباعة A4',
      'printA5': 'طباعة A5',
      'ok': 'موافق',

      // Edit order dialog
      'changesNotSaved': 'لن يتم حفظ التغييرات على الطلب إذا خرجت',

      // Login form
      'emailOrPhoneNumber': 'البريد الإلكتروني أو رقم الهاتف',
      'emailOrPhonePlaceholder': 'johndoe@email.com أو 1234567890',
      'emailOrPhoneRequired': 'البريد الإلكتروني أو رقم الهاتف مطلوب',
      'enterValidEmailOrPhone': 'أدخل بريد إلكتروني أو رقم هاتف صحيح',
      'passwordPlaceholder': '********',
      'minCharacters': 'الحد الأدنى 6 أحرف',
      'rememberMe': 'تذكرني',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'forgotPasswordDescription': 'أدخل عنوان بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور',
      'emailAddress': 'عنوان البريد الإلكتروني',
      'sendResetLink': 'إرسال رابط إعادة التعيين',
      'emailSent': 'تم إرسال البريد الإلكتروني!',
      'emailSentDescription': 'لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى عنوان بريدك الإلكتروني. يرجى التحقق من صندوق الوارد واتباع التعليمات لإعادة تعيين كلمة المرور.',
      'resendEmail': 'إعادة إرسال البريد الإلكتروني',
      'backToLogin': 'العودة لتسجيل الدخول',
      'checkEmailForReset': 'تحقق من بريدك الإلكتروني للحصول على تعليمات إعادة التعيين',
      'enterOtpCode': 'أدخل رمز التحقق',
      'otpCode': 'رمز التحقق',
      'otpCodePlaceholder': 'أدخل الرمز المكون من 6 أرقام',
      'verifyOtp': 'تحقق من الرمز',
      'otpSentToEmail': 'لقد أرسلنا رمز مكون من 6 أرقام إلى عنوان بريدك الإلكتروني',
      'resendOtp': 'إعادة إرسال الرمز',
      'otpVerified': 'تم التحقق من الرمز!',
      'otpVerifiedDescription': 'تم التحقق من رمز التحقق بنجاح. يمكنك الآن إعادة تعيين كلمة المرور.',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'resetPasswordDescription': 'أدخل كلمة المرور الجديدة أدناه لإكمال عملية إعادة التعيين',
      'newPassword': 'كلمة المرور الجديدة',
      'newPasswordPlaceholder': 'أدخل كلمة المرور الجديدة',
      'confirmNewPassword': 'تأكيد كلمة المرور الجديدة',
      'confirmNewPasswordPlaceholder': 'أكد كلمة المرور الجديدة',
      'continueToResetPassword': 'متابعة لإعادة تعيين كلمة المرور',
      'goToLogin': 'الذهاب لتسجيل الدخول',
      'passwordResetSuccessfully': 'تم إعادة تعيين كلمة المرور بنجاح!',
      'passwordResetSuccessDescription': 'تم إعادة تعيين كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.',
      'otpVerifiedSuccessfully': 'تم التحقق من الرمز بنجاح',
      'otpSentSuccessfully': 'تم إرسال الرمز إلى بريدك الإلكتروني بنجاح',
      'otpResentSuccessfully': 'تم إعادة إرسال الرمز بنجاح',
      'invalidOtpCode': 'رمز التحقق غير صحيح. يرجى إدخال رقم مكون من 6 أرقام.',
      'passwordResetSuccessfullyToast': 'تم إعادة تعيين كلمة المرور بنجاح',

      // Signup form
      'enterFullName': 'أدخل اسمك الكامل',
      'enterEmailAddress': 'أدخل عنوان بريدك الإلكتروني',
      'createPassword': 'إنشاء كلمة مرور',
      'iWantStorage': 'أريد التخزين',
      'iAgreeToTerms': 'أوافق على الشروط والأحكام',
      'login': 'تسجيل الدخول',
      'verify': 'تحقق',
      'verified': 'تم التحقق',
      'alreadyHaveAccount': 'لديك حساب بالفعل',

      // Create Pickup Screen
      'enterNumberOfOrders': 'أدخل عدد الطلبات',
      'pickupAddressHelper': 'عنوان الاستلام المسجل من إنشاء الحساب مستخدم لجميع عمليات الاستلام',
      'contactInfo': 'معلومات الاتصال',
      'whatsappHelper': 'تأكد من أن هذا الرقم متاح على واتساب لتحديثات التسليم',
      'pickUpDate': 'تاريخ الاستلام',
      'enterPickupNotes': 'أدخل أي تعليمات أو ملاحظات خاصة للاستلام',
      'requiresLargerVehicle': 'يتطلب مركبة أكبر',
      'specialHandlingRequired': 'يتطلب معالجة خاصة',

      // Create Bottom Sheet
      'requestPickupToPickOrders': 'طلب استلام لاستلام طلباتك',

      // Language Settings
      'languageSettings': 'إعدادات اللغة',
      'choosePreferredLanguage': 'اختر لغتك المفضلة',
      'selectLanguage': 'اختر اللغة',
      'tapLanguageOptionToChange': 'اضغط على خيار اللغة للتغيير',
      'changingLanguageWillRestart': 'تغيير اللغة سيعيد تشغيل التطبيق لتطبيق الإعدادات الجديدة',
      'switchToEnglish': 'التبديل إلى الإنجليزية؟',
      'switchToArabic': 'التبديل إلى العربية؟',
      'appWillRestartToApplyLanguage': 'سيعيد التطبيق التشغيل لتطبيق اللغة الجديدة.',

      // Contact Us Screen
      'ourOffice': 'مكتبنا',
      'businessHours': 'ساعات العمل',
      'phoneAndEmail': 'الهاتف والبريد الإلكتروني',
      'sendUsMessage': 'أرسل لنا رسالة',
      'yourName': 'اسمك',
      'yourEmail': 'بريدك الإلكتروني',
      'issueType': 'نوع المشكلة',
      'generalInquiry': 'استفسار عام',
      'yourMessage': 'رسالتك',
      'sendMessage': 'إرسال الرسالة',

      // About Screen
      'aboutNowShipping': 'حول Now Shipping',
      'aboutDescription': 'Now Shipping هو منصة حديثة لإدارة الشحن مصممة للشركات من جميع الأحجام. تساعدك منصتنا في إدارة عمليات الشحن بكفاءة، من إنشاء الطلبات إلى تتبع التسليمات',
      'keyFeatures': 'الميزات الرئيسية',
      'easyOrderCreation': 'إنشاء وإدارة الطلبات بسهولة',
      'realTimeTracking': 'تتبع الشحنات في الوقت الفعلي',
      'integratedPayments': 'حلول الدفع المتكاملة',
      'addressManagement': 'إدارة عناوين العملاء',
      'analyticsReporting': 'التحليلات والتقارير',
      'multiPlatformSupport': 'دعم متعدد المنصات',
      'companyInformation': 'معلومات الشركة',
      'founded': 'تأسست',
      'headquarters': 'المقر الرئيسي',
      'website': 'الموقع الإلكتروني',
      'legal': 'قانوني',
      'allRightsReserved': 'Now Shipping. جميع الحقوق محفوظة 2025 ©',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for commonly used strings
  String get appTitle => get('appTitle');
  String get loginTitle => get('loginTitle');
  String get registerTitle => get('registerTitle');
  String get emailLabel => get('emailLabel');
  String get passwordLabel => get('passwordLabel');
  String get nameLabel => get('nameLabel');
  String get phoneLabel => get('phoneLabel');
  String get loginButton => get('loginButton');
  String get registerButton => get('registerButton');
  String get createAccountPrompt => get('createAccountPrompt');
  String get alreadyHaveAccountPrompt => get('alreadyHaveAccountPrompt');
  String get businessOwnerLabel => get('businessOwnerLabel');
  String get deliveryPersonLabel => get('deliveryPersonLabel');
  String get accountTypeLabel => get('accountTypeLabel');
  String get businessDashboardTitle => get('businessDashboardTitle');
  String get deliveryDashboardTitle => get('deliveryDashboardTitle');
  String get activeShipmentsLabel => get('activeShipmentsLabel');
  String get deliveredLabel => get('deliveredLabel');
  String get recentShipmentsLabel => get('recentShipmentsLabel');
  String get assignedShipmentsLabel => get('assignedShipmentsLabel');
  String get createShipmentButton => get('createShipmentButton');
  String get updateButton => get('updateButton');
  String get scanShipmentButton => get('scanShipmentButton');
  String get noShipmentsMessage => get('noShipmentsMessage');
  String get noAssignedShipmentsMessage => get('noAssignedShipmentsMessage');
  String get createShipmentTitle => get('createShipmentTitle');
  String get packageDescriptionLabel => get('packageDescriptionLabel');
  String get receiverInfoLabel => get('receiverInfoLabel');
  String get receiverNameLabel => get('receiverNameLabel');
  String get receiverPhoneLabel => get('receiverPhoneLabel');
  String get deliveryAddressLabel => get('deliveryAddressLabel');
  String get shipmentCreatedSuccess => get('shipmentCreatedSuccess');
  String get shipmentDetailsTitle => get('shipmentDetailsTitle');
  String get statusLabel => get('statusLabel');
  String get trackingNumberLabel => get('trackingNumberLabel');
  String get createdLabel => get('createdLabel');
  String get descriptionLabel => get('descriptionLabel');
  String get recipientLabel => get('recipientLabel');
  String get addressLabel => get('addressLabel');
  String get updateStatusLabel => get('updateStatusLabel');
  String get inTransitStatus => get('inTransitStatus');
  String get deliveredStatus => get('deliveredStatus');
  String get captureProofButton => get('captureProofButton');
  String get assignShipmentButton => get('assignShipmentButton');
  String get deleteShipmentButton => get('deleteShipmentButton');
  String get deleteConfirmation => get('deleteConfirmation');
  String get cancelButton => get('cancelButton');
  String get deleteButton => get('deleteButton');
  String get assignButton => get('assignButton');
  String get assignShipmentTitle => get('assignShipmentTitle');
  String get shipmentAssignedSuccess => get('shipmentAssignedSuccess');
  String get shipmentDeletedSuccess => get('shipmentDeletedSuccess');
  String get statusUpdatedSuccess => get('statusUpdatedSuccess');
  String get languageTitle => get('languageTitle');
  String get currentLanguage => get('currentLanguage');
  String get activeLanguage => get('activeLanguage');
  String get doneButton => get('doneButton');
  String get changeLanguage => get('changeLanguage');
  String get changeLanguageConfirmation => get('changeLanguageConfirmation');
  String get confirmButton => get('confirmButton');
  String get languageChangedSuccess => get('languageChangedSuccess');
  String get english => get('english');
  String get arabic => get('arabic');
  String get applicationSettings => get('applicationSettings');
  String get support => get('support');
  String get contactUs => get('contactUs');
  String get about => get('about');
  String get personalInfo => get('personalInfo');
  String get security => get('security');
  String get notifications => get('notifications');
  String get helpCenter => get('helpCenter');
  String get deleteAccount => get('deleteAccount');
  String get logout => get('logout');
  String get profile => get('profile');
  String get settings => get('settings');
  String get termsOfService => get('termsOfService');
  String get privacyPolicy => get('privacyPolicy');
  String get lastUpdated => get('lastUpdated');
  String get enterPhoneNumber => get('enterPhoneNumber');
  String get thisFieldIsRequired => get('thisFieldIsRequired');
  String get whatsAppNote => get('whatsAppNote');
  String get locationNote => get('locationNote');
  String get pickupDate => get('pickupDate');
  String get pickupAddress => get('pickupAddress');
  String get contactNumber => get('contactNumber');
  String get numberOfOrders => get('numberOfOrders');
  String get specialRequirements => get('specialRequirements');
  String get fragileItem => get('fragileItem');
  String get largeItem => get('largeItem');
  String get additionalNotes => get('additionalNotes');
  String get schedulePickup => get('schedulePickup');
  String get updatePickup => get('updatePickup');
  String get pickupScheduled => get('pickupScheduled');
  String get pickupUpdated => get('pickupUpdated');
  String get today => get('today');
  String get tomorrow => get('tomorrow');
  String get selectDate => get('selectDate');
  String get welcome => get('welcome');
  String get dashboard => get('dashboard');
  String get home => get('home');
  String get orders => get('orders');
  String get pickups => get('pickups');
  String get wallet => get('wallet');
  String get more => get('more');
  
  // Authentication screens getters
  String get createAccount => get('createAccount');
  String get fillInDetails => get('fillInDetails');
  String get welcomeBack => get('welcomeBack');
  String get loginToAccount => get('loginToAccount');
  String get dontHaveAccount => get('dontHaveAccount');
  String get signUp => get('signUp');
  String get agreeToTerms => get('agreeToTerms');
  String get verifyPhoneNumber => get('verifyPhoneNumber');
  String get resendCode => get('resendCode');
  String get verificationCode => get('verificationCode');
  String get enterVerificationCode => get('enterVerificationCode');
  String get wantStorage => get('wantStorage');
  String get termsAndConditions => get('termsAndConditions');
  
  // Dashboard and Home getters
  String get hello => get('hello');
  String get moreFunctionalities => get('moreFunctionalities');
  String get visitDashboard => get('visitDashboard');
  String get checkingProfileStatus => get('checkingProfileStatus');
  String get notLoggedIn => get('notLoggedIn');
  String get error => get('error');
  String get retry => get('retry');
  String get welcomeUser => get('welcomeUser');
  String get completeProfile => get('completeProfile');
  String get todayOverview => get('todayOverview');
  String get inHubPackages => get('inHubPackages');
  String get headingToCustomer => get('headingToCustomer');
  String get awaitingAction => get('awaitingAction');
  String get successfulOrders => get('successfulOrders');
  String get unsuccessfulOrders => get('unsuccessfulOrders');
  String get headingToYou => get('headingToYou');
  String get newOrders => get('newOrders');
  String get successRate => get('successRate');
  String get unsuccessRate => get('unsuccessRate');
  
  // Orders getters
  String get createNewOrder => get('createNewOrder');
  String get areYouSureExit => get('areYouSureExit');
  String get changesWontBeSaved => get('changesWontBeSaved');
  String get orderDataWontBeSaved => get('orderDataWontBeSaved');
  String get errorLoadingOrders => get('errorLoadingOrders');
  String get checkConnectionRetry => get('checkConnectionRetry');
  String get noOrdersYet => get('noOrdersYet');
  String get noOrdersWithStatus => get('noOrdersWithStatus');
  String get customerDetails => get('customerDetails');
  String get deliveryType => get('deliveryType');
  String get deliver => get('deliver');
  String get cashCollection => get('cashCollection');
  String get productDescription => get('productDescription');
  String get orderValue => get('orderValue');
  String get shippingFees => get('shippingFees');
  String get totalAmount => get('totalAmount');
  
  // Pickups getters
  String get createPickup => get('createPickup');
  String get editPickup => get('editPickup');
  String get clear => get('clear');
  String get pickupDetails => get('pickupDetails');
  String get placeOfPickup => get('placeOfPickup');
  String get savedPickupAddress => get('savedPickupAddress');
  String get whatsappAvailable => get('whatsappAvailable');
  String get pickupNotes => get('pickupNotes');
  String get noUpcomingPickups => get('noUpcomingPickups');
  String get noPickupHistory => get('noPickupHistory');
  String get createFirstPickup => get('createFirstPickup');
  String get completedPickupsHere => get('completedPickupsHere');
  String get cancelPickup => get('cancelPickup');
  String get cancelPickupConfirmation => get('cancelPickupConfirmation');
  String get no => get('no');
  String get yesCancelPickup => get('yesCancelPickup');
  String get pickupCancellationSoon => get('pickupCancellationSoon');
  String get upcoming => get('upcoming');
  String get history => get('history');
  
  // More Screen getters
  String get accountSettings => get('accountSettings');
  String get accountActions => get('accountActions');
  
  // Common UI Elements getters
  String get close => get('close');
  String get undo => get('undo');
  String get save => get('save');
  String get edit => get('edit');
  String get delete => get('delete');
  String get cancel => get('cancel');
  String get confirm => get('confirm');
  String get yes => get('yes');
  String get loading => get('loading');
  String get pleaseWait => get('pleaseWait');
  String get success => get('success');
  String get warning => get('warning');
  String get info => get('info');
  String get tryAgain => get('tryAgain');
  String get refresh => get('refresh');
  String get refreshFailed => get('refreshFailed');
  
  // Dashboard specific getters
  String get suggestionBox => get('suggestionBox');
  String get newLabel => get('newLabel');
  String get helpUsServeBetter => get('helpUsServeBetter');
  String get shareSuggestions => get('shareSuggestions');
  String get suggestNow => get('suggestNow');
  String get youreAllSet => get('youreAllSet');
  String get profileCompletedSuccess => get('profileCompletedSuccess');
  String get todaysOverview => get('todaysOverview');
  String get inHub => get('inHub');
  String get packages => get('packages');
  String get viewAll => get('viewAll');
  String get statistics => get('statistics');
  String get thisWeek => get('thisWeek');
  String get thisMonth => get('thisMonth');
  String get newOrdersCount => get('newOrdersCount');
  String get completedOrdersCount => get('completedOrdersCount');
  String get revenue => get('revenue');
  String get totalEarnings => get('totalEarnings');
  String get youHaveInOurHubs => get('youHaveInOurHubs');
  String get profileSummary => get('profileSummary');
  String get brand => get('brand');
  String get industry => get('industry');
  String get location => get('location');
  String get payment => get('payment');
  String get finishSetup => get('finishSetup');
  String get notProvided => get('notProvided');
  String get city => get('city');
  String get country => get('country');
  String get cashOnDelivery => get('cashOnDelivery');
  String get bankTransfer => get('bankTransfer');
  String get digitalWallet => get('digitalWallet');
  String get notSelected => get('notSelected');
  
  // Order preparation workflow getters
  String get preparingYourOrders => get('preparingYourOrders');
  String get followProfessionalSteps => get('followProfessionalSteps');
  String get readyToPrepare => get('readyToPrepare');
  String get verifyOrderInformation => get('verifyOrderInformation');
  String get doubleCheckCustomerDetails => get('doubleCheckCustomerDetails');
  String get selectProperPackaging => get('selectProperPackaging');
  String get chooseAppropriatePackaging => get('chooseAppropriatePackaging');
  String get securePackageContents => get('securePackageContents');
  String get useProperCushioning => get('useProperCushioning');
  String get applyShippingLabel => get('applyShippingLabel');
  String get printAndAffixLabels => get('printAndAffixLabels');
  String get arrangeForPickup => get('arrangeForPickup');
  
  // Financial/Cash collection getters
  String get expectedCash => get('expectedCash');
  String get collectedCash => get('collectedCash');
  String get egp => get('egp');
  String get youHaveCreatedOrders => get('youHaveCreatedOrders');
  String get prepareOrders => get('prepareOrders');
  String get create => get('create');
  String get singleOrder => get('singleOrder');
  String get createOrdersOneByOne => get('createOrdersOneByOne');
  String get schedulePickupTitle => get('schedulePickupTitle');
  String get requestPickupDescription => get('requestPickupDescription');
  String get personalInformation => get('personalInformation');
  String get profilePicture => get('profilePicture');
  String get basicInformation => get('basicInformation');
  String get fullName => get('fullName');
  String get email => get('email');
  String get phone => get('phone');
  String get businessInformation => get('businessInformation');
  String get businessName => get('businessName');
  String get role => get('role');
  String get storageNeeded => get('storageNeeded');
  String get accountStatus => get('accountStatus');
  String get registeredDate => get('registeredDate');
  String get editInformation => get('editInformation');
  String get editPersonalInformation => get('editPersonalInformation');
  String get active => get('active');
  String get pendingVerification => get('pendingVerification');
  String get inactive => get('inactive');
  String get noUserDataAvailable => get('noUserDataAvailable');
  String get tapToChangeProfilePicture => get('tapToChangeProfilePicture');
  String get pleaseEnterYourName => get('pleaseEnterYourName');
  String get pleaseEnterYourEmail => get('pleaseEnterYourEmail');
  String get pleaseEnterValidEmail => get('pleaseEnterValidEmail');
  String get pleaseEnterYourPhoneNumber => get('pleaseEnterYourPhoneNumber');
  String get pleaseEnterYourBusinessName => get('pleaseEnterYourBusinessName');
  String get saveChanges => get('saveChanges');
  String get deleteYourAccount => get('deleteYourAccount');
  String get deleteAccountWarning => get('deleteAccountWarning');
  String get deletePersonalInfo => get('deletePersonalInfo');
  String get loseDataAccess => get('loseDataAccess');
  String get cancelSubscriptions => get('cancelSubscriptions');
  String get needNewAccount => get('needNewAccount');
  String get confirmDeletion => get('confirmDeletion');
  String get securityVerification => get('securityVerification');
  String get securityPasswordPrompt => get('securityPasswordPrompt');
  String get password => get('password');
  String get pleaseEnterPassword => get('pleaseEnterPassword');
  String get continueAction => get('continueAction');
  String get areYouSureLogout => get('areYouSureLogout');
  String get allOrders => get('allOrders');
  String get newStatus => get('newStatus');
  String get pickedUpStatus => get('pickedUpStatus');
  String get inStockStatus => get('inStockStatus');
  String get inProgressStatus => get('inProgressStatus');
  String get headingToCustomerStatus => get('headingToCustomerStatus');
  String get headingToYouStatus => get('headingToYouStatus');
  String get completedStatus => get('completedStatus');
  String get canceledStatus => get('canceledStatus');
  String get rejectedStatus => get('rejectedStatus');
  String get returnedStatus => get('returnedStatus');
  String get terminatedStatus => get('terminatedStatus');
  String get filterByDeliveryType => get('filterByDeliveryType');
  String get deliverType => get('deliverType');
  String get exchangeType => get('exchangeType');
  String get returnType => get('returnType');
  String get cashCollectionType => get('cashCollectionType');
  String get applyFilter => get('applyFilter');
  String get orderNumber => get('orderNumber');
  String get cashOnDeliveryText => get('cashOnDeliveryText');
  String get pullDownToRefresh => get('pullDownToRefresh');
  String get releaseToRefresh => get('releaseToRefresh');
  String get refreshingText => get('refreshingText');
  String get refreshCompleted => get('refreshCompleted');
  String get refreshFailedText => get('refreshFailedText');
  String get tracking => get('tracking');
  String get orderDetails => get('orderDetails');
  String get scanSmartSticker => get('scanSmartSticker');
  String get customer => get('customer');
  String get shippingInformation => get('shippingInformation');
  String get deliverItemsToCustomer => get('deliverItemsToCustomer');
  String get exchangeItemsWithCustomer => get('exchangeItemsWithCustomer');
  String get returnItemsFromCustomer => get('returnItemsFromCustomer');
  String get deliveryDetails => get('deliveryDetails');
  String get packageType => get('packageType');
  String get parcel => get('parcel');
  String get numberOfItems => get('numberOfItems');
  String get packageDescription => get('packageDescription');
  String get allowCustomerInspect => get('allowCustomerInspect');
  String get expressShipping => get('expressShipping');
  String get additionalDetails => get('additionalDetails');
  String get specialInstructions => get('specialInstructions');
  String get referenceNumber => get('referenceNumber');
  String get dateCreated => get('dateCreated');
  String get status => get('status');
  String get orderCreatedSuccess => get('orderCreatedSuccess');
  String get pickedUpTitle => get('pickedUpTitle');
  String get pickedUpDescription => get('pickedUpDescription');
  String get inStockTitle => get('inStockTitle');
  String get inStockDescription => get('inStockDescription');
  String get headingToCustomerTitle => get('headingToCustomerTitle');
  String get headingToCustomerDescription => get('headingToCustomerDescription');
  String get successfulTitle => get('successfulTitle');
  String get successfulDescription => get('successfulDescription');
  String get orderActions => get('orderActions');
  String get viewDetails => get('viewDetails');
  String get printAirwaybill => get('printAirwaybill');
  String get editOrder => get('editOrder');
  String get trackOrder => get('trackOrder');
  String get deleteOrder => get('deleteOrder');

  // Create Order Screen getters
  String get addCustomerDetails => get('addCustomerDetails');
  String get selectDeliveryTypeDescription => get('selectDeliveryTypeDescription');
  String get orderType => get('orderType');
  String get cashCollect => get('cashCollect');
  String get describeProductsPlaceholder => get('describeProductsPlaceholder');
  String get additionalOptions => get('additionalOptions');
  String get specialRequirementsDescription => get('specialRequirementsDescription');
  String get allowOpeningPackage => get('allowOpeningPackage');
  String get specialInstructionsPlaceholder => get('specialInstructionsPlaceholder');
  String get referralNumberOptional => get('referralNumberOptional');
  String get referralCodePlaceholder => get('referralCodePlaceholder');
  String get deliveryFeeSummary => get('deliveryFeeSummary');
  String get totalDeliveryFee => get('totalDeliveryFee');
  String get confirmOrder => get('confirmOrder');
  
  // Customer Details Screen getters
  String get phoneNumber => get('phoneNumber');
  String get addSecondaryNumber => get('addSecondaryNumber');
  String get namePlaceholder => get('namePlaceholder');
  String get address => get('address');
  String get cityArea => get('cityArea');
  String get addressDetails => get('addressDetails');
  String get apartment => get('apartment');
  String get floor => get('floor');
  String get building => get('building');
  String get landmark => get('landmark');
  String get thisIsWorkingAddress => get('thisIsWorkingAddress');

  // City name getters
  String get cairo => get('cairo');
  String get alexandria => get('alexandria');
  String get giza => get('giza');
  String get portSaid => get('portSaid');
  String get suez => get('suez');
  String get luxor => get('luxor');
  String get aswan => get('aswan');
  String get hurghada => get('hurghada');
  String get sharmElSheikh => get('sharmElSheikh');

  // Cash on Delivery getters
  String get cashOnDeliveryAmount => get('cashOnDeliveryAmount');
  String get enterAmount => get('enterAmount');

  // Dialog button getters
  String get exit => get('exit');

  // Print dialog getters
  String get selectPaperSize => get('selectPaperSize');
  String get printA4 => get('printA4');
  String get printA5 => get('printA5');
  String get ok => get('ok');

  // Edit order dialog getters
  String get changesNotSaved => get('changesNotSaved');

  // Login form getters
  String get emailOrPhoneNumber => get('emailOrPhoneNumber');
  String get emailOrPhonePlaceholder => get('emailOrPhonePlaceholder');
  String get emailOrPhoneRequired => get('emailOrPhoneRequired');
  String get enterValidEmailOrPhone => get('enterValidEmailOrPhone');
  String get passwordPlaceholder => get('passwordPlaceholder');
  String get minCharacters => get('minCharacters');
  String get rememberMe => get('rememberMe');
  String get forgotPassword => get('forgotPassword');
  String get forgotPasswordDescription => get('forgotPasswordDescription');
  String get emailAddress => get('emailAddress');
  String get sendResetLink => get('sendResetLink');
  String get emailSent => get('emailSent');
  String get emailSentDescription => get('emailSentDescription');
  String get resendEmail => get('resendEmail');
  String get backToLogin => get('backToLogin');
  String get checkEmailForReset => get('checkEmailForReset');
  String get enterOtpCode => get('enterOtpCode');
  String get otpCode => get('otpCode');
  String get otpCodePlaceholder => get('otpCodePlaceholder');
  String get verifyOtp => get('verifyOtp');
  String get otpSentToEmail => get('otpSentToEmail');
  String get resendOtp => get('resendOtp');
  String get otpVerified => get('otpVerified');
  String get otpVerifiedDescription => get('otpVerifiedDescription');
  String get resetPassword => get('resetPassword');
  String get resetPasswordDescription => get('resetPasswordDescription');
  String get newPassword => get('newPassword');
  String get newPasswordPlaceholder => get('newPasswordPlaceholder');
  String get confirmNewPassword => get('confirmNewPassword');
  String get confirmNewPasswordPlaceholder => get('confirmNewPasswordPlaceholder');
  String get continueToResetPassword => get('continueToResetPassword');
  String get goToLogin => get('goToLogin');
  String get passwordResetSuccessfully => get('passwordResetSuccessfully');
  String get passwordResetSuccessDescription => get('passwordResetSuccessDescription');
  String get otpVerifiedSuccessfully => get('otpVerifiedSuccessfully');
  String get otpSentSuccessfully => get('otpSentSuccessfully');
  String get otpResentSuccessfully => get('otpResentSuccessfully');
  String get invalidOtpCode => get('invalidOtpCode');
  String get passwordResetSuccessfullyToast => get('passwordResetSuccessfullyToast');

  // Signup form getters
  String get enterFullName => get('enterFullName');
  String get enterEmailAddress => get('enterEmailAddress');
  String get createPassword => get('createPassword');
  String get iWantStorage => get('iWantStorage');
  String get iAgreeToTerms => get('iAgreeToTerms');
  String get login => get('login');
  String get verify => get('verify');
  String get verified => get('verified');
  String get alreadyHaveAccount => get('alreadyHaveAccount');

  // Create Pickup Screen getters
  String get enterNumberOfOrders => get('enterNumberOfOrders');
  String get pickupAddressHelper => get('pickupAddressHelper');
  String get contactInfo => get('contactInfo');
  String get whatsappHelper => get('whatsappHelper');
  String get pickUpDate => get('pickUpDate');
  String get enterPickupNotes => get('enterPickupNotes');
  String get requiresLargerVehicle => get('requiresLargerVehicle');
  String get specialHandlingRequired => get('specialHandlingRequired');

  // Create Bottom Sheet getters
  String get requestPickupToPickOrders => get('requestPickupToPickOrders');

  // Language Settings getters
  String get languageSettings => get('languageSettings');
  String get choosePreferredLanguage => get('choosePreferredLanguage');
  String get selectLanguage => get('selectLanguage');
  String get tapLanguageOptionToChange => get('tapLanguageOptionToChange');
  String get changingLanguageWillRestart => get('changingLanguageWillRestart');
  String get switchToEnglish => get('switchToEnglish');
  String get switchToArabic => get('switchToArabic');
  String get appWillRestartToApplyLanguage => get('appWillRestartToApplyLanguage');

  // Contact Us Screen getters
  String get ourOffice => get('ourOffice');
  String get businessHours => get('businessHours');
  String get phoneAndEmail => get('phoneAndEmail');
  String get sendUsMessage => get('sendUsMessage');
  String get yourName => get('yourName');
  String get yourEmail => get('yourEmail');
  String get issueType => get('issueType');
  String get generalInquiry => get('generalInquiry');
  String get yourMessage => get('yourMessage');
  String get sendMessage => get('sendMessage');

  // About Screen getters
  String get aboutNowShipping => get('aboutNowShipping');
  String get aboutDescription => get('aboutDescription');
  String get keyFeatures => get('keyFeatures');
  String get easyOrderCreation => get('easyOrderCreation');
  String get realTimeTracking => get('realTimeTracking');
  String get integratedPayments => get('integratedPayments');
  String get addressManagement => get('addressManagement');
  String get analyticsReporting => get('analyticsReporting');
  String get multiPlatformSupport => get('multiPlatformSupport');
  String get companyInformation => get('companyInformation');
  String get founded => get('founded');
  String get headquarters => get('headquarters');
  String get website => get('website');
  String get legal => get('legal');
  String get allRightsReserved => get('allRightsReserved');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}
