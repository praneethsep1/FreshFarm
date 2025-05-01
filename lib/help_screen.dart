import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A stateless widget that displays a help center with FAQs and customer support options.
///
/// Shows a list of frequently asked questions with expandable answers and a button
/// to initiate a phone call to customer care.

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  /// A list of frequently asked questions (FAQs) and their answers.
  ///
  /// Each entry is a map with a 'query' (the question) and an 'answer' (the response).

  final List<Map<String, String>> faqs = const [
    {
      'query': 'How do I place an order?',
      'answer':
          'Go to the Products tab, select items, add them to your cart, then proceed to checkout from the Cart tab.',
    },
    {
      'query': 'How can I track my order?',
      'answer':
          'Visit the Orders tab to see the status of your orders. You’ll also receive notifications when the status changes.',
    },
    {
      'query': 'How do I add a product as a farmer?',
      'answer':
          'Go to the Products tab, tap "Add New Product," fill in the details, and save.',
    },
    {
      'query': 'What if my order is delayed?',
      'answer':
          'Check the Orders tab for updates. If delayed, contact customer care using the "More Help" option below.',
    },
    {
      'query': 'How do I update my profile?',
      'answer':
          'Go to the Profile tab, edit your details, and tap "Save Profile."',
    },
  ];

  /// Initiates a phone call to the customer care number.
  ///
  /// Uses [url_launcher] to launch the phone dialer with a predefined phone number.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the call is initiated.

  Future<void> _launchPhoneCall() async {
    const phoneNumber = 'tel:+1 2345678900';
    await launchUrl(Uri.parse(phoneNumber));
  }

  /// Builds the UI for the help center screen.
  ///
  /// Displays a list of FAQs in expandable tiles and a button to call customer care.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the help center screen UI.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to the Help Center!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'FAQs:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(
                      faqs[index]['query']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(faqs[index]['answer']!),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _launchPhoneCall();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to initiate call: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'More Help - Call Customer Care',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
