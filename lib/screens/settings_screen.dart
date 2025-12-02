import 'package:flutter/material.dart';
import '../widgets/shopping_background.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
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
                final currentCode =
                    context.read<ThemeProvider>().locale?.toLanguageTag();
                String? selectedCode = currentCode;
                await showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text(
                        AppLocalizations.of(ctx)?.chooseLanguageTitle ??
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
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageSystem ??
                                    'Usar idioma do sistema',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'pt_BR',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languagePortuguese ??
                                    'Português (Brasil)',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'en',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageEnglish ??
                                    'Inglês',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'es',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageSpanish ??
                                    'Espanhol',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'fr',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageFrench ??
                                    'Francês',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'de',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageGerman ??
                                    'Alemão',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'it',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageItalian ??
                                    'Italiano',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'ja',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageJapanese ??
                                    'Japonês',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'ko',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageKorean ??
                                    'Coreano',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'pl',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languagePolish ??
                                    'Polonês',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'ru',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(ctx)?.languageRussian ??
                                    'Russo',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'zh_Hans',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(
                                      ctx,
                                    )?.languageChineseSimplified ??
                                    'Chinês Simplificado',
                              ),
                            ),
                            RadioListTile<String?>(
                              value: 'zh_Hant',
                              groupValue: selectedCode,
                              onChanged: (val) {
                                selectedCode = val;
                                Navigator.of(ctx).pop();
                              },
                              title: Text(
                                AppLocalizations.of(
                                      ctx,
                                    )?.languageChineseTraditional ??
                                    'Chinês Tradicional',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                      (AppLocalizations.of(
                            context,
                          )?.backupSavedAt(savedPath ?? '') ??
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
          ],
        ),
      ),
    );
  }
}
