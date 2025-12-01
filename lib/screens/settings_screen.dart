import 'package:flutter/material.dart';
import '../widgets/shopping_background.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShoppingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Configurações',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text(
                'Modo escuro',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Ativa/desativa o tema escuro do app',
                style: TextStyle(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                  fontSize: 13,
                ),
              ),
              trailing: Switch(
                value: context.watch<ThemeProvider>().isDark,
                onChanged: (value) {
                  context.read<ThemeProvider>().setDark(value);
                },
              ),
              onTap: () {
                final current = context.read<ThemeProvider>().isDark;
                context.read<ThemeProvider>().setDark(!current);
              },
            ),
            Divider(
              thickness: 0.8,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
            ),
          ],
        ),
      ),
    );
  }
}
