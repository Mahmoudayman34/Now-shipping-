import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:now_shipping/features/business/orders/models/order_model.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import 'package:now_shipping/features/business/orders/providers/orders_provider.dart';
import 'package:now_shipping/features/business/orders/widgets/additional_options_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/cash_collection_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/customer_section_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/delivery_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/edit_order_fee_summary_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/exchange_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/return_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/shipping_information_widget.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/app_dialog.dart';

// Provider for fetching order by ID
final getOrderByIdProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, orderId) async {
  final orderService = ref.watch(orderServiceProvider);
  print('DEBUG EDIT: Fetching fresh order data for ID: $orderId');
  return await orderService.getOrderDetails(orderId);
});

// Provider for updating an order
final updateOrderProvider = FutureProvider.family<OrderModel, Map<String, dynamic>>((ref, params) async {
  final orderService = ref.watch(orderServiceProvider);
  final orderId = params['orderId'] as String;
  final orderData = Map<String, dynamic>.from(params)..remove('orderId');
  return await orderService.updateOrder(orderId, orderData);
});

// Provider for calculating order fees
final calculateFeesProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final orderService = ref.watch(orderServiceProvider);
  final government = params['government'] as String;
  final orderType = params['orderType'] as String;
  final isExpressShipping = params['isExpressShipping'] as bool? ?? false;
  
  print('DEBUG FEE PROVIDER: Calculating fees with:');
  print('DEBUG FEE PROVIDER: government=$government');
  print('DEBUG FEE PROVIDER: orderType=$orderType');
  print('DEBUG FEE PROVIDER: isExpressShipping=$isExpressShipping');
  
  return await orderService.calculateOrderFees(government, orderType, isExpressShipping: isExpressShipping);
});

// Provider for delivery fee state to be used in the edit screen
final editOrderFeeProvider = StateProvider<double>((ref) => 0.0);

class EditOrderScreen extends ConsumerStatefulWidget {
  final String orderId;
  final Map<String, dynamic>? initialCustomerData;
  final String? initialDeliveryType;
  final String? initialProductDescription;
  final int? initialNumberOfItems;
  final bool? initialAllowPackageInspection;
  final String? initialSpecialInstructions;
  final String? initialReferralNumber;

  const EditOrderScreen({
    super.key,
    required this.orderId,
    this.initialCustomerData,
    this.initialDeliveryType,
    this.initialProductDescription,
    this.initialNumberOfItems,
    this.initialAllowPackageInspection,
    this.initialSpecialInstructions,
    this.initialReferralNumber,
  });

