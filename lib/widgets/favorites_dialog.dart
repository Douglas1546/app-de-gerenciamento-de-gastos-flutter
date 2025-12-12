import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class FavoritesDialog extends StatefulWidget {
  const FavoritesDialog({Key? key}) : super(key: key);

  @override
  State<FavoritesDialog> createState() => _FavoritesDialogState();
}

class _FavoritesDialogState extends State<FavoritesDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _mostPurchased = [];
  bool _isLoadingMostPurchased = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMostPurchased();
  }

  Future<void> _loadMostPurchased() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final mostPurchased = await provider.getMostPurchasedProducts(limit: 20);
    setState(() {
      _mostPurchased = mostPurchased;
      _isLoadingMostPurchased = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.alimentos:
        return const Color(0xFF4CAF50);
      case ProductCategory.bebidas:
        return const Color(0xFF2196F3);
      case ProductCategory.tecnologia:
        return const Color(0xFF9C27B0);
      case ProductCategory.contasDeCasa:
        return const Color(0xFFFF9800);
      case ProductCategory.higienePessoal:
        return const Color(0xFFE91E63);
      case ProductCategory.limpeza:
        return const Color(0xFF00BCD4);
      case ProductCategory.vestuario:
        return const Color(0xFF673AB7);
      case ProductCategory.saude:
        return const Color(0xFFF44336);
      case ProductCategory.entretenimento:
        return const Color(0xFFFF5722);
      case ProductCategory.outros:
        return Colors.grey;
    }
  }

  String _categoryName(ProductCategory category, AppLocalizations? l) {
    switch (category) {
      case ProductCategory.alimentos:
        return l?.categoryAlimentos ?? 'Alimentos';
      case ProductCategory.bebidas:
        return l?.categoryBebidas ?? 'Bebidas';
      case ProductCategory.tecnologia:
        return l?.categoryTecnologia ?? 'Tecnologia';
      case ProductCategory.contasDeCasa:
        return l?.categoryContasDeCasa ?? 'Contas de Casa';
      case ProductCategory.higienePessoal:
        return l?.categoryHigienePessoal ?? 'Higiene Pessoal';
      case ProductCategory.limpeza:
        return l?.categoryLimpeza ?? 'Limpeza';
      case ProductCategory.vestuario:
        return l?.categoryVestuario ?? 'Vestuário';
      case ProductCategory.saude:
        return l?.categorySaude ?? 'Saúde';
      case ProductCategory.entretenimento:
        return l?.categoryEntretenimento ?? 'Entretenimento';
      case ProductCategory.outros:
        return l?.categoryOutros ?? 'Outros';
    }
  }

  Future<void> _addProduct(
    String name,
    ProductCategory category, {
    double? price,
    String? store,
  }) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final product = Product(
      name: name,
      quantity: 1,
      category: category,
      price: price,
      store: store,
      createdAt: DateTime.now(),
    );
    await provider.addProduct(product);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.productAdded ?? 'Produto adicionado!',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l?.addFromFavorites ?? 'Adicionar dos Favoritos',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2E7D32),
              tabs: [
                Tab(
                  icon: const Icon(Icons.star),
                  text: l?.favorites ?? 'Favoritos',
                ),
                Tab(
                  icon: const Icon(Icons.trending_up),
                  text: l?.mostPurchased ?? 'Mais Comprados',
                ),
              ],
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Favoritos
                  _buildFavoritesList(),
                  // Mais Comprados
                  _buildMostPurchasedList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    final l = AppLocalizations.of(context);
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final favorites = provider.favoriteProducts;

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l?.noFavorites ?? 'Nenhum favorito ainda',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  l?.noFavoritesHint ??
                      'Marque produtos como favoritos para acesso rápido',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final product = favorites[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(
                    product.category,
                  ).withOpacity(0.2),
                  child: Icon(
                    Icons.shopping_basket,
                    color: _getCategoryColor(product.category),
                    size: 20,
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_categoryName(product.category, l)),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
                  onPressed:
                      () => _addProduct(
                        product.name,
                        product.category,
                        price: product.price,
                        store: product.store,
                      ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMostPurchasedList() {
    final l = AppLocalizations.of(context);

    if (_isLoadingMostPurchased) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mostPurchased.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l?.noMostPurchased ?? 'Nenhum histórico ainda',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _mostPurchased.length,
      itemBuilder: (context, index) {
        final item = _mostPurchased[index];
        final category = item['category'] as ProductCategory;
        final count = item['count'] as int;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(category).withOpacity(0.2),
              child: Icon(
                Icons.shopping_basket,
                color: _getCategoryColor(category),
                size: 20,
              ),
            ),
            title: Text(
              item['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${_categoryName(category, l)} • $count ${count == 1 ? (l?.timesSingular ?? 'vez') : (l?.timesPlural ?? 'vezes')}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
              onPressed:
                  () => _addProduct(
                    item['name'] as String,
                    category,
                    price: item['lastPrice'] as double?,
                    store: item['lastStore'] as String?,
                  ),
            ),
          ),
        );
      },
    );
  }
}
