import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/purchase_dialog.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                    AppLocalizations.of(context)?.noProductsAdded ??
                        'Nenhum produto adicionado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.addProductsUsingPlus ??
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
                showCheckbox: false,
                showConfirmButton: true,
                onCheckboxChanged: () async {
                  final price = await _showSmoothDialog<double>(
                    context,
                    PurchaseDialog(product: product),
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
                    final l = AppLocalizations.of(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l?.productRemoved ?? 'Produto removido!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onTap: () async {
                  final updatedProduct = await _showSmoothDialog<Product>(
                    context,
                    AddProductDialog(product: product),
                  );

                  if (updatedProduct != null && context.mounted) {
                    await Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).updateProduct(updatedProduct);
                    if (context.mounted) {
                      final l = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l?.productUpdated ?? 'Produto atualizado!',
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF2E7D32),
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
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () async {
          final product = await _showSmoothDialog<Product>(
            context,
            const AddProductDialog(),
          );

          if (product != null && context.mounted) {
            await Provider.of<ProductProvider>(
              context,
              listen: false,
            ).addProduct(product);
            if (context.mounted) {
              final l = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l?.productAdded ?? 'Produto adicionado!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
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
