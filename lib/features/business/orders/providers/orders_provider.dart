import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the selected tab in the orders screen
final selectedOrderTabProvider = StateProvider<String>((ref) => 'All');

// Provider for the mock orders data
final ordersProvider = Provider<List<Map<String, dynamic>>>((ref) => [
  {
    'orderId': '32686112',
    'customerName': 'Mohamed Ahmed Saad',
    'location': 'Cairo, Abdeen',
    'amount': '300 EGP',
    'status': 'New',
  },
  {
    'orderId': '32686113',
    'customerName': 'Ahmed Hassan',
    'location': 'Cairo, Maadi',
    'amount': '450 EGP',
    'status': 'In Progress',
  },
  {
    'orderId': '32686114',
    'customerName': 'Sara Ibrahim',
    'location': 'Cairo, Heliopolis',
    'amount': '600 EGP',
    'status': 'Picked Up',
  },
  {
    'orderId': '32686115',
    'customerName': 'Omar Khaled',
    'location': 'Cairo, Zamalek',
    'amount': '275 EGP',
    'status': 'Terminated',
  },
  {
    'orderId': '32686116',
    'customerName': 'Omar Khaled',
    'location': 'Cairo, Zamalek',
    'amount': '275 EGP',
    'status': 'Canceled',
  },
  {
    'orderId': '32686117',
    'customerName': 'Omar Khaled',
    'location': 'Cairo, Zamalek',
    'amount': '275 EGP',
    'status': 'In Stock',
  },
  {
    'orderId': '32686118',
    'customerName': 'Omar Khaled',
    'location': 'Cairo, Zamalek',
    'amount': '275 EGP',
    'status': 'Completed',
  },
  {
    'orderId': '32686119',
    'customerName': 'Omar Khaled',
    'location': 'Cairo, Zamalek',
    'amount': '275 EGP',
    'status': 'Heading To Customer',
  },
]);

// Provider for filtered orders based on selected tab
final filteredOrdersProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final orders = ref.watch(ordersProvider);
  final selectedTab = ref.watch(selectedOrderTabProvider);
  
  if (selectedTab == 'All') {
    return orders;
  } else {
    return orders.where((order) => order['status'] == selectedTab).toList();
  }
});