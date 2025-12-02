import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final _priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updateTotal);
    _priceFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _priceController.removeListener(_updateTotal);
    _priceController.dispose();
    _priceFocus.dispose();
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
    String _currentLocale() {
      final name =
          AppLocalizations.of(context)?.localeName ??
          Localizations.localeOf(context).toLanguageTag();
      if (name == 'zh_Hans' || name == 'zh-Hans') return 'zh_CN';
      if (name == 'zh_Hant' || name == 'zh-Hant') return 'zh_TW';
      return name.replaceAll('-', '_');
    }

    String _symbolForLocale(String loc) {
      switch (loc) {
        case 'pt_BR':
          return 'R\$';
        case 'pt':
          return '€';
        case 'en':
        case 'en_US':
          return '\$';
        case 'es':
        case 'fr':
        case 'de':
        case 'it':
          return '€';
        case 'ja':
          return '¥';
        case 'ko':
          return '₩';
        case 'pl':
          return 'zł';
        case 'ru':
          return '₽';
        case 'zh_CN':
          return '¥';
        case 'zh_TW':
          return 'NT\$';
        default:
          return NumberFormat.simpleCurrency(locale: loc).currencySymbol;
      }
    }

    final currLocale = _currentLocale();
    final currencySymbol = _symbolForLocale(currLocale);
    final currency = NumberFormat.currency(
      locale: currLocale,
      symbol: currencySymbol,
    );
    bool _symbolIsPrefix() {
      final sample = NumberFormat.currency(
        locale: currLocale,
        symbol: currencySymbol,
      ).format(1);
      return sample.trim().startsWith(currencySymbol);
    }

    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l?.confirmPurchaseTitle ?? 'Confirmar Compra'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l?.productLabel ?? 'Produto:'} ${widget.product.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${l?.quantityLabel ?? 'Quantidade'}: ${widget.product.quantity}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow:
                    _priceFocus.hasFocus
                        ? [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: TextFormField(
                controller: _priceController,
                focusNode: _priceFocus,
                decoration: InputDecoration(
                  labelText: l?.unitPriceLabel ?? 'Preço Unitário',
                  border: const OutlineInputBorder(),
                  prefixText: _symbolIsPrefix() ? '$currencySymbol ' : null,
                  suffixText: _symbolIsPrefix() ? null : ' $currencySymbol',
                  // prefixIcon: const Icon(Icons.attach_money_outlined),
                  hintText: l?.unitPriceHint ?? 'Use vírgula para centavos',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+([.,]\d{0,2})?'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l?.priceRequired ?? 'Por favor, insira o preço';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return l?.priceInvalid ?? 'Preço inválido';
                  }
                  return null;
                },
              ),
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
                  Text(
                    l?.totalLabel ?? 'Total:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: Text(
                      currency.format(_totalPrice),
                      key: ValueKey(_totalPrice.toStringAsFixed(2)),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2E7D32),
                      ),
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
          child: Text(l?.cancel ?? 'Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final unitPrice = double.parse(
                _priceController.text.replaceAll(',', '.'),
              );
              Navigator.of(context).pop(unitPrice);
            }
          },
          child: Text(l?.confirm ?? 'Confirmar'),
        ),
      ],
    );
  }
}
