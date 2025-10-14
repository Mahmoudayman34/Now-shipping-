import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:now_shipping/features/business/orders/providers/order_providers.dart';
import 'package:now_shipping/features/business/orders/screens/create_order/create_order_screen.dart';
import '../../../../core/utils/responsive_utils.dart';

class CreateOrderButton extends ConsumerWidget {
  const CreateOrderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: 'createOrderButton',
      onPressed: () {
        // Reset all order-related state before navigating to create screen
        ref.read(orderModelProvider.notifier).resetOrder();
        ref.read(customerDataProvider.notifier).state = null;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateOrderScreen(),
          ),
        );
      },
      backgroundColor: Colors.red,
      child: Icon(
        Icons.add,
        size: ResponsiveUtils.getResponsiveIconSize(context),
      ),
    );
  }
}