import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';

class DeliveryDetailsWidget extends ConsumerStatefulWidget {
  const DeliveryDetailsWidget({super.key});

  @override
  ConsumerState<DeliveryDetailsWidget> createState() => _DeliveryDetailsWidgetState();
}

class _DeliveryDetailsWidgetState extends ConsumerState<DeliveryDetailsWidget> {
  late TextEditingController _productDescriptionController;
  late TextEditingController _cashOnDeliveryAmountController;
  
  @override
  void initState() {
    super.initState();
    _productDescriptionController = TextEditingController();
    _cashOnDeliveryAmountController = TextEditingController();
  }
    @override
  void dispose() {
    _productDescriptionController.dispose();
    _cashOnDeliveryAmountController.dispose();
    super.dispose();
  }
    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with values from provider
    final order = ref.read(orderModelProvider);
    if (order.productDescription != null && _productDescriptionController.text.isEmpty) {
      _productDescriptionController.text = order.productDescription!;
    }
    if (order.cashOnDeliveryAmount != null && _cashOnDeliveryAmountController.text.isEmpty) {
      _cashOnDeliveryAmountController.text = order.cashOnDeliveryAmount!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderModelProvider);
    final numberOfItems = order.numberOfItems ?? 1;
    final cashOnDelivery = order.cashOnDelivery ?? false;

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
          // Delivery Details
          const Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Product Description
          const Text(
            'Product Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Product Description TextField
          TextFormField(
            controller: _productDescriptionController,
            maxLines: 4,
            onChanged: (value) {
              ref.read(orderModelProvider.notifier).updateDeliveryDetails(
                productDescription: value,
              );
            },
            decoration: InputDecoration(
              hintText: 'Describe the products being delivered',
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
          
          // Number of Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Number of Items',
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
                      if (numberOfItems > 1) {
                        ref.read(orderModelProvider.notifier).updateDeliveryDetails(
                          numberOfItems: numberOfItems - 1,
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
                      '$numberOfItems',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Plus button
                  InkWell(
                    onTap: () {
                      ref.read(orderModelProvider.notifier).updateDeliveryDetails(
                        numberOfItems: numberOfItems + 1,
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
            // Cash on Delivery
          Row(  
            children: [
              Checkbox(
                value: cashOnDelivery,
                onChanged: (value) {
                  ref.read(orderModelProvider.notifier).updateDeliveryDetails(
                    cashOnDelivery: value,
                  );
                },
                activeColor: Colors.orange.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              const Text(
                'Cash on Delivery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
            ],
          ),
          
          // Cash on Delivery Amount Field - only visible when cashOnDelivery is true
          if (cashOnDelivery) ...[
            const SizedBox(height: 12),
            const Text(
              'Cash on Delivery Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff2F2F2F),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cashOnDeliveryAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                ref.read(orderModelProvider.notifier).updateDeliveryDetails(
                  cashOnDeliveryAmount: value,
                );
              },
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixText: 'EGP ',
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
        ],
      ),
    );
  }
}