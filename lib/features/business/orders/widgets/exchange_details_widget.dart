import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';

class ExchangeDetailsWidget extends ConsumerStatefulWidget {
  const ExchangeDetailsWidget({super.key});

  @override
  ConsumerState<ExchangeDetailsWidget> createState() => _ExchangeDetailsWidgetState();
}

class _ExchangeDetailsWidgetState extends ConsumerState<ExchangeDetailsWidget> {
  late TextEditingController _currentProductDescriptionController;
  late TextEditingController _newProductDescriptionController;
  late TextEditingController _cashDifferenceAmountController;

  @override
  void initState() {
    super.initState();
    _currentProductDescriptionController = TextEditingController();
    _newProductDescriptionController = TextEditingController();
    _cashDifferenceAmountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with values from provider
    final order = ref.read(orderModelProvider);
    if (order.productDescription != null && _currentProductDescriptionController.text.isEmpty) {
      _currentProductDescriptionController.text = order.productDescription!;
    }
    if (order.newProductDescription != null && _newProductDescriptionController.text.isEmpty) {
      _newProductDescriptionController.text = order.newProductDescription!;
    }
    if (order.cashDifferenceAmount != null && _cashDifferenceAmountController.text.isEmpty) {
      _cashDifferenceAmountController.text = order.cashDifferenceAmount!;
    }
  }

  @override
  void dispose() {
    _currentProductDescriptionController.dispose();
    _newProductDescriptionController.dispose();
    _cashDifferenceAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderModelProvider);
    final numberOfCurrentItems = order.numberOfItems ?? 1;
    final numberOfNewItems = order.numberOfNewItems ?? 1;
    final hasCashDifference = order.hasCashDifference ?? false;

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
          // Exchange Details
          const Text(
            'Exchange Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Current Product Description
          const Text(
            'Current Product Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Current Product Description TextField
          TextFormField(
            controller: _currentProductDescriptionController,
            maxLines: 4,
            onChanged: (value) {
              ref.read(orderModelProvider.notifier).updateExchangeDetails(
                currentProductDescription: value,
              );
            },
            decoration: InputDecoration(
              hintText: 'Describe the current products being exchanged',
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
          
          const SizedBox(height: 16),
          
          // Number of Current Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Number of Current \nItems',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
              Row(
                children: [
                  // Minus button
                  InkWell(
                    onTap: () {
                      if (numberOfCurrentItems > 1) {
                        ref.read(orderModelProvider.notifier).updateExchangeDetails(
                          numberOfCurrentItems: numberOfCurrentItems - 1,
                        );
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.remove, size: 16),
                    ),
                  ),
                  
                  // Item count
                  Container(
                    width: 50,
                    height: 30,
                    alignment: Alignment.center,
                    child: Text(
                      '$numberOfCurrentItems',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Plus button
                  InkWell(
                    onTap: () {
                      ref.read(orderModelProvider.notifier).updateExchangeDetails(
                        numberOfCurrentItems: numberOfCurrentItems + 1,
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // New Product Description
          const Text(
            'New Product Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // New Product Description TextField
          TextFormField(
            controller: _newProductDescriptionController,
            maxLines: 4,
            onChanged: (value) {
              ref.read(orderModelProvider.notifier).updateExchangeDetails(
                newProductDescription: value,
              );
            },
            decoration: InputDecoration(
              hintText: 'Describe the new products being exchanged',
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
          
          const SizedBox(height: 16),
          
          // Number of New Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Number of New Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
              Row(
                children: [
                  // Minus button
                  InkWell(
                    onTap: () {
                      if (numberOfNewItems > 1) {
                        ref.read(orderModelProvider.notifier).updateExchangeDetails(
                          numberOfNewItems: numberOfNewItems - 1,
                        );
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.remove, size: 16),
                    ),
                  ),
                  
                  // Item count
                  Container(
                    width: 50,
                    height: 30,
                    alignment: Alignment.center,
                    child: Text(
                      '$numberOfNewItems',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Plus button
                  InkWell(
                    onTap: () {
                      ref.read(orderModelProvider.notifier).updateExchangeDetails(
                        numberOfNewItems: numberOfNewItems + 1,
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Cash Difference Checkbox
          Row(
            children: [
              Checkbox(
                value: hasCashDifference,
                activeColor: const Color(0xfff29620),
                onChanged: (value) {
                  ref.read(orderModelProvider.notifier).updateExchangeDetails(
                    hasCashDifference: value,
                  );
                  if (value == false) {
                    _cashDifferenceAmountController.clear();
                    ref.read(orderModelProvider.notifier).updateExchangeDetails(
                      cashDifferenceAmount: null,
                    );
                  }
                },
              ),
              const Text(
                'Cash Difference',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
            ],
          ),
          
          // Cash Difference Amount TextField (only visible when checkbox is checked)
          if (hasCashDifference) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _cashDifferenceAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cash Difference Amount',
                labelStyle: const TextStyle(color: Color(0xff2F2F2F)),
                hintText: 'Enter amount',
                prefixText: 'EGP ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xfff29620)),
                ),
              ),
              onChanged: (value) {
                // Only allow numeric input
                if (value.isNotEmpty && double.tryParse(value) != null) {
                  ref.read(orderModelProvider.notifier).updateExchangeDetails(
                    cashDifferenceAmount: value,
                  );
                }
              },
              // Ensure only numbers are entered
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],

          const SizedBox(height: 16),
          
          // Express Shipping Checkbox
          Row(
            children: [
              Checkbox(
                value: order.expressShipping ?? false,
                onChanged: (value) {
                  ref.read(orderModelProvider.notifier).updateExchangeDetails(
                    expressShipping: value,
                  );
                },
                activeColor: const Color(0xfff29620),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Express Shipping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}