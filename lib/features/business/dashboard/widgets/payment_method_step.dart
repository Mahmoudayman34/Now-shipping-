import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this import for haptic feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/core/widgets/toast_.dart' show ToastService, ToastType;
import '../providers/profile_form_provider.dart';

class DashboardPaymentMethodStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final GlobalKey<FormState>? formKey;
  final Function(Function)? onRegisterSave;
  final Color themeColor;
  
  const DashboardPaymentMethodStep({
    super.key, 
    required this.onComplete,
    required this.onPrevious,
    this.formKey,
    this.onRegisterSave,
    this.themeColor = Colors.blue, // Default to blue if not provided
  });

  @override
  ConsumerState<DashboardPaymentMethodStep> createState() => _DashboardPaymentMethodStepState();
}

class _DashboardPaymentMethodStepState extends ConsumerState<DashboardPaymentMethodStep> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod;
  final paymentMethods = [
    {
      'id': 'bank',
      'title': 'Bank Transfer',
      'icon': Icons.account_balance_outlined,
    },
  ];
  
  // Add controllers for payment method details
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  String? _selectedBank;
  
  // List of available banks with value and label
  final List<Map<String, String>> banks = [
    {"value": "nbe", "label": "National Bank of Egypt / البنك الأهلي المصري"},
    {"value": "banque-misr", "label": "Banque Misr / بنك مصر"},
    {"value": "cib", "label": "CIB (Commercial International Bank) / البنك التجاري الدولي"},
    {"value": "qnb", "label": "QNB Alahli / QNB الأهلي"},
    {"value": "aaib", "label": "Arab African International Bank (AAIB) / البنك العربي الأفريقي الدولي"},
    {"value": "adib", "label": "Abu Dhabi Islamic Bank - Egypt (ADIB) / بنك أبوظبي الإسلامي - مصر"},
    {"value": "abk", "label": "Al Ahli Bank of Kuwait - Egypt (ABK) / بنك الأهلي الكويتي - مصر"},
    {"value": "aib", "label": "Arab Investment Bank (AIB) / البنك العربي للاستثمار"},
    {"value": "attijariwafa", "label": "Attijariwafa Bank Egypt / بنك التجاري وفا مصر"},
    {"value": "bank-of-alexandria", "label": "Bank of Alexandria / بنك الإسكندرية"},
    {"value": "bank-audi", "label": "Bank Audi - Egypt / بنك عوده - مصر"},
    {"value": "banque-du-caire", "label": "Banque du Caire / بنك القاهرة"},
    {"value": "blom", "label": "BLOM Bank Egypt / بنك بلوم مصر"},
    {"value": "credit-agricole", "label": "Crédit Agricole Egypt / كريديت أجريكول مصر"},
    {"value": "egb", "label": "Egyptian Gulf Bank (EGB) / البنك المصري الخليجي"},
    {"value": "emirates-nbd", "label": "Emirates NBD Egypt / بنك الإمارات دبي الوطني مصر"},
    {"value": "ebbe", "label": "Export Development Bank of Egypt (EBBE) / بنك تنمية الصادرات"},
    {"value": "fab", "label": "First Abu Dhabi Bank Egypt (FAB) / بنك أبوظبي الأول مصر"},
    {"value": "faisal-islamic", "label": "Faisal Islamic Bank of Egypt / بنك فيصل الإسلامي المصري"},
    {"value": "hdb", "label": "Housing and Development Bank (HDB) / بنك الإسكان والتنمية"},
    {"value": "hsbc", "label": "HSBC Bank Egypt / بنك HSBC مصر"},
    {"value": "idb", "label": "Industrial Development Bank (IDB) / بنك التنمية الصناعية"},
    {"value": "nbk", "label": "National Bank of Kuwait - Egypt (NBK) / البنك الوطني الكويتي - مصر"},
    {"value": "saib", "label": "SAIB Bank / بنك SAIB"},
    {"value": "united-bank", "label": "United Bank of Egypt / البنك المتحد"},
    {"value": "alexbank", "label": "Bank of Alexandria (AlexBank) / بنك الإسكندرية (أليكس بنك)"},
    {"value": "al-baraka", "label": "Al Baraka Bank Egypt / بنك البركة مصر"},
    {"value": "adcb", "label": "Abu Dhabi Commercial Bank Egypt (ADCB) / بنك أبوظبي التجاري مصر"},
    {"value": "suez-canal-bank", "label": "Suez Canal Bank / بنك قناة السويس"},
    {"value": "mashreq", "label": "Mashreq Bank Egypt / بنك المشرق مصر"},
    {"value": "bank-ei", "label": "Bank of Egypt International (BEI) / بنك مصر الدولي"},
  ];
  
  @override
  void dispose() {
    _ibanController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Auto-select bank transfer as it's the only option
    _selectedPaymentMethod = 'bank';
    
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
      // Ensure bank is selected if no existing data
      if (_selectedPaymentMethod == null) {
        setState(() {
          _selectedPaymentMethod = 'bank';
        });
      }
      _saveFormData();
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
      if (_selectedPaymentMethod == 'bank') {
        formData['bankName'] = _selectedBank;
        formData['iban'] = _ibanController.text;
        formData['accountName'] = _accountNameController.text;
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
      if (_selectedPaymentMethod == 'bank') {
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
                color: Color(0xffF29620),
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
            Center(
              child: SizedBox(
                width: 200,
                child: _buildPaymentCard(
                  'bank',
                  'Bank Transfer',
                  Icons.account_balance_outlined,
                  theme,
                ),
              ),
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
                    child: _buildBankFields(theme),
                  ),
            ),

            const SizedBox(height: 40),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                                        style: OutlinedButton.styleFrom(
                      foregroundColor: widget.themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: widget.themeColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back',
                    style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _validateAndContinue,
                     style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Next',
                     style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,),
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
          items: banks.map((Map<String, String> bank) {
            return DropdownMenuItem(
              value: bank['value'],
              child: Text(
                bank['label'] ?? '',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBank = newValue;
            });
            _saveFormData();
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

  void _validateAndContinue() {
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