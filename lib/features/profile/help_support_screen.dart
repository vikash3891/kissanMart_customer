import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQs Section
          _SectionCard(
            title: 'Frequently Asked Questions',
            children: const [
              _FaqTile(
                question: 'How do I place an order?',
                answer:
                    'Browse products, add them to cart, select your delivery address, choose payment method, and confirm your order.',
              ),
              _FaqTile(
                question: 'How can I track my order?',
                answer:
                    'Go to Orders tab to see real-time status updates for all your orders.',
              ),
              _FaqTile(
                question: 'What is the return policy?',
                answer:
                    'We offer easy returns within 24 hours of delivery for fresh produce and 7 days for packaged items.',
              ),
              _FaqTile(
                question: 'How do I apply a coupon?',
                answer:
                    'During checkout, tap "Apply Coupon" and enter your coupon code. Discounts are applied automatically.',
              ),
              _FaqTile(
                question: 'Is free delivery available?',
                answer:
                    'Free delivery is available on orders above ₹499. A delivery fee of ₹30 applies for smaller orders.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Us
          _SectionCard(
            title: 'Contact Us',
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: kLightGreen,
                  child: Icon(Icons.email_outlined, color: kGreen),
                ),
                title: const Text('Email Support'),
                subtitle: const Text('support@kisaankart.com'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: kLightGreen,
                  child: Icon(Icons.phone_outlined, color: kGreen),
                ),
                title: const Text('Call Us'),
                subtitle: const Text('+91-XXXXXXXXXX'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: kLightGreen,
                  child: Icon(Icons.chat_bubble_outline, color: kGreen),
                ),
                title: const Text('Live Chat'),
                subtitle: const Text('Available 9 AM - 9 PM'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat feature coming soon')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }
}
