enum ProductCategory {
  alimentos,
  bebidas,
  tecnologia,
  contasDeCasa,
  higienePessoal,
  limpeza,
  vestuario,
  saude,
  entretenimento,
  outros,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.alimentos:
        return 'Alimentos';
      case ProductCategory.bebidas:
        return 'Bebidas';
      case ProductCategory.tecnologia:
        return 'Tecnologia';
      case ProductCategory.contasDeCasa:
        return 'Contas de Casa';
      case ProductCategory.higienePessoal:
        return 'Higiene Pessoal';
      case ProductCategory.limpeza:
        return 'Limpeza';
      case ProductCategory.vestuario:
        return 'Vestuário';
      case ProductCategory.saude:
        return 'Saúde';
      case ProductCategory.entretenimento:
        return 'Entretenimento';
      case ProductCategory.outros:
        return 'Outros';
    }
  }

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ProductCategory.outros,
    );
  }
}

class Product {
  final int? id;
  final String name;
  final int quantity;
  final ProductCategory category;
  final double? price;
  final String? store;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime? purchasedAt;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.price,
    this.store,
    this.isPurchased = false,
    required this.createdAt,
    this.purchasedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category.toString().split('.').last,
      'price': price,
      'store': store,
      'isPurchased': isPurchased ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'purchasedAt': purchasedAt?.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      category: ProductCategoryExtension.fromString(map['category'] as String),
      price: map['price'] as double?,
      store: map['store'] as String?,
      isPurchased: map['isPurchased'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      purchasedAt:
          map['purchasedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['purchasedAt'] as int)
              : null,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    int? quantity,
    ProductCategory? category,
    double? price,
    String? store,
    bool? isPurchased,
    DateTime? createdAt,
    DateTime? purchasedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      price: price ?? this.price,
      store: store ?? this.store,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt ?? this.createdAt,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}