  @override
  ConsumerState<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends ConsumerState<EditOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }
  
  Future<void> _loadOrderData() async {
    try {
      // Fetch the order data using the provider and orderId
      final orderData = await ref.read(getOrderByIdProvider(widget.orderId).future);
      
      print('DEBUG EDIT: Order data received: $orderData');
      
      // Get delivery type and government for fee calculation
      String deliveryType = '';
      String government = '';
      bool expressShipping = false;
      
      // Extract shipping info
      if (orderData['orderShipping'] != null && orderData['orderShipping'] is Map<String, dynamic>) {
        final shipping = orderData['orderShipping'];
        deliveryType = shipping['orderType'] ?? widget.initialDeliveryType ?? 'Deliver';
        expressShipping = shipping['isExpressShipping'] == true;
      } else {
        deliveryType = orderData['deliveryType'] ?? widget.initialDeliveryType ?? 'Deliver';
        expressShipping = orderData['isExpressShipping'] == true;
      }
      
      // Extract government from customer data
      if (orderData['orderCustomer'] != null && orderData['orderCustomer'] is Map<String, dynamic>) {
        government = orderData['orderCustomer']['government'] ?? '';
      } else if (orderData['government'] != null) {
        government = orderData['government'];
      } else if (orderData['customerAddress'] != null) {
        String address = orderData['customerAddress'].toString();
        government = address.split(',').first.trim();
      }
      
      print('DEBUG EDIT: Extracted delivery type: $deliveryType, government: $government, express: $expressShipping');
      
      // Calculate fees if we have government
      if (government.isNotEmpty) {
        try {
          // Calculate fees using the provider
          final feeParams = {
            'government': government,
            'orderType': deliveryType,
            'isExpressShipping': expressShipping,
          };
          
          // Calculate fees immediately and wait for the result
          final fees = await ref.read(calculateFeesProvider(feeParams).future);
          print('DEBUG EDIT: Fees calculated: $fees');
          
          // Update the fee provider with calculated fee
          double calculatedFee = 0.0;
          if (fees.containsKey('fee')) {
            calculatedFee = (fees['fee'] as num).toDouble();
          } else if (fees.containsKey('fees')) {
            calculatedFee = (fees['fees'] as num).toDouble();
          } else if (fees.containsKey('deliveryFee')) {
            calculatedFee = (fees['deliveryFee'] as num).toDouble();
          } else if (orderData['orderFees'] != null) {
            calculatedFee = (orderData['orderFees'] as num).toDouble();
          }
          
          print('DEBUG EDIT: Setting fee to: $calculatedFee');
          ref.read(editOrderFeeProvider.notifier).state = calculatedFee;
        } catch (e) {
          print('DEBUG EDIT: Error calculating fees: $e');
          
          // If fee calculation fails, try to use the fee from the order data
          if (orderData['orderFees'] != null) {
            final orderFee = (orderData['orderFees'] as num).toDouble();
            ref.read(editOrderFeeProvider.notifier).state = orderFee;
            print('DEBUG EDIT: Using order fee from data: $orderFee');
          }
        }
      }
      
      // Extract product description and number of items
      String? productDescription;
      int? numberOfItems;
      bool cashOnDelivery = false;
      String? cashOnDeliveryAmount;
      
      if (orderData['orderShipping'] != null && orderData['orderShipping'] is Map<String, dynamic>) {
        final shipping = orderData['orderShipping'];
        productDescription = shipping['productDescription'];
        numberOfItems = shipping['numberOfItems'];
        
        // Extract cash on delivery info
        if (shipping['amountType'] == 'COD') {
          cashOnDelivery = true;
          cashOnDeliveryAmount = shipping['amount']?.toString();
        }
      } else {
        productDescription = orderData['productDescription'];
        numberOfItems = orderData['numberOfItems'];
        
        // Check for COD in main order data
        if (orderData['COD'] == true || orderData['cashOnDelivery'] == true) {
          cashOnDelivery = true;
          cashOnDeliveryAmount = orderData['amountCOD']?.toString() ?? 
                              orderData['cashOnDeliveryAmount']?.toString();
        }
      }
      
      print('DEBUG EDIT: Extracted product desc: $productDescription, items: $numberOfItems, COD: $cashOnDelivery, COD amount: $cashOnDeliveryAmount');
      
      // Extract special instructions and referral number
      String? specialInstructions;
      if (orderData['orderNotes'] != null) {
        specialInstructions = orderData['orderNotes'];
      } else if (orderData['Notes'] != null) {
        specialInstructions = orderData['Notes'];
      } else if (orderData['specialInstructions'] != null) {
        specialInstructions = orderData['specialInstructions'];
      }
      
      String? referralNumber = orderData['referralNumber'];
      
      print('DEBUG EDIT: Extracted special instructions: $specialInstructions, referral: $referralNumber');
      
      // Initialize order model with fetched data
      final order = OrderModel(
        id: orderData['_id'] ?? orderData['id'] ?? orderData['orderNumber'],
        customerName: _extractCustomerName(orderData),
        customerPhone: _extractCustomerPhone(orderData),
        customerAddress: _extractCustomerAddress(orderData),
        deliveryType: deliveryType,
        productDescription: productDescription ?? widget.initialProductDescription,
        numberOfItems: numberOfItems ?? widget.initialNumberOfItems ?? 1,
        allowPackageInspection: orderData['isOrderAvailableForPreview'] == true,
        specialInstructions: specialInstructions ?? widget.initialSpecialInstructions,
        referralNumber: referralNumber ?? widget.initialReferralNumber,
        cashOnDelivery: cashOnDelivery,
        cashOnDeliveryAmount: cashOnDeliveryAmount,
        expressShipping: expressShipping,
        status: orderData['orderStatus'] ?? orderData['status'],
        createdAt: orderData['orderDate'] != null ? 
                 DateTime.parse(orderData['orderDate']) : 
                 orderData['createdAt'] != null ? 
                 DateTime.parse(orderData['createdAt']) : 
                 DateTime.now(),
      );
      
      print('DEBUG EDIT: Created order model: ${order.toJson()}');
      
      // Set order data in provider
      ref.read(orderModelProvider.notifier).setOrder(order);
      
      // Set customer data
      Map<String, dynamic>? customerData = _extractCustomerData(orderData);
      if (customerData != null) {
        ref.read(customerDataProvider.notifier).state = customerData;
      } else if (widget.initialCustomerData != null) {
        ref.read(customerDataProvider.notifier).state = widget.initialCustomerData;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG EDIT: Error loading order data: $e');
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load order data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _recalculateFees(OrderModel order) {
    // Skip if we don't have required parameters
    final government = order.customerAddress?.split(',').first.trim();
    final orderType = order.deliveryType;
    final expressShipping = order.expressShipping ?? false;
    
    if (government == null || government.isEmpty || orderType == null || orderType.isEmpty) {
      print('DEBUG FEE: Missing required parameters for fee calculation');
      print('DEBUG FEE: government=$government, orderType=$orderType');
      return;
    }
    
    print('DEBUG FEE: Calculating fees with parameters:');
    print('DEBUG FEE: government=$government');
    print('DEBUG FEE: orderType=$orderType');
    print('DEBUG FEE: expressShipping=$expressShipping');
    
    // Set fee to calculating state by setting to 0
    ref.read(editOrderFeeProvider.notifier).state = 0.0;
    
    // Calculate fees
    try {
      final feeParams = {
        'government': government,
        'orderType': orderType,
        'isExpressShipping': expressShipping,
      };
      
      // Cancel any previous fee calculations
      ref.read(calculateFeesProvider(feeParams).future).then((fees) {
        print('DEBUG FEE: Fees recalculated: $fees');
        // Update the fee provider with calculated fee
        double calculatedFee = 0.0;
        if (fees.containsKey('fee')) {
          calculatedFee = (fees['fee'] as num).toDouble();
        } else if (fees.containsKey('fees')) {
          calculatedFee = (fees['fees'] as num).toDouble();
        } else if (fees.containsKey('deliveryFee')) {
          calculatedFee = (fees['deliveryFee'] as num).toDouble();
        }
        print('DEBUG FEE: Setting fee to: $calculatedFee');
        ref.read(editOrderFeeProvider.notifier).state = calculatedFee;
      }).catchError((e) {
        print('DEBUG FEE: Failed to recalculate fees: $e');
        
        // Set a default fee value to prevent UI showing "Calculating..."
        final defaultFee = _getDefaultFeeForGovernment(government);
        print('DEBUG FEE: Using default fee: $defaultFee');
        ref.read(editOrderFeeProvider.notifier).state = defaultFee;
      });
    } catch (e) {
      print('DEBUG FEE: Error recalculating fees: $e');
      // Set a default fee
      final defaultFee = _getDefaultFeeForGovernment(government);
      ref.read(editOrderFeeProvider.notifier).state = defaultFee;
    }
  }
  
  // Helper method to provide default fees when API fails
  double _getDefaultFeeForGovernment(String government) {
    // Default fees based on government
    final Map<String, double> defaultFees = {
      'Cairo': 80.0,
      'Giza': 100.0,
      'Alexandria': 120.0,
      // Add more default fees as needed
    };
    
    // Return the default fee or a general default if not found
    return defaultFees[government] ?? 80.0;
  }
  
  // Helper methods to extract data from the order details response
  String _extractCustomerName(Map<String, dynamic> orderData) {
    if (orderData['customer'] != null && orderData['customer'] is Map<String, dynamic>) {
      return orderData['customer']['name'] ?? '';
    } else if (orderData['orderCustomer'] != null && orderData['orderCustomer'] is Map<String, dynamic>) {
      return orderData['orderCustomer']['fullName'] ?? '';
    } else if (orderData['customerName'] != null) {
      return orderData['customerName'];
    }
    return '';
  }
  
  String _extractCustomerPhone(Map<String, dynamic> orderData) {
    if (orderData['customer'] != null && orderData['customer'] is Map<String, dynamic>) {
      return orderData['customer']['phoneNumber'] ?? '';
    } else if (orderData['orderCustomer'] != null && orderData['orderCustomer'] is Map<String, dynamic>) {
      return orderData['orderCustomer']['phoneNumber'] ?? '';
    } else if (orderData['customerPhone'] != null) {
      return orderData['customerPhone'];
    }
    return '';
  }
  
  String _extractCustomerAddress(Map<String, dynamic> orderData) {
    if (orderData['customer'] != null && orderData['customer'] is Map<String, dynamic>) {
      final city = orderData['customer']['city'] ?? '';
      final addressDetails = orderData['customer']['addressDetails'] ?? '';
      return '$city, $addressDetails';
    } else if (orderData['orderCustomer'] != null && orderData['orderCustomer'] is Map<String, dynamic>) {
      final government = orderData['orderCustomer']['government'] ?? '';
      final zone = orderData['orderCustomer']['zone'] ?? '';
      final address = orderData['orderCustomer']['address'] ?? '';
      return '$government, $zone, $address';
    } else if (orderData['customerAddress'] != null) {
      return orderData['customerAddress'];
    } else if (orderData['address'] != null) {
      return orderData['address'];
    }
    return '';
  }
  
  bool _extractAllowPackageInspection(Map<String, dynamic> orderData) {
    if (orderData['previewPermission'] != null) {
      return orderData['previewPermission'] == 'on';
    } else if (orderData['allowPackageInspection'] != null) {
      return orderData['allowPackageInspection'] == true;
    } else if (orderData['isOrderAvailableForPreview'] != null) {
      return orderData['isOrderAvailableForPreview'] == true;
    }
    return widget.initialAllowPackageInspection ?? false;
  }
  
  Map<String, dynamic>? _extractCustomerData(Map<String, dynamic> orderData) {
    // Prepare customer data for the provider
    try {
      if (orderData['customer'] != null && orderData['customer'] is Map<String, dynamic>) {
        return orderData['customer'] as Map<String, dynamic>;
      } else if (orderData['orderCustomer'] != null && orderData['orderCustomer'] is Map<String, dynamic>) {
        final customerData = orderData['orderCustomer'] as Map<String, dynamic>;
        
        // Parse address if it's a combined string
        String address = customerData['address'] ?? '';
        String zone = customerData['zone'] ?? '';
        String addressDetails = '';
        
        // Extract city and address details if zone is empty and address has city format
        if (zone.isEmpty && address.contains(',')) {
          List<String> parts = address.split(',');
          if (parts.length > 1) {
            // Keep the full address in addressDetails for display
            addressDetails = address.trim();
          } else {
            addressDetails = address.trim();
          }
        } else {
          addressDetails = zone.isNotEmpty ? zone : address;
        }
        
        return {
          'name': customerData['fullName'],
          'phoneNumber': customerData['phoneNumber'],
          'city': customerData['government'],
          'addressDetails': addressDetails,
          'building': customerData['building'] ?? '',
          'floor': customerData['floor'] ?? '',
          'apartment': customerData['apartment'] ?? '',
        };
      } else if (orderData.containsKey('customerName') && orderData.containsKey('customerPhone')) {
        String address = orderData['customerAddress'] ?? '';
        List<String> addressParts = address.split(',');
        String city = addressParts.isNotEmpty ? addressParts.first.trim() : '';
        String addressDetails = addressParts.length > 1 ? addressParts.sublist(1).join(',').trim() : '';
        
        return {
          'name': orderData['customerName'],
          'phoneNumber': orderData['customerPhone'],
          'city': city,
          'addressDetails': addressDetails,
          'building': '',
          'floor': '',
          'apartment': '',
        };
      }
    } catch (e) {
      print('DEBUG EDIT: Error extracting customer data: $e');
    }
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    // Get current order data from provider for UI decisions
    final order = ref.watch(orderModelProvider);
    final selectedDeliveryType = order.deliveryType ?? 'Deliver';
    
    // Listen for changes to order model that affect fees
    ref.listen<OrderModel>(orderModelProvider, (previous, current) {
      // Skip if nothing changed
      if (previous == current) return;
      
      // Only recalculate if parameters affecting fees changed
      if (previous?.customerAddress != current.customerAddress ||
          previous?.deliveryType != current.deliveryType ||
          previous?.expressShipping != current.expressShipping) {
        _recalculateFees(current);
      }
    });
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).editOrder,
          style: const TextStyle(
            color: Color(0xff2F2F2F),
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xff2F2F2F)),
          onPressed: () {
            AppDialog.show(
              context,
              title: AppLocalizations.of(context).areYouSureExit,
              message: AppLocalizations.of(context).changesWontBeSaved,
              confirmText: AppLocalizations.of(context).exit,
              cancelText: AppLocalizations.of(context).cancel,
              confirmColor: Colors.red,
            ).then((confirmed) {
              if (confirmed == true) {
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Section
                      const CustomerSectionWidget(),
                      
                      const SizedBox(height: 16),
                      
                      // Shipping Information Section with cards
                      const ShippingInformationWidget(isEditing: true),
                      
                      const SizedBox(height: 16),
                      
                      // Show order details based on selected delivery type
                      if (selectedDeliveryType == 'Deliver')
                        const DeliveryDetailsWidget(),
                        
                      if (selectedDeliveryType == 'Exchange')
                        const ExchangeDetailsWidget(),

                      if (selectedDeliveryType == 'Return')
                        const ReturnDetailsWidget(),
                        
                      if (selectedDeliveryType == 'Cash Collect')
                        const CashCollectionDetailsWidget(),
                      
                      const SizedBox(height: 16),
                      
                      // Additional Options Section
                      const AdditionalOptionsWidget(),
                      
                      const SizedBox(height: 16),
                      
                      // Delivery Fee Summary Section
                      const EditOrderFeeSummaryWidget(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _submitOrder(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF89C29),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            AppLocalizations.of(context).saveChanges,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  void _submitOrder(BuildContext context) async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        
        // Get current order from provider and convert to API format
        final orderNotifier = ref.read(orderModelProvider.notifier);
        final orderData = orderNotifier.toApiRequest();
        
        // Ensure we have all required fields in the correct format
        final Map<String, dynamic> finalOrderData = {
          ..._ensureRequiredFields(orderData),
        };
        
        print('DEBUG EDIT: Submitting data: $finalOrderData');
        
        // Get the MongoDB _id from the OrderModel
        final mongoId = ref.read(orderModelProvider).id;
        print('DEBUG EDIT: Using MongoDB _id for update: $mongoId');
        
        // Add order ID to the data for the provider 
        // (make sure we're using the MongoDB _id, not the order number)
        final params = {
          'orderId': mongoId,
          ...finalOrderData,
        };
        
        // Extra validation for Cash Collection orders
        final orderType = finalOrderData['orderType'] as String?;
        if (orderType == 'Cash Collection') {
          // Ensure amountCashCollection exists and is valid
          if (!finalOrderData.containsKey('amountCashCollection') || 
              finalOrderData['amountCashCollection'] == null || 
              finalOrderData['amountCashCollection'] <= 0) {
            
            // Close loading indicator
            Navigator.pop(context);
            
            // Show specific error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid amount for Cash Collection'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        // Validation for Return orders
        else if (orderType == 'Return') {
          // Ensure product description exists
          if (!finalOrderData.containsKey('productDescription') || 
              finalOrderData['productDescription'] == null || 
              finalOrderData['productDescription'].toString().isEmpty) {
            
            // Close loading indicator
            Navigator.pop(context);
            
            // Show specific error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a product description for the return'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          // Ensure number of items is valid
          if (!finalOrderData.containsKey('numberOfItems') || 
              finalOrderData['numberOfItems'] == null || 
              finalOrderData['numberOfItems'] < 1) {
            
            // Close loading indicator
            Navigator.pop(context);
            
            // Show specific error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please specify at least 1 item for the return'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        
        // Submit the updated order using provider
        final orderResult = await ref.read(
          updateOrderProvider(params).future
        );
        
        // Close loading indicator
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Changes saved successfully for Order #${orderResult.id}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Force refresh provider data to ensure it's up to date for next edit
        if (mongoId != null) {
          ref.invalidate(getOrderByIdProvider(mongoId));
        }
        
        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        // Close loading indicator if showing
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Helper method to ensure all required fields are present in the expected format
  Map<String, dynamic> _ensureRequiredFields(Map<String, dynamic> orderData) {
    final result = Map<String, dynamic>.from(orderData);
    
    // Properly handle previewPermission (keep any existing value from orderData)
    if (orderData.containsKey('previewPermission')) {
      // previewPermission already exists, keep it
    } else if (result.containsKey('allowPackageInspection')) {
      // Convert allowPackageInspection to previewPermission format
      result['previewPermission'] = result['allowPackageInspection'] == true ? 'on' : 'off';
      result.remove('allowPackageInspection');
    }
    
    // Ensure Notes is in the expected format (replace specialInstructions)
    if (result.containsKey('specialInstructions')) {
      result['Notes'] = result['specialInstructions'];
      result.remove('specialInstructions');
    }
    
    // Ensure COD and amountCOD are properly set
    if (result.containsKey('cashOnDelivery') && result['cashOnDelivery'] == true) {
      result['COD'] = true;
      
      if (result.containsKey('cashOnDeliveryAmount')) {
        // Convert to integer if it's a string
        if (result['cashOnDeliveryAmount'] is String) {
          final amount = int.tryParse(result['cashOnDeliveryAmount']) ?? 0;
          result['amountCOD'] = amount;
        } else {
          result['amountCOD'] = result['cashOnDeliveryAmount'];
        }
        result.remove('cashOnDeliveryAmount');
      }
      
      result.remove('cashOnDelivery');
    }
    
    // Handle Cash Collection type
    if (result['orderType'] == 'Cash Collect') {
      result['orderType'] = 'Cash Collection';
    }
    
    // Ensure numberOfItems is an integer
    if (result.containsKey('numberOfItems') && result['numberOfItems'] is String) {
      result['numberOfItems'] = int.tryParse(result['numberOfItems']) ?? 1;
    }
    
    // Ensure expressShipping is included and preserved
    // Note: Previously, this could overwrite existing expressShipping value
    
    // Ensure required fields for different order types
    if (result['orderType'] == 'Exchange') {
      // Set defaults for exchange fields if missing
      if (!result.containsKey('currentPD')) {
        result['currentPD'] = result['productDescription'] ?? '';
      }
      if (!result.containsKey('numberOfItemsCurrentPD')) {
        result['numberOfItemsCurrentPD'] = result['numberOfItems'] ?? 1;
      }
      if (!result.containsKey('newPD')) {
        result['newPD'] = '';
      }
      if (!result.containsKey('numberOfItemsNewPD')) {
        result['numberOfItemsNewPD'] = 1;
      }
    }
    
    return result;
  }
} 