import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SupportCard extends StatefulWidget {
  final VoidCallback? onClose;

  const SupportCard({super.key, this.onClose});

  @override
  State<SupportCard> createState() => _SupportCardState();
}

class _SupportCardState extends State<SupportCard> {
  Future<void> _launchSupportUrl() async {
    final Uri url = Uri.parse('https://ajude-o-meu-gasto.vercel.app/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)?.supportSectionTitle ??
                      'Está gostando do nosso projeto?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.supportMessage ??
                      'Se ele te ajuda no dia a dia e você quiser apoiar o projeto, ficaremos muito gratos, o apoio é 100% voluntário e não desbloqueia vantagens. É apenas uma forma de dizer "obrigado"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _launchSupportUrl,
                    icon: const Icon(Icons.volunteer_activism),
                    label: Text(
                      AppLocalizations.of(context)?.supportButton ??
                          'Apoiar o projeto',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onClose != null)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: widget.onClose,
                icon: Icon(
                  Icons.close,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
