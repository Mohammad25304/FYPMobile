import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Chatbot.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  void openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/96170000000');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@cashpilot.app',
      query: 'subject=CashPilot Support',
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _supportCard(
              icon: Icons.smart_toy_outlined,
              title: 'Chat with Assistant',
              subtitle: 'Get instant help from CashPilot chatbot',
              onTap: () => Get.to(() => const ChatbotPage()),
            ),
            _supportCard(
              icon: Icons.chat_outlined,
              title: 'Live Chat (WhatsApp)',
              subtitle: 'Talk to our support team',
              onTap: openWhatsApp,
            ),
            _supportCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'Send us an email',
              onTap: openEmail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: const Color(0xFF1E88E5)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
