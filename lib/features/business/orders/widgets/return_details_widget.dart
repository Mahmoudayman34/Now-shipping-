import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/orders/providers/order_providers.dart';

class ReturnDetailsWidget extends ConsumerStatefulWidget {
  const ReturnDetailsWidget({Key? key}) : super(key: key);

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
  }

  @override
  void dispose() {
    _returnProductDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderModelProvider);
    final numberOfReturnItems = order.numberOfReturnItems ?? 1;

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
                      if (numberOfReturnItems > 1) {
                        ref.read(orderModelProvider.notifier).updateReturnDetails(
                          numberOfReturnItems: numberOfReturnItems - 1,
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
                      '$numberOfReturnItems',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Plus button
                  InkWell(
                    onTap: () {
                      ref.read(orderModelProvider.notifier).updateReturnDetails(
                        numberOfReturnItems: numberOfReturnItems + 1,
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
        ],
      ),
    );
  }
}