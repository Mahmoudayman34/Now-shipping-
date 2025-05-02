/// Utility class for form validation throughout the app
class Validators {
  /// Validates that a field is not empty
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
  
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates phone number format
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    if (value.length < 8) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }
  
  /// Validates name format
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name is too short';
    }
    
    return null;
  }
  
  /// Validates password requirements
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  /// Validates address requirements
  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 5) {
      return 'Please enter a complete address';
    }
    
    return null;
  }
  
  /// Validates zip/postal code format
  static String? zipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal/ZIP code is required';
    }
    
    if (value.length < 4) {
      return 'Please enter a valid postal/ZIP code';
    }
    
    return null;
  }
}
