import 'package:flutter/material.dart';
import 'package:now_shipping/features/business/orders/screens/create_order/create_order_screen.dart';

class CreateOrderButton extends StatelessWidget {
  const CreateOrderButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'createOrderButton',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateOrderScreen(),
          ),
        );
      },
      backgroundColor: Colors.red,
      child: const Icon(Icons.add),
    );
  }
}