import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'delete_account_success_screen.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';

class DeleteAccountConfirmScreen extends StatefulWidget {
  const DeleteAccountConfirmScreen({super.key});

  @override
  State<DeleteAccountConfirmScreen> createState() => _DeleteAccountConfirmScreenState();
}

class _DeleteAccountConfirmScreenState extends State<DeleteAccountConfirmScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeletion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Get token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token == null) {
          setState(() {
            _errorMessage = 'Authentication error. Please login again.';
            _isLoading = false;
          });
          return;
        }
        
        // Make the API call to delete the account
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteAccount}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'password': _passwordController.text,
          }),
        );

        // Handle the response
        if (response.statusCode == 200) {
          // Success - navigate to success screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DeleteAccountSuccessScreen(),
              ),
            );
          }
        } else {
          // Error - display error message
          final errorData = jsonDecode(response.body);
          setState(() {
            _errorMessage = errorData['message'] ?? 'Failed to delete account. Please try again.';
            _isLoading = false;
          });
        }
      } catch (e) {
        // Handle network or other errors
        setState(() {
          _errorMessage = 'An error occurred. Please check your connection and try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).confirmDeletion,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 18, 
                tablet: 20, 
                desktop: 22,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.isTablet(context) 
                    ? MediaQuery.of(context).size.width * 0.6
                    : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
                    
                    // Security icon
                    Container(
                      padding: ResponsiveUtils.getResponsivePadding(context),
                      decoration: BoxDecoration(
                        color: const Color(0xfff29620).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: const Color(0xfff29620),
                        size: ResponsiveUtils.getResponsiveIconSize(context) * 2,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
                    
                    // Heading
                    Text(
                      AppLocalizations.of(context).securityVerification,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context, 
                          mobile: 20, 
                          tablet: 24, 
                          desktop: 28,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                    
                    // Description
                    Text(
                      AppLocalizations.of(context).securityPasswordPrompt,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context, 
                          mobile: 14, 
                          tablet: 16, 
                          desktop: 18,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
              
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).password,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            size: ResponsiveUtils.getResponsiveIconSize(context),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).pleaseEnterPassword;
                        }
                        return null;
                      },
                    ),
                    
                    // Error message
                    if (_errorMessage != null) ...[
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context, 
                            mobile: 12, 
                            tablet: 14, 
                            desktop: 16,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 2),
                    
                    // Buttons
                    ResponsiveUtils.isTablet(context) 
                        ? Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _confirmDeletion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: ResponsiveUtils.getResponsiveSpacing(context) * 1.2,
                                          width: ResponsiveUtils.getResponsiveSpacing(context) * 1.2,
                                          child: const CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          AppLocalizations.of(context).confirmDeletion,
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                              context, 
                                              mobile: 14, 
                                              tablet: 16, 
                                              desktop: 18,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                              
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).cancel,
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                                        context, 
                                        mobile: 14, 
                                        tablet: 16, 
                                        desktop: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _confirmDeletion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: ResponsiveUtils.getResponsiveSpacing(context) * 1.2,
                                          width: ResponsiveUtils.getResponsiveSpacing(context) * 1.2,
                                          child: const CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          AppLocalizations.of(context).confirmDeletion,
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                              context, 
                                              mobile: 14, 
                                              tablet: 16, 
                                              desktop: 18,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                              
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).cancel,
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                                        context, 
                                        mobile: 14, 
                                        tablet: 16, 
                                        desktop: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 