import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import '../widgets/add_product_dialog.dart';

class PurchasedTab extends StatelessWidget {
  const PurchasedTab({Key? key}) : super(key: key);

  String _getFilterLabel(PurchasedFilter filter) {
    switch (filter) {
      case PurchasedFilter.all:
        return 'Todos';
      case PurchasedFilter.today:
        return 'Hoje';
      case PurchasedFilter.thisMonth:
        return 'Este Mês';
      case PurchasedFilter.thisYear:
        return 'Este Ano';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final products = provider.purchasedProducts;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              color: const Color.fromARGB(137, 255, 255, 255),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children:
                      PurchasedFilter.values.map((filter) {
                        final isSelected = provider.currentFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getFilterLabel(filter)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                provider.setFilter(filter);
                              }
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: const Color(0xFF2E7D32),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Expanded(
              child:
                  products.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum produto comprado',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Produtos comprados aparecerão aqui',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            showPrice: true,
                            onDelete: () async {
                              await Provider.of<ProductProvider>(
                                context,
                                listen: false,
                              ).deleteProduct(product.id!);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Produto removido!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            onTap: () async {
                              final updatedProduct = await showDialog<Product>(
                                context: context,
                                builder:
                                    (context) =>
                                        AddProductDialog(product: product),
                              );

                              if (updatedProduct != null && context.mounted) {
                                await Provider.of<ProductProvider>(
                                  context,
                                  listen: false,
                                ).updateProduct(updatedProduct);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Produto atualizado!'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Color(0xFF2E7D32),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}
