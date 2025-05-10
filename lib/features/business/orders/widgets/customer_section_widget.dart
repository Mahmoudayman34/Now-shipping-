import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import 'package:now_shipping/features/business/orders/screens/create_order/customer_details_screen.dart';

class CustomerSectionWidget extends ConsumerWidget {
  const CustomerSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerData = ref.watch(customerDataProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader('Customer', Icons.person_outline),
          const SizedBox(height: 12),
          
          // Show customer details or add button
          if (customerData != null)
            _buildCustomerDetails(context, customerData, ref)
          else
            // Add Customer Button
            GestureDetector(
              onTap: () => _navigateToCustomerDetails(context, ref),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F8FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Add Customer Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCustomerDetails(BuildContext context, Map<String, dynamic> customerData, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer name and edit button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                customerData['name'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2F2F2F),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Edit button
            TextButton(
              onPressed: () => _navigateToCustomerDetails(context, ref, customerData),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Phone number
        Row(
          children: [
            const Icon(Icons.phone, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              customerData['phoneNumber'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getFullAddress(customerData),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _navigateToCustomerDetails(BuildContext context, WidgetRef ref, [Map<String, dynamic>? initialData]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsScreen(
          initialData: initialData,
          onCustomerDataSaved: (data) {
            ref.read(customerDataProvider.notifier).state = data;
            // Also update order model with customer data
            ref.read(orderModelProvider.notifier).updateCustomerData(data);
          },
        ),
      ),
    );
  }
  
  String _getFullAddress(Map<String, dynamic> customerData) {
    final List<String> addressParts = [];
    
    if (customerData['addressDetails']?.isNotEmpty == true) {
      addressParts.add(customerData['addressDetails']);
    }
    
    if (customerData['building']?.isNotEmpty == true) {
      addressParts.add('Building: ${customerData['building']}');
    }
    
    if (customerData['floor']?.isNotEmpty == true) {
      addressParts.add('Floor: ${customerData['floor']}');
    }
    
    if (customerData['apartment']?.isNotEmpty == true) {
      addressParts.add('Apt: ${customerData['apartment']}');
    }
    
    if (customerData['city']?.isNotEmpty == true) {
      addressParts.add(customerData['city']);
    }
    
    return addressParts.join(', ');
  }
}