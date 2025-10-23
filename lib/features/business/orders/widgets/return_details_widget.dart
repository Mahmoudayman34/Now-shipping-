import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';

class ReturnDetailsWidget extends ConsumerStatefulWidget {
  const ReturnDetailsWidget({super.key});

  @override
  ConsumerState<ReturnDetailsWidget> createState() => _ReturnDetailsWidgetState();
}

class _ReturnDetailsWidgetState extends ConsumerState<ReturnDetailsWidget> {
  late TextEditingController _originalOrderNumberController;
  late TextEditingController _returnReasonController;
  bool _isLoadingOriginalOrder = false;
  bool _originalOrderFound = false;
  String? _errorMessage;
  
  // Mock data for simulation
  Map<String, dynamic>? _simulatedOriginalOrder;

  @override
  void initState() {
    super.initState();
    _originalOrderNumberController = TextEditingController();
    _returnReasonController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with values from provider if available
    final order = ref.read(orderModelProvider);
    if (order.originalOrderNumber != null && _originalOrderNumberController.text.isEmpty) {
      _originalOrderNumberController.text = order.originalOrderNumber!;
      if (order.originalOrderData != null) {
        _simulatedOriginalOrder = order.originalOrderData;
        _originalOrderFound = true;
      }
    }
    if (order.returnReason != null && _returnReasonController.text.isEmpty) {
      _returnReasonController.text = order.returnReason!;
    }
  }

