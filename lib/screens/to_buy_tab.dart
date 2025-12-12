import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/selection_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/purchase_dialog.dart';
import '../widgets/product_card.dart';
import '../widgets/import_previous_month_dialog.dart';
import '../models/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ToBuyTab extends StatefulWidget {
  const ToBuyTab({Key? key}) : super(key: key);

  @override
  State<ToBuyTab> createState() => _ToBuyTabState();
}

class _ToBuyTabState extends State<ToBuyTab> {
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void dispose() {
    // Limpa o modo de seleção ao sair da tela
    if (_isSelectionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SelectionProvider>().exitSelectionMode();
        }
      });
    }
    super.dispose();
  }

  void _checkSelectionMode() {
    // Verifica se o modo de seleção foi desativado externamente
    final selectionProvider = context.read<SelectionProvider>();
    if (!selectionProvider.isSelectionMode && _isSelectionMode) {
      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
        context.read<SelectionProvider>().exitSelectionMode();
      } else {
        _updateSelectionProvider();
      }
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _updateSelectionProvider();
    });
  }

  void _selectAll() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final products = provider.productsToBuy;
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(products.map((p) => p.id!));
    });
    _updateSelectionProvider();
  }

  void _updateSelectionProvider() {
    if (_isSelectionMode) {
      context.read<SelectionProvider>().enterSelectionMode(
        count: _selectedIds.length,
        onDelete: () => _deleteSelected(context),
        onCancel: _toggleSelectionMode,
        onSelectAll: _selectAll,
      );
    }
  }

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.deleteConfirmTitle ??
                  'Confirmar exclusão',
            ),
            content: Text(
              '${AppLocalizations.of(context)?.deleteMultipleConfirmMessage ?? 'Deseja excluir'} ${_selectedIds.length} ${_selectedIds.length == 1 ? (AppLocalizations.of(context)?.itemSingular ?? 'item') : (AppLocalizations.of(context)?.itemPlural ?? 'itens')}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)?.delete ?? 'Excluir'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      for (final id in _selectedIds) {
        await provider.deleteProduct(id);
      }
      setState(() {
        _selectedIds.clear();
        // Mantém o modo de seleção ativo
      });
      _updateSelectionProvider();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.itemsDeleted ?? 'Itens excluídos!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o modo de seleção foi desativado externamente
    _checkSelectionMode();

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
              final isSelected = _selectedIds.contains(product.id);

              return ProductCard(
                product: product,
                showCheckbox: _isSelectionMode,
                showConfirmButton: !_isSelectionMode,
                isSelectionMode: _isSelectionMode,
                isSelected: isSelected,
                onSelectionToggle: () => _toggleSelection(product.id!),
                onLongPress: () {
                  if (!_isSelectionMode) {
                    setState(() {
                      _isSelectionMode = true;
                      _selectedIds.add(product.id!);
                    });
                    _updateSelectionProvider();
                  }
                },
                onCheckboxChanged: () async {
                  final result = await _showSmoothDialog<Map<String, dynamic>>(
                    context,
                    PurchaseDialog(product: product),
                  );

                  if (result != null && context.mounted) {
                    final unitPrice = result['price'] as double;
                    final store = result['store'] as String?;
                    final totalPrice = unitPrice * product.quantity;
                    await Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).purchaseProduct(product, totalPrice, store);
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
      floatingActionButton:
          _isSelectionMode
              ? const SizedBox.shrink()
              : Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  final previousMonthProducts =
                      provider.getPreviousMonthProducts();

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Delete selection button
                      FloatingActionButton(
                        heroTag: 'delete_selection_button',
                        backgroundColor: Colors.red,
                        onPressed: _toggleSelectionMode,
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      // Import from previous month button
                      if (previousMonthProducts.isNotEmpty)
                        FloatingActionButton(
                          heroTag: 'import_button',
                          backgroundColor: const Color(0xFF2E7D32),
                          onPressed: () async {
                            final selectedProducts =
                                await _showSmoothDialog<List<Product>>(
                                  context,
                                  ImportPreviousMonthDialog(
                                    previousMonthProducts:
                                        previousMonthProducts,
                                  ),
                                );

                            if (selectedProducts != null &&
                                selectedProducts.isNotEmpty &&
                                context.mounted) {
                              await Provider.of<ProductProvider>(
                                context,
                                listen: false,
                              ).addProductsFromPreviousMonth(selectedProducts);

                              if (context.mounted) {
                                final l = AppLocalizations.of(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${l?.productsImported ?? 'Produtos importados'}: ${selectedProducts.length}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF2E7D32),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Icon(Icons.history, color: Colors.white),
                        ),
                      if (previousMonthProducts.isNotEmpty)
                        const SizedBox(height: 16),
                      // Add product button
                      FloatingActionButton(
                        heroTag: 'add_button',
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
                                  content: Text(
                                    l?.productAdded ?? 'Produto adicionado!',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: const Color(0xFF2E7D32),
                                ),
                              );
                            }
                          }
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  );
                },
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
