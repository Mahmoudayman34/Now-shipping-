import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tes1/core/widgets/toast_.dart';
import 'package:tes1/features/auth/services/auth_service.dart';
import 'package:tes1/features/business/orders/screens/create_order/create_order_screen.dart';

class EmptyOrdersState extends ConsumerWidget {
  const EmptyOrdersState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/order.png',
            width: 100,
            height: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          const Text(
            "You didn't create orders yet!",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xff2F2F2F),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleCreateOrder(context, ref),
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withOpacity(0.1),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Create Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateOrder(BuildContext context, WidgetRef ref) async {
    // Check if user profile is complete before navigating
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    
    if (user != null && user.isProfileComplete) {
      // Profile is complete, proceed with navigation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateOrderScreen(),
        ),
      );
    } else {
      // Profile is not complete, show toast message
      ToastService.show(
        context,
        'Please complete and activate your account first',
        type: ToastType.warning,
      );
    }
  }
}