  // Fetch original order details from API
  Future<void> _fetchOriginalOrder() async {
    final orderNumber = _originalOrderNumberController.text.trim();
    
    if (orderNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an order number';
      });
      return;
    }

    setState(() {
      _isLoadingOriginalOrder = true;
      _errorMessage = null;
      _originalOrderFound = false;
    });

    try {
      // Call API to validate original order
      final orderService = ref.read(orderServiceProvider);
      final response = await orderService.validateOriginalOrder(orderNumber);
      
      print('DEBUG: Validate original order response: $response');
      
      // Check if response is successful
      if (response['success'] == true && response['order'] != null) {
        // Extract order data from response
        _simulatedOriginalOrder = response['order'];
        
        // Get number of items to determine return type
        final orderShipping = _simulatedOriginalOrder!['orderShipping'] as Map<String, dynamic>? ?? {};
        final numberOfItems = orderShipping['numberOfItems'] as int? ?? 0;
        
        // Update provider with the original order data
        // If only 1 item, automatically select full return
        ref.read(orderModelProvider.notifier).updateReturnDetails(
          originalOrderNumber: orderNumber,
          originalOrderData: _simulatedOriginalOrder,
          returnType: numberOfItems <= 1 ? 'full' : null,
          numberOfItemsToReturn: numberOfItems <= 1 ? numberOfItems : null,
          numberOfReturnItems: numberOfItems <= 1 ? numberOfItems : null,
        );
        
        setState(() {
          _originalOrderFound = true;
          _isLoadingOriginalOrder = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Order not found. Please check the order number.';
          _isLoadingOriginalOrder = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error validating original order: $e');
      
      // Extract error message
      String errorMessage = 'Error fetching order';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      } else {
        errorMessage = e.toString();
      }
      
      setState(() {
        _errorMessage = errorMessage;
        _isLoadingOriginalOrder = false;
      });
    }
  }

  Widget _buildOriginalOrderSection() {
    if (_simulatedOriginalOrder == null) return const SizedBox.shrink();

    final orderCustomer = _simulatedOriginalOrder!['orderCustomer'] as Map<String, dynamic>? ?? {};
    final orderShipping = _simulatedOriginalOrder!['orderShipping'] as Map<String, dynamic>? ?? {};
    
    final orderNumber = _simulatedOriginalOrder!['orderNumber'] as String? ?? 'N/A';
    final customerName = orderCustomer['fullName'] as String? ?? 'N/A';
    final status = _simulatedOriginalOrder!['orderStatus'] as String? ?? 'N/A';
    final productDescription = orderShipping['productDescription'] as String? ?? 'N/A';
    final numberOfItems = orderShipping['numberOfItems'] as int? ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Original Order Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // Order details in a grid
          _buildReadOnlyField('Order Number', orderNumber),
          const SizedBox(height: 8),
          _buildReadOnlyField('Customer', customerName),
          const SizedBox(height: 8),
          _buildReadOnlyField('Status', status),
          const SizedBox(height: 8),
          _buildReadOnlyField('Product', productDescription),
          const SizedBox(height: 8),
          _buildReadOnlyField('No. of Items', numberOfItems.toString()),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff2F2F2F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReturnTypeSection() {
    final order = ref.watch(orderModelProvider);
    final selectedReturnType = order.returnType;
    final originalNumberOfItems = _simulatedOriginalOrder?['orderShipping']?['numberOfItems'] as int? ?? 0;
    final numberOfItemsToReturn = order.numberOfItemsToReturn ?? 1;
    
    // Disable partial return if there's only 1 item
    final canSelectPartial = originalNumberOfItems > 1;

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
          const Text(
            'Return Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Full Return Option
          InkWell(
            onTap: () {
              ref.read(orderModelProvider.notifier).updateReturnDetails(
                returnType: 'full',
                numberOfItemsToReturn: originalNumberOfItems,
                numberOfReturnItems: originalNumberOfItems,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedReturnType == 'full' 
                    ? Colors.orange.shade50 
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedReturnType == 'full' 
                      ? Colors.orange.shade300 
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedReturnType == 'full' 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                    color: selectedReturnType == 'full' 
                        ? Colors.orange.shade700 
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Return',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Return all $originalNumberOfItems items',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Partial Return Option (disabled if only 1 item)
          Opacity(
            opacity: canSelectPartial ? 1.0 : 0.5,
            child: InkWell(
              onTap: canSelectPartial ? () {
                ref.read(orderModelProvider.notifier).updateReturnDetails(
                  returnType: 'partial',
                  numberOfItemsToReturn: 1,
                  numberOfReturnItems: 1,
                );
              } : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedReturnType == 'partial' 
                      ? Colors.orange.shade50 
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedReturnType == 'partial' 
                        ? Colors.orange.shade300 
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                  Row(
                    children: [
                      Icon(
                        selectedReturnType == 'partial' 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                        color: selectedReturnType == 'partial' 
                            ? Colors.orange.shade700 
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Partial Return',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Show item counter for partial return
                  if (selectedReturnType == 'partial') ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items to Return',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            // Minus button
                            InkWell(
                              onTap: () {
                                if (numberOfItemsToReturn > 1) {
                                  ref.read(orderModelProvider.notifier).updateReturnDetails(
                                    numberOfItemsToReturn: numberOfItemsToReturn - 1,
                                    numberOfReturnItems: numberOfItemsToReturn - 1,
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
                                '$numberOfItemsToReturn',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            
                            // Plus button
                            InkWell(
                              onTap: () {
                                // Maximum is originalNumberOfItems - 1 (at least 1 must remain)
                                if (numberOfItemsToReturn < originalNumberOfItems - 1) {
    ref.read(orderModelProvider.notifier).updateReturnDetails(
                                    numberOfItemsToReturn: numberOfItemsToReturn + 1,
                                    numberOfReturnItems: numberOfItemsToReturn + 1,
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
                                child: const Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Show remaining items
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, 
                              color: Colors.green.shade700, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Remaining items: ${originalNumberOfItems - numberOfItemsToReturn}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ),
          
          // Info message if only 1 item
          if (!canSelectPartial) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Only 1 item in original order. Full return is required.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _originalOrderNumberController.dispose();
    _returnReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderModelProvider);

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
          
          // Original Order Number Input
          const Text(
            'Original Order Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _originalOrderNumberController,
                  enabled: !_originalOrderFound,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
            decoration: InputDecoration(
                    hintText: 'Enter original order number (e.g., 123456)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade400),
              ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    filled: _originalOrderFound,
                    fillColor: _originalOrderFound ? Colors.grey.shade100 : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the original order number';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Search/Reset Button
              ElevatedButton(
                onPressed: _isLoadingOriginalOrder 
                    ? null 
                    : (_originalOrderFound 
                        ? () {
                            setState(() {
                              _originalOrderFound = false;
                              _simulatedOriginalOrder = null;
                              _errorMessage = null;
                              _originalOrderNumberController.clear();
                            });
                            ref.read(orderModelProvider.notifier).updateReturnDetails(
                              originalOrderNumber: '',
                              originalOrderData: null,
                              returnType: null,
                              numberOfItemsToReturn: null,
                            );
                          }
                        : _fetchOriginalOrder),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _originalOrderFound 
                      ? Colors.red.shade400 
                      : Colors.orange.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoadingOriginalOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _originalOrderFound ? Icons.refresh : Icons.search,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
          
          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
                  Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Show original order details if found
          if (_originalOrderFound) ...[
            const SizedBox(height: 16),
            _buildOriginalOrderSection(),
            const SizedBox(height: 16),
            _buildReturnTypeSection(),
            const SizedBox(height: 16),
            
            // Return Reason (Optional)
                  Container(
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
                  Row(
                    children: [
                      const Text(
                        'Return Reason',
                        style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                          color: Color(0xff2F2F2F),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _returnReasonController,
                    maxLines: 3,
                    onChanged: (value) {
                      ref.read(orderModelProvider.notifier).updateReturnDetails(
                        returnReason: value,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g., Defective product, wrong size, customer changed mind...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              ),
            ],

          // Product Description Section
          const SizedBox(height: 16),
          
          Container(
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
                const Text(
                  'Product Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2F2F2F),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                TextFormField(
                  initialValue: order.productDescription,
                  maxLines: 3,
                  onChanged: (value) {
                    ref.read(orderModelProvider.notifier).updateReturnDetails(
                      productDescription: value,
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Describe the items being returned (e.g., Blue T-shirt, Size L, Wireless Headphones)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue.shade400),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          // Express Shipping (always visible)
          const SizedBox(height: 16),
          
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
