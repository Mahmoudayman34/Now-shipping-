import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';

class CashCollectionDetailsWidget extends ConsumerStatefulWidget {
  const CashCollectionDetailsWidget({super.key});

  @override
  ConsumerState<CashCollectionDetailsWidget> createState() => _CashCollectionDetailsWidgetState();
}

class _CashCollectionDetailsWidgetState extends ConsumerState<CashCollectionDetailsWidget> {
  late TextEditingController _amountToCollectController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountToCollectController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final order = ref.read(orderModelProvider);
    if (order.amountToCollect != null && _amountToCollectController.text.isEmpty) {
      _amountToCollectController.text = order.amountToCollect!;
    }
  }

  // Validates the amount for the cash collection
  bool validateAndSaveAmount() {
    if (_formKey.currentState?.validate() == true) {
      final amount = _amountToCollectController.text.trim();
      if (amount.isNotEmpty && int.tryParse(amount) != null) {
        ref.read(orderModelProvider.notifier).updateCashCollectionDetails(amount);
        print('DEBUG CASH COLLECTION: Amount validated and saved: $amount');
        return true;
      } else {
        print('DEBUG CASH COLLECTION: Invalid amount: $amount');
        return false;
      }
    }
    return false;
  }

  @override
  void dispose() {
    // Ensure amount is validated before disposing
    validateAndSaveAmount();
    _amountToCollectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cash Collection Details Header
          const Text(
            'Cash Collection Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Amount to Collect
          const Text(
            'Amount to Collect',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Amount to Collect TextField
          TextFormField(
            controller: _amountToCollectController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
                // Only update if it's a valid number
                if (value.isEmpty || int.tryParse(value) != null) {
              ref.read(orderModelProvider.notifier).updateCashCollectionDetails(value);
                  print('DEBUG CASH COLLECTION: Amount updated to: $value');
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  print('DEBUG CASH COLLECTION: Empty amount validation error');
                  return 'Please enter an amount';
                }
                if (int.tryParse(value) == null) {
                  print('DEBUG CASH COLLECTION: Invalid number validation error');
                  return 'Please enter a valid number';
                }
                if (int.parse(value) <= 0) {
                  print('DEBUG CASH COLLECTION: Zero/negative amount validation error');
                  return 'Amount must be greater than zero';
                }
                return null;
              },
              inputFormatters: [
                // Allow only digits (whole numbers)
                FilteringTextInputFormatter.digitsOnly,
              ],
            decoration: InputDecoration(
              hintText: 'Enter the amount to collect in EGP',
                prefixText: 'EGP ',
                prefixStyle: const TextStyle(color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF89C29)),
                ),
              ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Enter whole numbers only (no decimal points)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
            ),
          ),
        ],
        ),
      ),
    );
  }
}