// import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:now_shipping/core/utils/status_colors.dart';
// import 'package:now_shipping/features/orders/screens/create_order/create_order_screen.dart';

// class OrderDetailsScreen extends StatefulWidget {
//   final String orderId;
//   final String status;
//   final int initialTabIndex;

//   const OrderDetailsScreen({
//     Key? key,
//     required this.orderId,
//     required this.status,
//     this.initialTabIndex = 0, // Default to tracking tab (index 0)
//   }) : super(key: key);

//   @override
//   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
  
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the tab controller with the provided initial tab index
//     _tabController = TabController(
//       length: 2, 
//       vsync: this,
//       initialIndex: widget.initialTabIndex
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _showActionsBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       backgroundColor: Colors.white,
//       context: context,
//       isScrollControlled: true,
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.7,
//       ),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 12),
//               _buildActionItem(
//                 icon: Icons.qr_code_scanner_outlined,
//                 title: 'Scan Smart Sticker',
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Handle scan sticker
//                 },
//               ),
//               _buildActionItem(
//                 icon: Icons.print_outlined,
//                 title: 'Print Airwaybill',
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Handle print
//                 },
//               ),
//               _buildActionItem(
//                 icon: Icons.confirmation_number_outlined,
//                 title: 'Create ticket',
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Handle create ticket
//                 },
//               ),
//               _buildActionItem(
//                 icon: Icons.delete_outline,
//                 title: 'Delete order',
//                 titleColor: Colors.red,
//                 backgroundColor: const Color(0xFFFEE8E8),
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Handle delete order
//                 },
//               ),
//               const SizedBox(height: 60),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _handleEditOrder() {
//     // Get the current order data
//     Map<String, dynamic> orderData = {
//       'orderId': widget.orderId,
//       'customerName': 'Mohamed Ahmed',
//       'customerPhone': '+201234567890',
//       'customerAddress': 'Cairo, Abdeen, Building 15, Floor 3, Apt 301',
//       'deliveryType': 'Return', // Can be 'Deliver', 'Exchange', 'Return'
//       'packageType': 'Parcel',
//       'numberOfItems': 2,
//       'packageDescription': 'Smartphone with protective case',
//       'collectCashAmount': 850.0,
//       'allowOpeningPackage': true,
//       'deliveryNotes': 'Please call before delivery',
//       'orderReference': 'REF123456',
//       'status': widget.status,
//       'createdAt': '22 Apr 2025',
//       // Exchange specific fields
//       'currentItems': 1,
//       'currentProductDescription': 'Damaged smartphone',
//       'newItems': 2,
//       'newProductDescription': 'Replacement smartphone with case',
//       // Return specific fields
//       'returnItems': 3,
//       'returnReason': 'Customer received wrong item',
//       'returnProductDescription': 'Wedding dress, wrong size'
//     };

//     // Prepare customer data in the format expected by CreateOrderScreen
//     Map<String, dynamic> customerData = {
//       'name': orderData['customerName'],
//       'phoneNumber': orderData['customerPhone'],
//       'addressDetails': orderData['customerAddress'],
//       'city': 'Cairo', // Extracted from address
//       'building': '15', // Extracted from address
//       'floor': '3', // Extracted from address
//       'apartment': '301', // Extracted from address
//     };

