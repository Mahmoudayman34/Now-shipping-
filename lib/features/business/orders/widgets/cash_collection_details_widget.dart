import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/orders/providers/order_providers.dart';

class CashCollectionDetailsWidget extends ConsumerStatefulWidget {
  const CashCollectionDetailsWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<CashCollectionDetailsWidget> createState() => _CashCollectionDetailsWidgetState();
}

class _CashCollectionDetailsWidgetState extends ConsumerState<CashCollectionDetailsWidget> {
  late TextEditingController _amountToCollectController;

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

  @override
  void dispose() {
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
              ref.read(orderModelProvider.notifier).updateCashCollectionDetails(value);
            },
            decoration: InputDecoration(
              hintText: 'Enter the amount to collect in EGP',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}