import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/product.dart';

class ImportPreviousMonthDialog extends StatefulWidget {
  final List<Product> previousMonthProducts;

  const ImportPreviousMonthDialog({
    Key? key,
    required this.previousMonthProducts,
  }) : super(key: key);

  @override
  State<ImportPreviousMonthDialog> createState() =>
      _ImportPreviousMonthDialogState();
}

class _ImportPreviousMonthDialogState extends State<ImportPreviousMonthDialog> {
  final Set<String> _selectedProductIds = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Initially select all products
    _selectAll = true;
    _selectedProductIds.addAll(
      widget.previousMonthProducts.map((p) => p.id.toString()),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedProductIds.addAll(
          widget.previousMonthProducts.map((p) => p.id.toString()),
        );
      } else {
        _selectedProductIds.clear();
      }
    });
  }

  void _toggleProduct(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
        _selectAll = false;
      } else {
        _selectedProductIds.add(productId);
        if (_selectedProductIds.length == widget.previousMonthProducts.length) {
          _selectAll = true;
        }
      }
    });
  }

  String _getCategoryName(BuildContext context, ProductCategory category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case ProductCategory.alimentos:
        return l10n?.categoryAlimentos ?? 'Alimentos';
      case ProductCategory.bebidas:
        return l10n?.categoryBebidas ?? 'Bebidas';
      case ProductCategory.tecnologia:
        return l10n?.categoryTecnologia ?? 'Tecnologia';
      case ProductCategory.contasDeCasa:
        return l10n?.categoryContasDeCasa ?? 'Contas de Casa';
      case ProductCategory.higienePessoal:
        return l10n?.categoryHigienePessoal ?? 'Higiene Pessoal';
      case ProductCategory.limpeza:
        return l10n?.categoryLimpeza ?? 'Limpeza';
      case ProductCategory.vestuario:
        return l10n?.categoryVestuario ?? 'Vestuário';
      case ProductCategory.saude:
        return l10n?.categorySaude ?? 'Saúde';
      case ProductCategory.entretenimento:
        return l10n?.categoryEntretenimento ?? 'Entretenimento';
      case ProductCategory.outros:
        return l10n?.categoryOutros ?? 'Outros';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.previousMonthProducts.isEmpty) {
      return AlertDialog(
        title: Text(
          l10n?.importPreviousMonthTitle ?? 'Importar do Mês Anterior',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n?.noPreviousMonthProducts ??
                  'Nenhum produto encontrado no mês anterior',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.close ?? 'Fechar'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(l10n?.importPreviousMonthTitle ?? 'Importar do Mês Anterior'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          maxWidth: double.maxFinite,
        ),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: Text(
                  l10n?.selectAll ?? 'Selecionar Todos',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${widget.previousMonthProducts.length} ${widget.previousMonthProducts.length == 1 ? (l10n?.itemSingular ?? 'item') : (l10n?.itemPlural ?? 'itens')}',
                ),
                value: _selectAll,
                onChanged: (_) => _toggleSelectAll(),
                activeColor: const Color(0xFF2E7D32),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.previousMonthProducts.length,
                  itemBuilder: (context, index) {
                    final product = widget.previousMonthProducts[index];
                    final productId = product.id.toString();
                    final isSelected = _selectedProductIds.contains(productId);

                    return CheckboxListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        '${_getCategoryName(context, product.category)} • ${l10n?.quantityLabel ?? 'Quantidade'}: ${product.quantity}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      value: isSelected,
                      onChanged: (_) => _toggleProduct(productId),
                      activeColor: const Color(0xFF2E7D32),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              _selectedProductIds.isEmpty
                  ? null
                  : () {
                    final selectedProducts =
                        widget.previousMonthProducts
                            .where(
                              (p) =>
                                  _selectedProductIds.contains(p.id.toString()),
                            )
                            .toList();
                    Navigator.of(context).pop(selectedProducts);
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          child: Text(
            '${l10n?.add ?? 'Adicionar'} (${_selectedProductIds.length})',
          ),
        ),
      ],
    );
  }
}
