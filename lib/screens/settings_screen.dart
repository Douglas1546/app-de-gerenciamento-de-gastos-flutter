import 'package:flutter/material.dart';
import '../widgets/shopping_background.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/product_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _lastBackupPath;

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
    return ShoppingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context)?.settingsTitle ?? 'Configurações',
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
              title: Text(
                AppLocalizations.of(context)?.darkMode ?? 'Modo escuro',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                AppLocalizations.of(context)?.darkModeSubtitle ??
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
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: const Icon(Icons.language_outlined),
              title: Text(
                AppLocalizations.of(context)?.language ?? 'Idioma',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                AppLocalizations.of(context)?.languageSubtitle ??
                    'Escolha o idioma do app',
                style: TextStyle(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                  fontSize: 13,
                ),
              ),
              onTap: () async {
                final currentCode = context.read<ThemeProvider>().localeCode;
                String? selectedCode =
                    (currentCode == null || currentCode.isEmpty)
                        ? null
                        : currentCode;
                await _showSmoothDialog<void>(
                  context,
                  AlertDialog(
                    title: Text(
                      AppLocalizations.of(context)?.chooseLanguageTitle ??
                          'Idioma',
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<String?>(
                            value: null,
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageSystem ??
                                  'Usar idioma do sistema',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'pt_BR',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(
                                    context,
                                  )?.languagePortuguese ??
                                  'Português (Brasil)',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'pt',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(
                                    context,
                                  )?.languagePortuguesePortugal ??
                                  'Português (Portugal)',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'en',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageEnglish ??
                                  'Inglês',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'es',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageSpanish ??
                                  'Espanhol',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'fr',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageFrench ??
                                  'Francês',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'de',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageGerman ??
                                  'Alemão',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'it',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageItalian ??
                                  'Italiano',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'ja',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageJapanese ??
                                  'Japonês',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'ko',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageKorean ??
                                  'Coreano',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'pl',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languagePolish ??
                                  'Polonês',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'ru',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(context)?.languageRussian ??
                                  'Russo',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'zh_Hans',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(
                                    context,
                                  )?.languageChineseSimplified ??
                                  'Chinês Simplificado',
                            ),
                          ),
                          RadioListTile<String?>(
                            value: 'zh_Hant',
                            groupValue: selectedCode,
                            onChanged: (val) {
                              selectedCode = val;
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              AppLocalizations.of(
                                    context,
                                  )?.languageChineseTraditional ??
                                  'Chinês Tradicional',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                context.read<ThemeProvider>().setLocaleCode(selectedCode ?? '');
              },
            ),
            Divider(
              thickness: 0.8,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: const Icon(Icons.backup_outlined),
              title: Text(
                AppLocalizations.of(context)?.createBackup ?? 'Criar backup',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                AppLocalizations.of(context)?.createBackupSubtitle ??
                    'Exporta os dados para um arquivo .json',
                style: TextStyle(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                  fontSize: 13,
                ),
              ),
              onTap: () async {
                final provider = context.read<ProductProvider>();
                final json = await provider.exportToJson();
                final now = DateTime.now();
                final ts =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
                final fileName = 'shopping_list_backup_$ts.json';

                String? savedPath;
                if (Platform.isAndroid || Platform.isIOS) {
                  try {
                    savedPath = await FlutterFileDialog.saveFile(
                      params: SaveFileDialogParams(
                        data: utf8.encode(json),
                        fileName: fileName,
                      ),
                    );
                  } catch (_) {
                    savedPath = null;
                  }
                }

                if (savedPath == null) {
                  String? targetPath;
                  try {
                    targetPath = await FilePicker.platform.saveFile(
                      dialogTitle:
                          AppLocalizations.of(context)?.saveBackupDialogTitle ??
                          'Salvar backup',
                      fileName: fileName,
                      type: FileType.custom,
                      allowedExtensions: const ['json'],
                    );
                  } catch (_) {
                    targetPath = null;
                  }

                  if (targetPath == null) {
                    String? dirPath;
                    try {
                      dirPath = await FilePicker.platform.getDirectoryPath();
                    } catch (_) {
                      dirPath = null;
                    }
                    if (dirPath != null) {
                      targetPath = p.join(dirPath, fileName);
                    }
                  }

                  if (targetPath == null) {
                    final dbDir = await getDatabasesPath();
                    final backupsPath = p.join(dbDir, 'shopping_list_backups');
                    await Directory(backupsPath).create(recursive: true);
                    targetPath = p.join(backupsPath, fileName);
                  }

                  final file = File(targetPath);
                  await file.writeAsString(json);
                  savedPath = targetPath;
                }

                if (!mounted) return;
                setState(() {
                  _lastBackupPath = savedPath;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      (AppLocalizations.of(context)?.backupSavedAt(savedPath) ??
                          'Backup salvo em:\n$savedPath'),
                    ),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
            ),
            if (_lastBackupPath != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.lastBackupSavedAt ??
                          'Último backup salvo em:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      _lastBackupPath!,
                      style: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Divider(
                thickness: 0.8,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.black12,
              ),
            ],
            Divider(
              thickness: 0.8,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(
                AppLocalizations.of(context)?.importData ?? 'Importar dados',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                AppLocalizations.of(context)?.importDataSubtitle ??
                    'Seleciona um arquivo .json para importar',
                style: TextStyle(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                  fontSize: 13,
                ),
              ),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: const ['json'],
                );
                final path = result?.files.single.path;
                if (path == null) return;
                final file = File(path);
                final content = await file.readAsString();
                final count = await context
                    .read<ProductProvider>()
                    .importFromJsonString(content);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)?.importedItems(count) ??
                          'Importados $count itens',
                    ),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
            ),
            Divider(
              thickness: 0.8,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<T?> _showSmoothDialog<T>(BuildContext context, Widget child) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
