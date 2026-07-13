import 'package:flutter/material.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static final Uri _websiteUri = Uri.parse('https://nottik.app');
  static final Uri _githubUri = Uri.parse(
    'https://github.com/isina-nej/NotTik',
  );

  Future<void> _openLink(BuildContext context, Uri uri) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.openLinkError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          GlassmorphismCard(
            depth: 1.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const DepthIcon(
                      icon: Icons.notifications_active_rounded,
                      color: Color(0xFF6366F1),
                      selected: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.aboutHeroTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.aboutHeroBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassmorphismCard(
            depth: 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutPrivacyTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aboutPrivacyBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassmorphismCard(
            depth: 0.9,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _LinkTile(
                  icon: Icons.language_rounded,
                  color: const Color(0xFF0EA5E9),
                  title: l10n.website,
                  subtitle: _websiteUri.toString(),
                  onTap: () => _openLink(context, _websiteUri),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _LinkTile(
                  icon: Icons.code_rounded,
                  color: const Color(0xFF111827),
                  title: l10n.github,
                  subtitle: _githubUri.toString(),
                  onTap: () => _openLink(context, _githubUri),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: DepthIcon(icon: icon, color: color, selected: true),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, textDirection: TextDirection.ltr),
      trailing: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left
            : Icons.chevron_right,
      ),
      onTap: onTap,
    );
  }
}
