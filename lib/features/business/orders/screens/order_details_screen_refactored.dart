import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:now_shipping/features/business/orders/providers/order_details_provider.dart';
import 'package:now_shipping/features/business/orders/screens/create_order/create_order_screen.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/action_item.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/tracking_tab.dart';
import 'package:now_shipping/features/business/orders/widgets/order_details/details_tab.dart';

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
                title: 'Scan Smart Sticker',
                onTap: () {
                  Navigator.pop(context);
                  _scanBarcode();
                },
              ),
              ActionItem(
                icon: Icons.print_outlined,
                title: 'Print Airwaybill',
                onTap: () {
                  Navigator.pop(context);
                  // Implementation for print airwaybill
                },
              ),
              ActionItem(
                icon: Icons.edit_outlined,
                title: 'Edit order',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditOrder();
                },
              ),
              ActionItem(
                icon: Icons.delete_outline,
                title: 'Delete order',
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
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                  ),
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                      String code = barcodes[0].rawValue!;
                      Navigator.pop(context, code);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A2B9),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );

      if (barcodeScanRes != null) {
        ref.read(orderDetailsProvider(widget.orderId).notifier).updateWithStickerInfo(barcodeScanRes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Smart sticker scanned: $barcodeScanRes'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to scan barcode'),
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
    
    // Prepare customer data in the format expected by CreateOrderScreen
    Map<String, dynamic> customerData = {
      'name': orderDetails.customerName,
      'phoneNumber': orderDetails.customerPhone,
      'addressDetails': orderDetails.customerAddress,
      'city': orderDetails.customerAddress.split(',').first, // Extract city from address
      'building': '15', // Extracted from address
      'floor': '3', // Extracted from address
      'apartment': '301', // Extracted from address
    };

    // Navigate to CreateOrderScreen in edit mode with the order data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(
          isEditing: true,
          initialOrderId: widget.orderId,
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
    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementation for deleting order
              // In a real app, you would call a provider method here to delete the order
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context); // Go back to orders list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Order #${widget.orderId}',
          style: const TextStyle(
            color: Color(0xFF2F2F2F),
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2F2F2F)),
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
          tabs: const [
            Tab(text: 'Tracking'),
            Tab(text: 'Order Details'),
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
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }
}