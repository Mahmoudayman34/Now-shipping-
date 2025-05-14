import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';

class ReturnDetailsWidget extends ConsumerStatefulWidget {
  const ReturnDetailsWidget({super.key});

  @override
  ConsumerState<ReturnDetailsWidget> createState() => _ReturnDetailsWidgetState();
}

class _ReturnDetailsWidgetState extends ConsumerState<ReturnDetailsWidget> {
  late TextEditingController _returnProductDescriptionController;

  @override
  void initState() {
    super.initState();
    _returnProductDescriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with values from provider
    final order = ref.read(orderModelProvider);
    if (order.productDescription != null && _returnProductDescriptionController.text.isEmpty) {
      _returnProductDescriptionController.text = order.productDescription!;
    }
    
    // Ensure numberOfItems is initialized for Return order
    if (order.numberOfItems == null || order.numberOfItems == 0) {
      // Set a default of 1 if not already set
      ref.read(orderModelProvider.notifier).updateDeliveryDetails(
        numberOfItems: 1,
      );
      print('DEBUG RETURN: Initialized numberOfItems to 1');
    }
  }

  // Validates the product description field
  bool validateProductDescription() {
    final description = _returnProductDescriptionController.text.trim();
    if (description.isEmpty) {
      print('DEBUG RETURN: Product description is empty');
      return false;
    }
    
    // Update the provider with validated description
    ref.read(orderModelProvider.notifier).updateReturnDetails(
      returnProductDescription: description,
    );
    print('DEBUG RETURN: Product description validated and saved: $description');
    return true;
  }

  @override
  void dispose() {
    // Ensure product description is validated before disposing
    validateProductDescription();
    _returnProductDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderModelProvider);
    final numberOfItems = order.numberOfItems ?? 1;

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
          // Return Details Header
          const Text(
            'Return Details',
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
            controller: _returnProductDescriptionController,
            maxLines: 4,
            onChanged: (value) {
              ref.read(orderModelProvider.notifier).updateReturnDetails(
                returnProductDescription: value,
              );
              print('DEBUG RETURN: Product description updated to: $value');
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                print('DEBUG RETURN: Product description validation error - empty');
                return 'Please enter a product description';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Describe the products being returned',
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
                        print('DEBUG RETURN: Decreased numberOfItems to ${numberOfItems - 1}');
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
                      print('DEBUG RETURN: Increased numberOfItems to ${numberOfItems + 1}');
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
          
          // Express Shipping Checkbox
          Row(
            children: [
              Checkbox(
                value: order.expressShipping ?? false,
                onChanged: (value) {
                  ref.read(orderModelProvider.notifier).updateReturnDetails(
                    expressShipping: value,
                  );
                },
                activeColor: Colors.orange.shade300,
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