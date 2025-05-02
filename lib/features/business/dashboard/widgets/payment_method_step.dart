import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this import for haptic feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/core/widgets/toast_.dart' show ToastService, ToastType;
import '../providers/profile_form_provider.dart';

class DashboardPaymentMethodStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  
  const DashboardPaymentMethodStep({
    super.key, 
    required this.onComplete,
    required this.onPrevious,
    this.formKey,
    this.onRegisterSave,
  });

  @override
  ConsumerState<DashboardPaymentMethodStep> createState() => _DashboardPaymentMethodStepState();
}

class _DashboardPaymentMethodStepState extends ConsumerState<DashboardPaymentMethodStep> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod;
  final paymentMethods = [
    {
      'id': 'instapay',
      'title': 'InstaPay',
      'icon': Icons.smartphone_outlined,
    },
    {
      'id': 'wallet',
      'title': 'Mobile Wallet',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'bank',
      'title': 'Bank Transfer',
      'icon': Icons.account_balance_outlined,
    },
  ];
  
  // Add controllers for payment method details
  final TextEditingController _ipaAddressController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  String? _selectedBank;
  
  // List of sample banks
  final List<String> banks = [
    'Bank A',
    'Bank B',
    'Bank C',
    'Bank D',
    'Bank E',
  ];
  
  @override
  void dispose() {
    _ipaAddressController.dispose();
    _mobileNumberController.dispose();
    _ibanController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
    
    // Register save callback
    if (widget.onRegisterSave != null) {
      widget.onRegisterSave!(_saveFormData);
    }
  }

  // Method to save current form data without validation
  void _saveFormData() {
    // Check if widget is still mounted before using ref
    if (!mounted) return;
    
    if (_selectedPaymentMethod != null) {
      // Create base form data with payment method
      Map<String, dynamic> formData = {
        'paymentMethod': _selectedPaymentMethod,
      };
      
      // Add specific payment method details based on selection
      switch (_selectedPaymentMethod) {
        case 'instapay':
          formData['ipaAddress'] = _ipaAddressController.text;
          break;
        case 'wallet':
          formData['mobileNumber'] = _mobileNumberController.text;
          break;
        case 'bank':
          formData['bankName'] = _selectedBank;
          formData['iban'] = _ibanController.text;
          formData['accountName'] = _accountNameController.text;
          break;
      }
      
      try {
        // Update the provider
        final currentData = ref.read(profileFormDataProvider);
        ref.read(profileFormDataProvider.notifier).state = {
          ...currentData,
          ...formData,
        };
        
        debugPrint('Payment method step data auto-saved');
      } catch (e) {
        // Silently catch errors related to ref after dispose
        debugPrint('Error while saving payment method data: $e');
      }
    }
  }

  void _loadExistingData() {
    final data = ref.read(profileFormDataProvider);
    
    // Load payment method selection
    if (data.containsKey('paymentMethod') && data['paymentMethod'] != null) {
      setState(() {
        _selectedPaymentMethod = data['paymentMethod'] as String;
      });
      
      // Load specific payment method details based on type
      switch (_selectedPaymentMethod) {
        case 'instapay':
          if (data.containsKey('ipaAddress')) {
            _ipaAddressController.text = data['ipaAddress'] ?? '';
          }
          break;
        case 'wallet':
          if (data.containsKey('mobileNumber')) {
            _mobileNumberController.text = data['mobileNumber'] ?? '';
          }
          break;
        case 'bank':
          if (data.containsKey('bankName')) {
            setState(() {
              _selectedBank = data['bankName'] as String?;
            });
          }
          if (data.containsKey('iban')) {
            _ibanController.text = data['iban'] ?? '';
          }
          if (data.containsKey('accountName')) {
            _accountNameController.text = data['accountName'] ?? '';
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: widget.formKey ?? _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your preferred payment option for checkout.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            // Payment method option cards
            Row(
              children: [
                Expanded(
                  child: _buildPaymentCard(
                    'instapay',
                    'InstaPay',
                    Icons.smartphone_outlined,
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildPaymentCard(
                    'wallet',
                    'Mobile Wallet',
                    Icons.account_balance_wallet_outlined,
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildPaymentCard(
                    'bank',
                    'Bank Transfer',
                    Icons.account_balance_outlined,
                    theme,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Animated container for the input fields
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              child: _selectedPaymentMethod == null
                ? SizedBox(
                    key: const ValueKey('empty'),
                    height: 20,
                    child: Center(
                      child: Text(
                        'Select a payment method to continue',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : Container(
                    key: ValueKey(_selectedPaymentMethod),
                    child: _selectedPaymentMethod == 'instapay'
                      ? _buildInstapayFields(theme)
                      : _selectedPaymentMethod == 'wallet'
                        ? _buildWalletFields(theme)
                        : _buildBankFields(theme),
                  ),
            ),

            const SizedBox(height: 40),

            // Navigation buttons
            Row(
              children: [
                // Back button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      // Save data before going back
                      _saveFormData();
                      widget.onPrevious();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Next button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(String id, String title, IconData icon, ThemeData theme) {
    final isSelected = _selectedPaymentMethod == id;
    const orangeColor = Colors.orange; // Define orange color
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
        // Add a small haptic feedback when selecting a card
        HapticFeedback.lightImpact();
        _saveFormData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? orangeColor : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1,
          ),
          color: isSelected ? orangeColor.withOpacity(0.08) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? orangeColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
              blurRadius: isSelected ? 8 : 4,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated scale effect for the icon when selected
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: isSelected ? 1.0 : 0.8),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? orangeColor.withOpacity(0.15)
                    : Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected ? orangeColor : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? orangeColor : Colors.black87,
              ),
            ),
            // Indication dot for selected item
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isSelected ? 8 : 0,
              width: isSelected ? 8 : 0,
              margin: EdgeInsets.only(top: isSelected ? 8 : 0),
              decoration: const BoxDecoration(
                color: orangeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstapayFields(ThemeData theme) {
    const orangeColor = Colors.orange; // Define orange color
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your IPA Address:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ipaAddressController,
          decoration: InputDecoration(
            hintText: 'Example: ABCD1234',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: orangeColor),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.smartphone, color: Colors.grey.shade500),
            focusColor: orangeColor,
          ),
          cursorColor: orangeColor,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your IPA address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWalletFields(ThemeData theme) {
    const orangeColor = Colors.orange; // Define orange color
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your Mobile Number:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _mobileNumberController,
          decoration: InputDecoration(
            hintText: 'Example: +201234567890',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: orangeColor),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.phone_android, color: Colors.grey.shade500),
            focusColor: orangeColor,
          ),
          cursorColor: orangeColor,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your mobile number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankFields(ThemeData theme) {
    const orangeColor = Colors.orange; // Define orange color
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Bank:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBank,
          decoration: InputDecoration(
            hintText: 'Choose your bank',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: orangeColor),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: orangeColor),
          isExpanded: true,
          dropdownColor: Colors.white,
          items: banks.map((String bank) {
            return DropdownMenuItem(
              value: bank,
              child: Text(bank),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBank = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your bank';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Enter your IBAN:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ibanController,
          decoration: InputDecoration(
            hintText: 'Example: EG12 3456 7890 1234 5678 90',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: orangeColor),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.account_balance, color: Colors.grey.shade500),
            focusColor: orangeColor,
          ),
          cursorColor: orangeColor,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your IBAN';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Enter your Account Name:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _accountNameController,
          decoration: InputDecoration(
            hintText: 'Example: John Doe',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: orangeColor),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: Icon(Icons.person, color: Colors.grey.shade500),
            focusColor: orangeColor,
          ),
          cursorColor: orangeColor,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your account name';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _submitForm() {
    if (_selectedPaymentMethod == null) {
      // Show error message if no payment method is selected
      ToastService.show(
        context, 
        'Please select a payment method',
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Save form data before proceeding
    _saveFormData();

    // Move to next step
    widget.onComplete();
  }
}