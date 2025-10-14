import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/l10n/app_localizations.dart';
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
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_dialog.dart';

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
    super.key,
    this.isEditing = false,
    this.initialOrderId,
    this.initialCustomerData,
    this.initialDeliveryType,
    this.initialProductDescription,
    this.initialNumberOfItems,
    this.initialAllowPackageInspection,
    this.initialSpecialInstructions,
    this.initialReferralNumber,
  });

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    
    // Use Future.microtask to avoid setState during build
    Future.microtask(() {
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
        
        // Initialize order data in provider
        ref.read(orderModelProvider.notifier).setOrder(order);
        
        // Initialize customer data if provided
        if (widget.initialCustomerData != null) {
          ref.read(customerDataProvider.notifier).state = widget.initialCustomerData;
        }
      } else {
        // If not editing, ensure we have clean state
        ref.read(orderModelProvider.notifier).resetOrder();
        ref.read(customerDataProvider.notifier).state = null;
        print('DEBUG CREATE: Reset order data when entering create order screen');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Get current order data from provider for UI decisions
    final order = ref.watch(orderModelProvider);
    final selectedDeliveryType = order.deliveryType ?? 'Deliver';
    
    // Set appropriate title based on editing mode
    final String appBarTitle = widget.isEditing ? AppLocalizations.of(context).editOrder : AppLocalizations.of(context).createNewOrder;
    
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            appBarTitle,
            style: TextStyle(
              color: const Color(0xff2F2F2F),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 16, 
                tablet: 18, 
                desktop: 20,
              ),
              fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close, 
              color: const Color(0xff2F2F2F),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
          onPressed: () {
            AppDialog.show(
              context,
              title: AppLocalizations.of(context).areYouSureExit,
              message: widget.isEditing 
                ? AppLocalizations.of(context).changesWontBeSaved
                : AppLocalizations.of(context).orderDataWontBeSaved,
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
        padding: ResponsiveUtils.getResponsivePadding(context),
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
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.getResponsiveSpacing(context),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
            ),
          ),
          child: Text(
            widget.isEditing ? AppLocalizations.of(context).saveChanges : AppLocalizations.of(context).confirmOrder,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.w500,
            ),
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
        
        // Extra validation for Cash Collection orders
        final orderType = orderData['orderType'] as String?;
        if (orderType == 'Cash Collection') {
          print('DEBUG ORDER SUBMIT: Cash Collection order detected');
          
          // Ensure amountCashCollection exists and is valid
          if (!orderData.containsKey('amountCashCollection') || 
              orderData['amountCashCollection'] == null || 
              orderData['amountCashCollection'] <= 0) {
            print('DEBUG ORDER SUBMIT: Invalid Cash Collection amount: ${orderData['amountCashCollection']}');
            
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
          
          print('DEBUG ORDER SUBMIT: Final Cash Collection data: $orderData');
        }
        // Validation for Return orders
        else if (orderType == 'Return') {
          print('DEBUG ORDER SUBMIT: Return order detected');
          
          // Ensure product description exists
          if (!orderData.containsKey('productDescription') || 
              orderData['productDescription'] == null || 
              orderData['productDescription'].toString().isEmpty) {
            print('DEBUG ORDER SUBMIT: Missing product description for Return order');
            
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
          if (!orderData.containsKey('numberOfItems') || 
              orderData['numberOfItems'] == null || 
              orderData['numberOfItems'] < 1) {
            print('DEBUG ORDER SUBMIT: Invalid number of items for Return order: ${orderData['numberOfItems']}');
            
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
          
          print('DEBUG ORDER SUBMIT: Final Return order data: $orderData');
        }
        
        print('DEBUG ORDER SUBMIT: Submitting order with data: $orderData');
        
        // Submit the order using provider
        final orderResult = await ref.read(
          orderSubmissionWithParamProvider(orderData).future
        );
        
        // Close loading indicator
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing 
              ? 'Changes saved successfully for Order #${orderResult.id}' 
              : 'Order created successfully with ID: ${orderResult.id}'
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form if not editing
        if (!widget.isEditing) {
          // Reset order data completely including customer data
          orderNotifier.resetOrder();
          
          // Clear customer data provider
          ref.read(customerDataProvider.notifier).state = null;
        }
        
        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        // Close loading indicator if showing
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        // Log detailed error
        print('DEBUG ORDER SUBMIT: Error submitting order: $e');
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.isEditing ? 'update' : 'create'} order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('DEBUG ORDER SUBMIT: Form validation failed');
    }
  }
}

