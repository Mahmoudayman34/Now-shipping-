import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';

class ExchangeDetailsWidget extends ConsumerStatefulWidget {
  const ExchangeDetailsWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ExchangeDetailsWidget> createState() => _ExchangeDetailsWidgetState();
}

class _ExchangeDetailsWidgetState extends ConsumerState<ExchangeDetailsWidget> {
  late TextEditingController _currentProductDescriptionController;
  late TextEditingController _newProductDescriptionController;

  @override
  void initState() {
    super.initState();
    _currentProductDescriptionController = TextEditingController();
    _newProductDescriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with values from provider
    final order = ref.read(orderModelProvider);
    if (order.productDescription != null && _currentProductDescriptionController.text.isEmpty) {
      _currentProductDescriptionController.text = order.productDescription!;
    }
  }

  @override
  void dispose() {
    _currentProductDescriptionController.dispose();
    _newProductDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderModelProvider);
    final numberOfCurrentItems = order.numberOfItems ?? 1;
    final numberOfNewItems = order.numberOfNewItems ?? 1;

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
                'Number of Current Items',
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
        ],
      ),
    );
  }
}