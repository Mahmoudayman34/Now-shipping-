import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  
  const DashboardHeader({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(

                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Center(
                  child: Image.asset(
                  'assets/icons/icon_only.png',
                  width: 50,
                  height: 50,
                  color: const Color(0xfff29620),
                  ),
                ),
              ),
               const SizedBox(width: 8),
              Image.asset(
                  'assets/images/word_only.png',
                  width: 70,
                  height: 70,
                  
                  ),
                  const SizedBox(width: 4),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset('assets/icons/receipt.png', width: 16, height: 16),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(

                  children: [
                    Image.asset('assets/icons/support.png', width: 24, height: 24,
                      color: Colors.teal),
                    const SizedBox(width: 4),
                    const Text('Support', style: TextStyle(color: Colors.teal)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}