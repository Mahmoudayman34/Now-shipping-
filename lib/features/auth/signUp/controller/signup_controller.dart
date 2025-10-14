import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
class SignupData {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final bool wantsStorage;
  final bool agreedToTerms;

  SignupData({
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.wantsStorage = false,
    this.agreedToTerms = false,
  });

  SignupData copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? password,
    bool? wantsStorage,
    bool? agreedToTerms,
  }) {
    return SignupData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      wantsStorage: wantsStorage ?? this.wantsStorage,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }
}

class SignupController extends StateNotifier<SignupData> {
  SignupController() : super(SignupData());

  void update({
    String? fullName,
    String? phone,
    String? email,
    String? password,
    bool? wantsStorage,
    bool? agreedToTerms,
  }) {
    state = state.copyWith(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      wantsStorage: wantsStorage,
      agreedToTerms: agreedToTerms,
    );
  }
}

final signupControllerProvider = StateNotifierProvider<SignupController, SignupData>(
  (ref) => SignupController(),
);
