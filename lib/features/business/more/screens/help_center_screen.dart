import 'package:flutter/material.dart';
import 'contact_us_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // FAQ categories
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Shipping',
      'description': 'Questions about shipping orders',
    },
    {
      'icon': Icons.payment_outlined,
      'title': 'Payments',
      'description': 'Payment methods and billing',
    },
    {
      'icon': Icons.receipt_long_outlined,
      'title': 'Orders',
      'description': 'Order tracking and management',
    },
    {
      'icon': Icons.person_outline,
      'title': 'Account',
      'description': 'Account settings and profile',
    },
  ];
  
  // FAQ items
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I track my shipment?',
      'answer': 'You can track your shipment by entering the tracking number on the tracking page or by checking the order details in your account.',
      'isExpanded': false,
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept credit cards, debit cards, and cash on delivery. You can manage your payment methods in your account settings.',
      'isExpanded': false,
    },
    {
      'question': 'How to cancel an order?',
      'answer': 'You can cancel an order by going to the order details page and clicking on the "Cancel Order" button. Note that orders that have already been shipped cannot be cancelled.',
      'isExpanded': false,
    },
    {
      'question': 'What are the delivery times?',
      'answer': 'Delivery times vary depending on your location and the shipping method chosen. Standard delivery usually takes 2-3 business days, while express delivery can be completed within 24 hours.',
      'isExpanded': false,
    },
    {
      'question': 'How to contact customer support?',
      'answer': 'You can contact our customer support team through the Contact Us page, by email at support@example.com, or by phone at +201234567890.',
      'isExpanded': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for help',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (value) {
                  // Implement search functionality
                },
              ),
            ),
          ),
          
          // Category title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          
          // Categories horizontal list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(
                    icon: category['icon'],
                    title: category['title'],
                    description: category['description'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpCategoryScreen(
                            category: category['title'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // FAQs title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          
          // FAQ panels
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionPanelList(
                elevation: 1,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _faqs[index]['isExpanded'] = !isExpanded;
                  });
                },
                children: _faqs.map<ExpansionPanel>((Map<String, dynamic> faq) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          faq['question'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: Text(
                        faq['answer'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    isExpanded: faq['isExpanded'],
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Contact button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.headset_mic_outlined),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff29620),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xfff29620),
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class HelpCategoryScreen extends StatelessWidget {
  final String category;
  
  const HelpCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Sample count
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          // Sample content based on category
          return ListTile(
            title: Text('$category question ${index + 1}'),
            subtitle: Text('Tap to view answer for $category question ${index + 1}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to detailed help article
            },
          );
        },
      ),
    );
  }
} 