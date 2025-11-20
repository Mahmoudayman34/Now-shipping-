import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/screens/edit_order_screen.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/action_item.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/tracking_tab.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/details_tab.dart';
import 'package:now_shipping/features/business/orders/widgets/print_selection_dialog.dart';
import 'package:now_shipping/features/common/widgets/scanner_modal.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_dialog.dart';

class OrderDetailsScreenRefactored extends ConsumerStatefulWidget {
  final String orderId;
  final String status;
  final int initialTabIndex;

  const OrderDetailsScreenRefactored({
    super.key,
    required this.orderId,
    required this.status,
    this.initialTabIndex = 0, // Default to tracking tab (index 0)
  });

  @override
  ConsumerState<OrderDetailsScreenRefactored> createState() => _OrderDetailsScreenRefactoredState();
}

class _OrderDetailsScreenRefactoredState extends ConsumerState<OrderDetailsScreenRefactored> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    // Initialize the tab controller with the provided initial tab index
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTabIndex
    );
    
    // Fetch order details when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderDetailsProvider(widget.orderId).notifier).fetchOrderDetails(
        widget.orderId, 
        widget.status
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to show the order actions bottom sheet
  void _showActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(  
          child: Column(
            
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ActionItem(
                icon: Icons.qr_code_scanner_outlined,
                title: AppLocalizations.of(context).scanSmartSticker,
                onTap: () {
                  Navigator.pop(context);
                  _scanBarcode();
                },
              ),
              ActionItem(
                icon: Icons.print_outlined,
                title: AppLocalizations.of(context).printAirwaybill,
                onTap: () {
                  Navigator.pop(context);
                  _showPrintOptions();
                },
              ),
              ActionItem(
                icon: Icons.edit_outlined,
                title: AppLocalizations.of(context).editOrder,
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditOrder();
                },
              ),
              ActionItem(
                icon: Icons.delete_outline,
                title: AppLocalizations.of(context).deleteOrder,
                titleColor: Colors.red,
                backgroundColor: const Color(0xFFFEE8E8),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  // Method to scan a barcode
  Future<void> _scanBarcode() async {
    try {
      // Show a modal dialog with the scanner
      final String? barcodeScanRes = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ScannerModal(
          title: 'Scan Smart Sticker',
          onScanResult: (result) {
            Navigator.pop(context, result);
          },
        ),
      );

      if (barcodeScanRes != null && barcodeScanRes.isNotEmpty) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scanning smart sticker...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }

        try {
          // Call the API to scan the smart sticker
          await ref.read(orderDetailsProvider(widget.orderId).notifier).updateWithStickerInfo(barcodeScanRes);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Smart sticker scanned successfully: $barcodeScanRes'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          print('Error scanning smart sticker: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to scan smart sticker: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error in scan barcode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open scanner'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to navigate to edit order screen
  void _navigateToEditOrder() {
    final orderDetails = ref.read(orderDetailsProvider(widget.orderId));
    if (orderDetails == null) return;
    
    // Prepare customer data in the format expected by EditOrderScreen
    // Extract complete address details to match edit order format
    final addressParts = orderDetails.customerAddress.split(',');
    
    Map<String, dynamic> customerData = {
      'name': orderDetails.customerName,
      'phoneNumber': orderDetails.customerPhone,
      'addressDetails': orderDetails.customerAddress,
      'city': addressParts.isNotEmpty ? addressParts[0].trim() : '',
      'building': addressParts.length > 1 ? addressParts[1].trim() : '',
      'floor': addressParts.length > 2 ? addressParts[2].trim() : '',
      'apartment': addressParts.length > 3 ? addressParts[3].trim() : '',
    };

    // Navigate to EditOrderScreen with the order data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderScreen(
          orderId: widget.orderId,
          initialCustomerData: customerData,
          initialDeliveryType: orderDetails.deliveryType,
          initialProductDescription: orderDetails.packageDescription,
          initialNumberOfItems: orderDetails.numberOfItems,
          initialAllowPackageInspection: orderDetails.allowOpeningPackage,
          initialSpecialInstructions: orderDetails.deliveryNotes,
          initialReferralNumber: orderDetails.orderReference,
        ),
      ),
    );
  }
  
  // Method to show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    AppDialog.show(
      context,
      title: 'Delete Order',
      message: 'Are you sure you want to delete this order? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    ).then((confirmed) {
      if (confirmed == true) {
        // Implementation for deleting order
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  // Show print options dialog
  void _showPrintOptions() {
    showDialog(
      context: context,
      builder: (context) => PrintSelectionDialog(
        orderId: widget.orderId,
        onPrintSelected: (paperSize) {
          // Handle printing with the selected paper size
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Printing $paperSize airwaybill for order #${widget.orderId}'),
              backgroundColor: Colors.green,
            ),
          );
          // Here you would integrate with your actual printing service
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '${AppLocalizations.of(context).orderNumber}${widget.orderId}',
            style: TextStyle(
              color: const Color(0xFF2F2F2F),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 16, 
                tablet: 18, 
                desktop: 20,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new, 
              color: const Color(0xFF2F2F2F),
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.more_vert, color: Color(0xFF2F2F2F)),
          //     onPressed: () => _showActionsBottomSheet(context),
          //   ),
          // ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF26A2B9),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF26A2B9),
            labelStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 14, 
                tablet: 16, 
                desktop: 18,
              ),
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 14, 
                tablet: 16, 
                desktop: 18,
              ),
            ),
            tabs: [
              Tab(text: AppLocalizations.of(context).tracking),
              Tab(text: AppLocalizations.of(context).orderDetails),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tracking Tab
            TrackingTab(
              orderId: widget.orderId,
              status: widget.status,
            ),
            
            // Details Tab
            DetailsTab(
              orderId: widget.orderId,
              onScanSticker: _scanBarcode,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'order_details_fab',
          backgroundColor: const Color(0xfff29620),
          onPressed: () => _showActionsBottomSheet(context),
          child: Icon(
            Icons.menu, 
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context),
          ),
        ),
      ),
    );
  }
}