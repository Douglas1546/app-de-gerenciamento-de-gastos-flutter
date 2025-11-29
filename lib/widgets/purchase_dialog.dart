import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class PurchaseDialog extends StatefulWidget {
  final Product product;

  const PurchaseDialog({Key? key, required this.product}) : super(key: key);

  @override
  State<PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<PurchaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _priceController.removeListener(_updateTotal);
    _priceController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final text = _priceController.text.replaceAll(',', '.');
    final unitPrice = double.tryParse(text) ?? 0.0;
    setState(() {
      _totalPrice = unitPrice * widget.product.quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return AlertDialog(
      title: const Text('Confirmar Compra'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produto: ${widget.product.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quantidade: ${widget.product.quantity}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preço Unitário (R\$)',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o preço';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Preço inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    currency.format(_totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final unitPrice = double.parse(_priceController.text.replaceAll(',', '.'));
              Navigator.of(context).pop(unitPrice);
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
