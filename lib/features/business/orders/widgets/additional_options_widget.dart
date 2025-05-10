import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/features/business/orders/providers/order_providers.dart';

class AdditionalOptionsWidget extends ConsumerStatefulWidget {
  const AdditionalOptionsWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<AdditionalOptionsWidget> createState() => _AdditionalOptionsWidgetState();
}

class _AdditionalOptionsWidgetState extends ConsumerState<AdditionalOptionsWidget> {
  late TextEditingController _specialInstructionsController;
  late TextEditingController _referralNumberController;
  
  @override
  void initState() {
    super.initState();
    _specialInstructionsController = TextEditingController();
    _referralNumberController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final order = ref.read(orderModelProvider);
    
    if (order.specialInstructions != null && _specialInstructionsController.text.isEmpty) {
      _specialInstructionsController.text = order.specialInstructions!;
    }
    
    if (order.referralNumber != null && _referralNumberController.text.isEmpty) {
      _referralNumberController.text = order.referralNumber!;
    }
  }
  
  @override
  void dispose() {
    _specialInstructionsController.dispose();
    _referralNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderModelProvider);
    final allowPackageInspection = order.allowPackageInspection ?? false;

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
          // Additional Options Header
          const Text(
            'Additional Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Specify any special requirements for this order',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Allow package inspection option
          Row(
            children: [
              Checkbox(
                value: allowPackageInspection,
                onChanged: (value) {
                  ref.read(orderModelProvider.notifier).updateAdditionalOptions(
                    allowPackageInspection: value,
                  );
                },
                activeColor: Colors.orange.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Allow opening package',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff2F2F2F),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Special Instructions
          const Text(
            'Special Instructions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Special Instructions TextField
          TextFormField(
            controller: _specialInstructionsController,
            maxLines: 4,
            onChanged: (value) {
              ref.read(orderModelProvider.notifier).updateAdditionalOptions(
                specialInstructions: value,
              );
            },
            decoration: InputDecoration(
              hintText: 'Add any special delivery instructions or notes',
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
          
          // Referral Number
          const Text(
            'Referral Number (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2F2F2F),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Referral Number TextField
          TextFormField(
            controller: _referralNumberController,
            onChanged: (value) {
              ref.read(orderModelProvider.notifier).updateAdditionalOptions(
                referralNumber: value,
              );
            },
            decoration: InputDecoration(
              hintText: 'Enter referral code if available',
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
        ],
      ),
    );
  }
}