//     // Navigate to CreateOrderScreen in edit mode with the order data
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CreateOrderScreen(
//           isEditing: true,
//           initialOrderId: widget.orderId,
//           initialCustomerData: customerData,
//           initialDeliveryType: orderData['deliveryType'],
//           initialProductDescription: orderData['packageDescription'],
//           initialNumberOfItems: orderData['numberOfItems'],
//           initialAllowPackageInspection: orderData['allowOpeningPackage'],
//           initialSpecialInstructions: orderData['deliveryNotes'],
//           initialReferralNumber: orderData['orderReference'],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionItem({
//     required IconData icon,
//     required String title,
//     Color? titleColor,
//     Color? backgroundColor,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 24, color: titleColor ?? const Color(0xff2F2F2F)),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: titleColor ?? const Color(0xff2F2F2F),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Smart sticker scan button
//   Widget _buildScanStickerButton() {
//     return InkWell(
//       onTap: () {
//         _scanBarcode();
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: const Color(0xFF26A2B9),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(
//               Icons.qr_code_scanner,
//               color: Colors.white,
//               size: 24,
//             ),
//             SizedBox(width: 12),
//             Text(
//               'Scan Smart Sticker',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Function to scan barcode/QR code
//   Future<void> _scanBarcode() async {
//     String barcodeScanResult;
    
//     try {
//       // Launch the scanner with customized UI colors
//       barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
//         '#FF26A2B9', // Custom color matching the app's theme
//         'Cancel', 
//         true, // Show flash icon
//         ScanMode.QR, // Can be changed to ScanMode.BARCODE for regular barcodes
//       );

//       // If user cancels, the result will be "-1"
//       if (barcodeScanResult == '-1') {
//         return;
//       }

//       // Show the scan result to the user
//       _showScanResultDialog(barcodeScanResult);
      
//       // Here you would typically process the barcode/QR data
//       // For example, update the order with the scanned sticker ID
//       // or verify that the sticker matches this order
      
//     } catch (e) {
//       // Handle any errors
//       _showErrorDialog("Error scanning barcode: $e");
//     }
//   }

//   // Show dialog with scan result
//   void _showScanResultDialog(String result) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             "Smart Sticker Scanned",
//             style: TextStyle(
//               fontSize: 18,
//               color: Color(0xFF26A2B9),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Sticker ID:",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF2F2F2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   result,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontFamily: 'monospace',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 "This sticker has been associated with the current order.",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text(
//                 'Close',
//                 style: TextStyle(color: Color(0xFF26A2B9)),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Show error dialog
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Error"),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         titleSpacing: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2F2F2F), size: 20),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Row(
//           children: [
//             const Text(
//               'Order ',
//               style: TextStyle(
//                 fontSize: 18, 
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2F2F2F),
//               ),
//             ),
//             Text(
//               '#${widget.orderId}',
//               style: const TextStyle(
//                 fontSize: 16, 
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF26A2B9),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // Edit Order Button
//           IconButton(
//             icon: const Icon(Icons.edit_outlined, color: Color(0xFF26A2B9)),
//             onPressed: () {
//               // Handle edit order action
//               _handleEditOrder();
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: Color(0xFF2F2F2F)),
//             onPressed: () => _showActionsBottomSheet(context),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//             Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//             ),
//             margin: const EdgeInsets.symmetric(horizontal: 2),
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: Container(
//               height: 40, // Added fixed height to reduce tab bar height
//               decoration: BoxDecoration(
//               color: const Color(0xFFF2F2F2),
//               borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Padding(
//               padding: const EdgeInsets.all(2.0),
//               child: TabBar(
//                 controller: _tabController,
//                 indicator: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                   ),
//                 ],
//                 ),
//                 indicatorSize: TabBarIndicatorSize.tab,
//                 labelColor: Colors.black,
//                 unselectedLabelColor: Colors.grey,
//                 labelStyle: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//                 ),
//                 unselectedLabelStyle: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//                 ),
//                 labelPadding: const EdgeInsets.symmetric(vertical: 2), // Reduced vertical padding
//                 tabs: const [
//                 Tab(text: 'Tracking', height: 36), // Set explicit height for tabs
//                 Tab(text: 'Details', height: 36), // Set explicit height for tabs
//                 ],
//               ),
//               ),
//             ),
//             ),
//           const SizedBox(height: 8),
//           const Divider(height: 4, thickness: 6, color: Color(0xFFEEEEEE)),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildTrackingView(),
//                 _buildDetailsView(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrackingView() {
//     // Define tracking steps with their corresponding statuses
//     final List<Map<String, dynamic>> trackingSteps = [
//       {
//         'title': 'New',
//         'status': 'New',
//         'description': 'You successfully created the order.',
//         'time': '24 Feb 2025 - 21:07 PM',
//         'isCompleted': widget.status == 'New' || widget.status == 'Picked Up' || 
//                        widget.status == 'In Stock' || widget.status == 'In Progress' || 
//                        widget.status == 'Heading To Customer' || widget.status == 'Completed',
//         'isFirst': true,
//       },
//       {
//         'title': 'Picked up',
//         'status': 'Picked Up',
//         'description': 'We got your order! It should be at our warehouses by the end of day.',
//         'time': '',
//         'isCompleted': widget.status == 'Picked Up' || widget.status == 'In Stock' || 
//                        widget.status == 'In Progress' || widget.status == 'Heading To Customer' || 
//                        widget.status == 'Completed',
//       },
//       {
//         'title': 'In Progress',
//         'status': 'In Progress',
//         'description': 'We\'re preparing your order and we\'ll start shipping it soon.',
//         'time': '',
//         'isCompleted': widget.status == 'In Progress' || widget.status == 'Heading To Customer' || 
//                        widget.status == 'Completed',
//       },
//       {
//         'title': 'Heading to customer',
//         'status': 'Heading to customer',
//         'description': 'We shipped the order for delivery to your customer.',
//         'time': '',
//         'isCompleted': widget.status == 'Heading To Customer' || widget.status == 'Completed',
//       },
//       {
//         'title': 'Successful',
//         'status': 'Successful',
//         'description': 'Order delivered successfully to your customer 🎉',
//         'time': '',
//         'isCompleted': widget.status == 'Completed',
//         'isLast': true,
//       },
//     ];

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//       itemCount: trackingSteps.length,
//       itemBuilder: (context, index) {
//         final step = trackingSteps[index];
//         return _buildTrackingStep(
//           isCompleted: step['isCompleted'],
//           title: step['title'],
//           status: step['status'],
//           description: step['description'],
//           time: step['time'],
//           isFirst: step['isFirst'] ?? false,
//           isLast: step['isLast'] ?? false,
//         );
//       },
//     );
//   }

//   Widget _buildTrackingStep({
//     required bool isCompleted,
//     required String title,
//     required String status,
//     required String description,
//     required String time,
//     bool isFirst = false,
//     bool isLast = false,
//   }) {
//     // Use the StatusColors utility for consistent coloring
//     final Color completedColor = const Color(0xFF25AB93); // Default green for completed
//     final Color incompleteColor = Colors.grey.shade300;
//     final Color titleColor = isCompleted 
//         ? StatusColors.getTextColor(status) 
//         : Colors.grey;
    
//     // Calculate the height of the vertical line
//     double lineHeight = isCompleted ? 65.0 : 60.0;
    
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             if (isCompleted)
//               Container(
//                 width: 20,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: completedColor,
//                   border: Border.all(
//                     color: completedColor,
//                     width: 1,
//                   ),
//                 ),
//                 child: const Icon(Icons.check, color: Colors.white, size: 16),
//               )
//             else
//               Container(
//                 width: 20,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white,
//                   border: Border.all(
//                     color: incompleteColor,
//                     width: 1,
//                   ),
//                 ),
//               ),
//             if (!isLast)
//               isCompleted
//                 ? Container(
//                     width: 3,
//                     height: lineHeight,
//                     color: completedColor,
//                   )
//                 : Column(
//                     children: List.generate(
//                       5,
//                       (index) => Container(
//                         width: 1,
//                         height: 1,
//                         margin: const EdgeInsets.symmetric(vertical: 3),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: incompleteColor,
//                         ),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: titleColor,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 description,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.grey[600],
//                   height: 1.3,
//                 ),
//               ),
//               if (time.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4.0),
//                   child: Text(
//                     time,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[400],
//                     ),
//                   ),
//                 ),
//               SizedBox(height: isLast ? 0 : lineHeight - 24),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsView() {
//     // Sample order data - in a real app, this would be fetched from your backend
//     // based on the widget.orderId
//     final Map<String, dynamic> orderData = {
//       'orderId': widget.orderId,
//       'customerName': 'Mohamed Ahmed',
//       'customerPhone': '+201234567890',
//       'customerAddress': 'Cairo, Abdeen, Building 15, Floor 3, Apt 301',
//       'deliveryType': 'Return', // Can be 'Deliver', 'Exchange', 'Return'
//       'packageType': 'Parcel',
//       'numberOfItems': 2,
//       'packageDescription': 'Smartphone with protective case',
//       'collectCashAmount': 850.0,
//       'allowOpeningPackage': true,
//       'deliveryNotes': 'Please call before delivery',
//       'orderReference': 'REF123456',
//       'status': widget.status,
//       'createdAt': '22 Apr 2025',
//       // Exchange specific fields
//       'currentItems': 1,
//       'currentProductDescription': 'Damaged smartphone',
//       'newItems': 2,
//       'newProductDescription': 'Replacement smartphone with case',
//       // Return specific fields
//       'returnItems': 3,
//       'returnReason': 'Customer received wrong item',
//       'returnProductDescription': 'Wedding dress, wrong size'
//     };

//     return ListView(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//       children: [
//         // Scan Smart Sticker button at the top
//         _buildScanStickerButton(),
//         const SizedBox(height: 16),
        
//         _buildCustomerSection(orderData),
//         const SizedBox(height: 16),
//         _buildShippingSection(orderData),
//         const SizedBox(height: 16),
        
//         // Show different package details section based on delivery type
//         if (orderData['deliveryType'] == 'Deliver')
//           _buildDeliveryDetailsSection(orderData)
//         else if (orderData['deliveryType'] == 'Exchange')
//           _buildExchangeDetailsSection(orderData)
//         else if (orderData['deliveryType'] == 'Return')
//           _buildReturnDetailsSection(orderData),
        
//         const SizedBox(height: 16),
//         _buildAdditionalDetailsSection(orderData),
//       ],
//     );
//   }

//   // Delivery Details Section - shows when Deliver is selected
//   Widget _buildDeliveryDetailsSection(Map<String, dynamic> orderData) {
//     return _buildSectionContainer(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Delivery Details', Icons.inventory_2_outlined),
//           const SizedBox(height: 16),
          
//           // Package Type
//           _buildDetailRow(
//             label: 'Package Type',
//             value: orderData['packageType'] ?? 'N/A',
//           ),
          
//           const SizedBox(height: 12),
          
//           // Number of Items
//           _buildDetailRow(
//             label: 'Number of Items',
//             value: '${orderData['numberOfItems'] ?? 0}',
//           ),
          
//           const SizedBox(height: 12),
          
//           // Package Description
//           _buildDetailRow(
//             label: 'Package Description',
//             value: orderData['packageDescription'] ?? 'N/A',
//             maxLines: 3,
//           ),
          
//           const SizedBox(height: 12),
          
//           // Cash on Delivery
//           _buildDetailRow(
//             label: 'Cash on Delivery',
//             value: '${orderData['collectCashAmount'] ?? 0} EGP',
//             isHighlighted: true,
//           ),
          
//           const SizedBox(height: 12),
          
//           // Allow Opening Package
//           Row(
//             children: [
//               Icon(
//                 orderData['allowOpeningPackage'] == true
//                     ? Icons.check_box_outlined
//                     : Icons.check_box_outline_blank,
//                 color: const Color(0xFF26A2B9),
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Allow customer to inspect package',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF2F2F2F),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Exchange Details Section - shows when Exchange is selected
//   Widget _buildExchangeDetailsSection(Map<String, dynamic> orderData) {
//     return _buildSectionContainer(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Exchange Details', Icons.swap_horiz_outlined),
//           const SizedBox(height: 16),
          
//           // Current Items section
//           const Text(
//             'Current Items (To Be Collected)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF2F2F2F),
//             ),
//           ),
//           const SizedBox(height: 8),
          
//           // Number of Current Items
//           _buildDetailRow(
//             label: 'Number of Items',
//             value: '${orderData['currentItems'] ?? 0}',
//           ),
          
//           const SizedBox(height: 12),
          
//           // Current Item Description
//           _buildDetailRow(
//             label: 'Item Description',
//             value: orderData['currentProductDescription'] ?? 'N/A',
//             maxLines: 3,
//           ),
          
//           const Divider(height: 32),
          
//           // New Items section
//           const Text(
//             'New Items (To Be Delivered)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF2F2F2F),
//             ),
//           ),
//           const SizedBox(height: 8),
          
//           // Number of New Items
//           _buildDetailRow(
//             label: 'Number of Items',
//             value: '${orderData['newItems'] ?? 0}',
//           ),
          
//           const SizedBox(height: 12),
          
//           // New Item Description
//           _buildDetailRow(
//             label: 'Item Description',
//             value: orderData['newProductDescription'] ?? 'N/A',
//             maxLines: 3,
//           ),
          
//           const SizedBox(height: 12),
          
//           // Cash on Delivery (if applicable)
//           if (orderData['collectCashAmount'] != null && orderData['collectCashAmount'] > 0) ...[
//             const SizedBox(height: 12),
//             _buildDetailRow(
//               label: 'Cash on Delivery',
//               value: '${orderData['collectCashAmount']} EGP',
//               isHighlighted: true,
//             ),
//           ],
          
//           const SizedBox(height: 12),
          
//           // Allow Opening Package
//           Row(
//             children: [
//               Icon(
//                 orderData['allowOpeningPackage'] == true
//                     ? Icons.check_box_outlined
//                     : Icons.check_box_outline_blank,
//                 color: const Color(0xFF26A2B9),
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Allow customer to inspect package',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF2F2F2F),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Return Details Section - shows when Return is selected
//   Widget _buildReturnDetailsSection(Map<String, dynamic> orderData) {
//     return _buildSectionContainer(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Return Details', Icons.assignment_return_outlined),
//           const SizedBox(height: 16),
          
//           // Number of Return Items
//           _buildDetailRow(
//             label: 'Number of Items',
//             value: '${orderData['returnItems'] ?? 0}',
//           ),
          
//           const SizedBox(height: 12),
          
//           // Return Reason
//           _buildDetailRow(
//             label: 'Return Reason',
//             value: orderData['returnReason'] ?? 'N/A',
//             maxLines: 2,
//           ),
          
//           const SizedBox(height: 12),
          
//           // Return Items Description
//           _buildDetailRow(
//             label: 'Item Description',
//             value: orderData['returnProductDescription'] ?? 'N/A',
//             maxLines: 3,
//           ),
          
//           // Cash on Delivery (if applicable for return exchange difference)
//           if (orderData['collectCashAmount'] != null && orderData['collectCashAmount'] > 0) ...[
//             const SizedBox(height: 12),
//             _buildDetailRow(
//               label: 'Cash on Return',
//               value: '${orderData['collectCashAmount']} EGP',
//               isHighlighted: true,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomerSection(Map<String, dynamic> orderData) {
//     return _buildSectionContainer(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Customer', Icons.person_outline),
//           const SizedBox(height: 16),
          
//           // Customer name
//           Text(
//             orderData['customerName'] ?? 'N/A',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF2F2F2F),
//             ),
//           ),
//           const SizedBox(height: 8),
          
//           // Phone
//           Row(
//             children: [
//               const Icon(Icons.phone, size: 16, color: Colors.grey),
//               const SizedBox(width: 8),
//               Text(
//                 orderData['customerPhone'] ?? 'N/A',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
          
//           // Address
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.location_on, size: 16, color: Colors.grey),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   orderData['customerAddress'] ?? 'N/A',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShippingSection(Map<String, dynamic> orderData) {
//     String deliveryType = orderData['deliveryType'] ?? 'Deliver';
    
//     return _buildSectionContainer(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Shipping Information', Icons.local_shipping_outlined),
//           const SizedBox(height: 16),
          
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE3F8FC),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.withOpacity(0.3)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   deliveryType == 'Deliver' ? Icons.local_shipping_outlined :
//                   deliveryType == 'Exchange' ? Icons.swap_horiz_outlined :
//                   Icons.assignment_return_outlined,
//                   color: Colors.blue,
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       deliveryType,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     Text(
//                       deliveryType == 'Deliver' ? 'Deliver items to customer' :
//                       deliveryType == 'Exchange' ? 'Exchange items with customer' :
//                       'Return items from customer',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdditionalDetailsSection(Map<String, dynamic> orderData) {
//     return _buildSectionContainer(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader('Additional Details', Icons.info_outline),
//           const SizedBox(height: 16),
          
//           // Special Instructions
//           if (orderData['deliveryNotes'] != null && orderData['deliveryNotes'].isNotEmpty)
//             _buildDetailRow(
//               label: 'Special Instructions',
//               value: orderData['deliveryNotes'],
//               maxLines: 3,
//             ),
          
//           // Reference Number
//           if (orderData['orderReference'] != null && orderData['orderReference'].isNotEmpty) ...[
//             const SizedBox(height: 12),
//             _buildDetailRow(
//               label: 'Reference Number',
//               value: orderData['orderReference'],
//             ),
//           ],
          
//           const SizedBox(height: 12),
          
//           // Date created
//           _buildDetailRow(
//             label: 'Date Created',
//             value: orderData['createdAt'] ?? 'N/A',
//           ),
          
//           const SizedBox(height: 12),
          
//           // Order Status
//           _buildDetailRow(
//             label: 'Status',
//             value: orderData['status'] ?? 'N/A',
//             valueColor: StatusColors.getTextColor(orderData['status'] ?? ''),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionContainer({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: const Color(0xFF26A2B9)),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF2F2F2F),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow({
//     required String label,
//     required String value,
//     int maxLines = 1,
//     bool isHighlighted = false,
//     Color? valueColor,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
//             color: valueColor ?? (isHighlighted ? const Color(0xFFF89C29) : const Color(0xFF2F2F2F)),
//           ),
//           maxLines: maxLines,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }
// }