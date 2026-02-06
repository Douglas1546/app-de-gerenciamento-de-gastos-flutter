import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/selection_provider.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import '../widgets/add_product_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PurchasedTab extends StatefulWidget {
  const PurchasedTab({Key? key}) : super(key: key);

  @override
  State<PurchasedTab> createState() => _PurchasedTabState();
}

class _PurchasedTabState extends State<PurchasedTab> {
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.setSearchQueryPurchased(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    // Limpa o modo de seleção ao sair da tela
    if (_isSelectionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SelectionProvider>().exitSelectionMode();
          // Clear search query when leaving tab
          context.read<ProductProvider>().setSearchQueryPurchased('');
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
    final products = provider.purchasedProducts;
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

  String _getFilterLabel(BuildContext context, PurchasedFilter filter) {
    final l = AppLocalizations.of(context);
    switch (filter) {
      case PurchasedFilter.all:
        return l?.filterAll ?? 'Todos';
      case PurchasedFilter.today:
        return l?.filterToday ?? 'Hoje';
      case PurchasedFilter.thisMonth:
        return l?.filterThisMonth ?? 'Este Mês';
      case PurchasedFilter.thisYear:
        return l?.filterThisYear ?? 'Este Ano';
      case PurchasedFilter.specificDay:
        return l?.filterSpecificDay ?? 'Dia';
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
          final products = provider.purchasedProducts;

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : const Color.fromARGB(137, 255, 255, 255),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.searchProducts ??
                        'Pesquisar produtos',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              // Filter Chips
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : const Color.fromARGB(137, 255, 255, 255),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children:
                        [
                          PurchasedFilter.all,
                          PurchasedFilter.today,
                          PurchasedFilter.specificDay,
                          PurchasedFilter.thisMonth,
                          PurchasedFilter.thisYear,
                        ].map((filter) {
                          final isSelected = provider.currentFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_getFilterLabel(context, filter)),
                              selected: isSelected,
                              onSelected: (_) async {
                                if (filter == PurchasedFilter.specificDay) {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        provider.selectedDayFilter ??
                                        DateTime.now(),
                                    firstDate: DateTime(2000, 1, 1),
                                    lastDate: DateTime(2100, 12, 31),
                                  );
                                  if (picked != null) {
                                    provider.setFilterDay(picked);
                                  } else {
                                    if (provider.selectedDayFilter != null) {
                                      provider.setFilter(
                                        PurchasedFilter.specificDay,
                                      );
                                    }
                                  }
                                } else {
                                  provider.setFilter(filter);
                                }
                              },
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.grey[200],
                              selectedColor: const Color(0xFF2E7D32),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black87),
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
                                AppLocalizations.of(
                                      context,
                                    )?.noPurchasedProducts ??
                                    'Nenhum produto comprado',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )?.purchasedProductsAppearHere ??
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
                            final isSelected = _selectedIds.contains(
                              product.id,
                            );

                            return ProductCard(
                              product: product,
                              showPrice: true,
                              isSelectionMode: _isSelectionMode,
                              isSelected: isSelected,
                              onSelectionToggle:
                                  () => _toggleSelection(product.id!),
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedIds.add(product.id!);
                                  });
                                  _updateSelectionProvider();
                                }
                              },
                              onFavoriteToggle: () async {
                                await Provider.of<ProductProvider>(
                                  context,
                                  listen: false,
                                ).toggleFavorite(product.id!);
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
                                      content: Text(
                                        l?.productRemoved ??
                                            'Produto removido!',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              onTap: () async {
                                final updatedProduct =
                                    await _showSmoothDialog<Product>(
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
                                          l?.productUpdated ??
                                              'Produto atualizado!',
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: const Color(
                                          0xFF2E7D32,
                                        ),
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
      ),
      floatingActionButton:
          _isSelectionMode
              ? const SizedBox.shrink()
              : FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: _toggleSelectionMode,
                child: const Icon(Icons.close, color: Colors.white),
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
