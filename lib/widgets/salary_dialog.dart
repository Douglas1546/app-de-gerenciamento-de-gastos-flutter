import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/product_provider.dart';

class SalaryDialog extends StatefulWidget {
  final int year;
  final int month;
  final double? currentSalary;

  const SalaryDialog({
    Key? key,
    required this.year,
    required this.month,
    this.currentSalary,
  }) : super(key: key);

  @override
  State<SalaryDialog> createState() => _SalaryDialogState();
}

class _SalaryDialogState extends State<SalaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentSalary != null) {
      _salaryController.text = widget.currentSalary!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n?.setSalaryDialogTitle ?? 'Definir Salário Mensal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mês: ${widget.month}/${widget.year}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salaryController,
              decoration: InputDecoration(
                labelText: l10n?.salaryInputLabel ?? 'Salário',
                prefixText: 'R\$ ',
                border: const OutlineInputBorder(),
                helperText:
                    l10n?.salaryInputHelper ??
                    'Digite o valor do seu salário mensal',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n?.salaryInputRequired ??
                      'Por favor, insira um valor';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return l10n?.salaryInputInvalid ??
                      'Por favor, insira um valor válido';
                }
                return null;
              },
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_salaryController.text);
              final provider = Provider.of<ProductProvider>(
                context,
                listen: false,
              );
              await provider.setSalary(widget.year, widget.month, amount);
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          child: Text(l10n?.save ?? 'Salvar'),
        ),
      ],
    );
  }
}
