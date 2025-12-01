import 'package:flutter/material.dart';
import '../models/product.dart';

class AddProductDialog extends StatefulWidget {
  final Product? product;

  const AddProductDialog({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late ProductCategory _selectedCategory;
  late FocusNode _nameFocus;
  late FocusNode _quantityFocus;
  late FocusNode _priceFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '',
    );

    // Calculate unit price if product exists and has price
    String initialPrice = '';
    if (widget.product?.price != null && widget.product!.quantity > 0) {
      final unitPrice = widget.product!.price! / widget.product!.quantity;
      initialPrice = unitPrice.toStringAsFixed(2).replaceAll('.', ',');
    }

    _priceController = TextEditingController(text: initialPrice);
    _selectedCategory = widget.product?.category ?? ProductCategory.alimentos;
    _nameFocus = FocusNode()..addListener(() => setState(() {}));
    _quantityFocus = FocusNode()..addListener(() => setState(() {}));
    _priceFocus = FocusNode()..addListener(() => setState(() {}));
    _nameController.addListener(() => setState(() {}));
    _quantityController.addListener(() => setState(() {}));
    _priceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _quantityFocus.dispose();
    _priceFocus.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final isPurchased = widget.product?.isPurchased ?? false;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Produto' : 'Adicionar Produto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      _nameFocus.hasFocus
                          ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : [],
                ),
                child: TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(
                    labelText: 'Nome do Produto',
                    border: const OutlineInputBorder(),
                    hintText: 'Ex.: Arroz, Feijão',
                    suffixIcon:
                        _nameController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _nameController.clear();
                              },
                            )
                            : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do produto';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      _quantityFocus.hasFocus
                          ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : [],
                ),
                child: TextFormField(
                  controller: _quantityController,
                  focusNode: _quantityFocus,
                  decoration: InputDecoration(
                    labelText: 'Quantidade',
                    border: const OutlineInputBorder(),
                    suffixIcon: SizedBox(
                      width: 96,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              final current =
                                  int.tryParse(_quantityController.text) ?? 1;
                              final next = current > 1 ? current - 1 : 1;
                              _quantityController.text = next.toString();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              final current =
                                  int.tryParse(_quantityController.text) ?? 1;
                              _quantityController.text =
                                  (current + 1).toString();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a quantidade';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Quantidade deve ser um número válido';
                    }
                    return null;
                  },
                ),
              ),
              if (isPurchased) ...[
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow:
                        _priceFocus.hasFocus
                            ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.12),
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
                      labelText: 'Preço Unitário (R\$)',
                      border: const OutlineInputBorder(),
                      prefixText: 'R\$ ',
                      hintText: 'Use vírgula para centavos',
                      suffixIcon:
                          _priceController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _priceController.clear();
                                },
                              )
                              : null,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o preço';
                      }
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Preço inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                menuMaxHeight: 300,
                items:
                    ProductCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text;
              final quantity = int.parse(_quantityController.text);

              double? price;
              if (isPurchased) {
                final unitPrice = double.parse(
                  _priceController.text.replaceAll(',', '.'),
                );
                price = unitPrice * quantity;
              } else {
                price = widget.product?.price;
              }

              final product =
                  isEditing
                      ? widget.product!.copyWith(
                        name: name,
                        quantity: quantity,
                        category: _selectedCategory,
                        price: price,
                      )
                      : Product(
                        name: name,
                        quantity: quantity,
                        category: _selectedCategory,
                        createdAt: DateTime.now(),
                      );
              Navigator.of(context).pop(product);
            }
          },
          child: Text(isEditing ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }
}
