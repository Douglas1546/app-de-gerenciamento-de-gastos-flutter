import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/purchase_dialog.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';

class ToBuyTab extends StatelessWidget {
  const ToBuyTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final products = provider.productsToBuy;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto adicionado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione produtos usando o botão +',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                showCheckbox: true,
                onCheckboxChanged: () async {
                  final price = await showDialog<double>(
                    context: context,
                    builder: (context) => PurchaseDialog(product: product),
                  );

                  if (price != null && context.mounted) {
                    final totalPrice = price * product.quantity;
                    await Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).purchaseProduct(product, totalPrice);
                  }
                },
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
                    builder: (context) => AddProductDialog(product: product),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () async {
          final product = await showDialog(
            context: context,
            builder: (context) => const AddProductDialog(),
          );

          if (product != null && context.mounted) {
            await Provider.of<ProductProvider>(
              context,
              listen: false,
            ).addProduct(product);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produto adicionado!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF3B82F6),
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
