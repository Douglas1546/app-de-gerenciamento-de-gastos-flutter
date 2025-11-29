import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool showCheckbox;
  final bool showPrice;
  final VoidCallback? onCheckboxChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.product,
    this.showCheckbox = false,
    this.showPrice = false,
    this.onCheckboxChanged,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.alimentos:
        return Colors.green;
      case ProductCategory.bebidas:
        return Colors.blue;
      case ProductCategory.tecnologia:
        return Colors.purple;
      case ProductCategory.contasDeCasa:
        return Colors.orange;
      case ProductCategory.higienePessoal:
        return Colors.pink;
      case ProductCategory.limpeza:
        return Colors.teal;
      case ProductCategory.vestuario:
        return Colors.indigo;
      case ProductCategory.saude:
        return Colors.red;
      case ProductCategory.entretenimento:
        return Colors.amber;
      case ProductCategory.outros:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Dismissible(
        key: Key(product.id.toString()),
        direction:
            onDelete != null
                ? DismissDirection.endToStart
                : DismissDirection.none,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmar'),
                content: const Text('Deseja realmente excluir este produto?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Excluir'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          if (onDelete != null) {
            onDelete!();
          }
        },
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(16),
          leading:
              showCheckbox
                  ? Checkbox(
                    value: product.isPurchased,
                    activeColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (bool? value) {
                      if (onCheckboxChanged != null) {
                        onCheckboxChanged!();
                      }
                    },
                  )
                  : Icon(
                    Icons.shopping_bag_outlined,
                    color: _getCategoryColor(product.category),
                    size: 28,
                  ),
          title: Text(
            product.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      product.category,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.category.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getCategoryColor(product.category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Qtd: ${product.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showPrice && product.price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.quantity > 1
                          ? '${currency.format(product.price! / product.quantity)} un. • ${currency.format(product.price!)}'
                          : currency.format(product.price!),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                if (product.purchasedAt != null)
                  Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                      'pt_BR',
                    ).format(product.purchasedAt!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          trailing:
              onDelete != null
                  ? IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Excluir',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text(
                              'Deseja realmente excluir este produto?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmed == true && onDelete != null) {
                        onDelete!();
                      }
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}
