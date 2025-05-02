import 'package:flutter/material.dart';

class WelcomeMessage extends StatelessWidget {
  final String name;
  
  const WelcomeMessage({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello, ${name.split(' ')[0].toLowerCase()}! 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset('assets/icons/notification.png', width: 24, height: 24,color: Colors.teal,),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '6',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              const Text(
                'More functionalities?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Row(
                  children: [
                    Text(
                      'Visit Dashboard',
                      style: TextStyle(color: Colors.teal),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.open_in_new, color: Colors.teal, size: 14),
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