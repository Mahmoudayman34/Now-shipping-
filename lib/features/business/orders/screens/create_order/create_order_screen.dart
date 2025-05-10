import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/models/order_model.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import 'package:now_shipping/features/business/orders/widgets/additional_options_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/cash_collection_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/customer_section_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/delivery_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/delivery_fee_summary_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/exchange_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/return_details_widget.dart';
import 'package:now_shipping/features/business/orders/widgets/shipping_information_widget.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  final String? initialOrderId;
  final Map<String, dynamic>? initialCustomerData;
  final String? initialDeliveryType;
  final String? initialProductDescription;
  final int? initialNumberOfItems;
  final bool? initialAllowPackageInspection;
  final String? initialSpecialInstructions;
  final String? initialReferralNumber;

  const CreateOrderScreen({
    Key? key,
    this.isEditing = false,
    this.initialOrderId,
    this.initialCustomerData,
    this.initialDeliveryType,
    this.initialProductDescription,
    this.initialNumberOfItems,
    this.initialAllowPackageInspection,
    this.initialSpecialInstructions,
    this.initialReferralNumber,
  }) : super(key: key);

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize order with existing data if editing
    if (widget.isEditing) {
      final order = OrderModel(
        deliveryType: widget.initialDeliveryType,
        productDescription: widget.initialProductDescription,
        numberOfItems: widget.initialNumberOfItems,
        allowPackageInspection: widget.initialAllowPackageInspection,
        specialInstructions: widget.initialSpecialInstructions,
        referralNumber: widget.initialReferralNumber,
      );
      
      // Use Future.microtask to avoid setState during build
      Future.microtask(() {
        // Initialize order data in provider
        ref.read(orderModelProvider.notifier).setOrder(order);
        
        // Initialize customer data if provided
        if (widget.initialCustomerData != null) {
          ref.read(customerDataProvider.notifier).state = widget.initialCustomerData;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Get current order data from provider for UI decisions
    final order = ref.watch(orderModelProvider);
    final selectedDeliveryType = order.deliveryType ?? 'Deliver';
    
    // Update the app bar title based on editing mode
    String appBarTitle = widget.isEditing ? 'Edit Order' : 'Create New Order';
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          appBarTitle,
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
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                    title: const Text(
                    "Are you sure you want to exit?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2F2F2F),
                    ),
                    ),
                    titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 5), // Reduced bottom padding
                    content: const Text(
                    "Order data and updates won't be saved if you decided to exit",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff2F2F2F),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Reduced top padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  actions: <Widget>[
                    Container(
                      height: 1,
                      color: Colors.white54,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        Container(
                          width: 1,
                          height: 47,
                          color: Colors.white54,
                        ),
                        TextButton(
                          child: const Text(
                            "Exit",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.of(context).pop(); // Close the screen
                          },
                        ),
                      ],
                    ),
                  ],
                  actionsPadding: EdgeInsets.zero,
                );
              },
            );
          },
        ),
      ),
      body: Form(
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
                ShippingInformationWidget(isEditing: widget.isEditing),
                
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
                const DeliveryFeeSummaryWidget(),
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
          onPressed: () => _submitOrder(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF89C29),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.isEditing ? 'Update Order' : 'Confirm Order',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  void _submitOrder(BuildContext context) {
    // Validate form
    if (_formKey.currentState!.validate()) {
      // Get current order from provider
      final order = ref.read(orderModelProvider);
      
      // Process and submit the order - you would implement your API call or database save here
      // For now just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEditing ? 'Order updated successfully!' : 'Order created successfully!')),
      );
      
      Navigator.pop(context);
    }
  }
}
