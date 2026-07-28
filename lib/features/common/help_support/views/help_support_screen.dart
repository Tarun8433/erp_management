import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/constants/app_urls.dart';
import 'package:erp_management/routes/app_routes.dart';

/// Help & Support screen: contact details, quick FAQ, and links to the
/// Privacy Policy / Terms pages (opened inside the in-app WebView).
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _openWeb(String title, String url) {
    Get.toNamed(AppRoutes.webView, arguments: {'title': title, 'url': url});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(scheme: scheme),
          const SizedBox(height: 24),
          _sectionTitle(context, 'CONTACT US'),
          const SizedBox(height: 10),
          _Card(children: [
            _ContactTile(
              icon: Icons.email_outlined,
              color: Colors.indigo,
              title: 'Email',
              subtitle: AppUrls.supportEmail,
              onTap: () => _copy(AppUrls.supportEmail, 'Email copied'),
            ),
            const Divider(height: 1),
            _ContactTile(
              icon: Icons.phone_outlined,
              color: Colors.green,
              title: 'Phone',
              subtitle: AppUrls.supportPhone,
              onTap: () => _copy(AppUrls.supportPhone, 'Phone number copied'),
            ),
            const Divider(height: 1),
            _ContactTile(
              icon: Icons.language_outlined,
              color: Colors.teal,
              title: 'Website',
              subtitle: AppUrls.website,
              onTap: () => _openWeb('School Club', AppUrls.website),
            ),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(context, 'FREQUENTLY ASKED'),
          const SizedBox(height: 10),
          _Card(
            children: _faqs
                .map((f) => _FaqTile(question: f.$1, answer: f.$2))
                .toList(),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, 'LEGAL'),
          const SizedBox(height: 10),
          _Card(children: [
            _ContactTile(
              icon: Icons.privacy_tip_outlined,
              color: Colors.indigo,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () =>
                  _openWeb('Privacy Policy', AppUrls.privacyPolicy),
            ),
            const Divider(height: 1),
            _ContactTile(
              icon: Icons.description_outlined,
              color: Colors.purple,
              title: 'Terms & Conditions',
              subtitle: 'Rules for using the app',
              onTap: () =>
                  _openWeb('Terms & Conditions', AppUrls.termsAndConditions),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _copy(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  static const List<(String, String)> _faqs = [
    (
      'How do I reset my password?',
      'Go to the login screen and tap "Forgot Password". Enter your registered '
          'mobile number or email to receive reset instructions.',
    ),
    (
      'How do I change the app language or theme?',
      'Open Settings from the menu. You can switch language, theme (light/dark) '
          'and font size from there.',
    ),
    (
      'Why can’t I see my classes or groups?',
      'Make sure an active session is selected. If the problem continues, '
          'check your internet connection and try again.',
    ),
    (
      'How do I contact the school administration?',
      'Use the Email or Phone details above, or reach out through the school’s '
          'official website.',
    ),
  ];
}

class _Header extends StatelessWidget {
  final ColorScheme scheme;
  const _Header({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.support_agent_rounded,
              size: 44, color: scheme.onPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We’re here to help',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reach out to us anytime — we usually respond within 24 hours.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded),
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
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      children: [
        Text(
          answer,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
