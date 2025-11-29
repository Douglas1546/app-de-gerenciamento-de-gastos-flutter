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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _quantityController =
        TextEditingController(text: widget.product?.quantity.toString() ?? '');
    
    // Calculate unit price if product exists and has price
    String initialPrice = '';
    if (widget.product?.price != null && widget.product!.quantity > 0) {
      final unitPrice = widget.product!.price! / widget.product!.quantity;
      initialPrice = unitPrice.toStringAsFixed(2).replaceAll('.', ',');
    }
    
    _priceController = TextEditingController(text: initialPrice);
    _selectedCategory = widget.product?.category ?? ProductCategory.alimentos;
  }

  @override
  void dispose() {
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
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
              if (isPurchased) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Preço Unitário (R\$)',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  // Add input formatter for comma support if needed, but simple validation works too
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
                items: ProductCategory.values.map((category) {
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
                final unitPrice = double.parse(_priceController.text.replaceAll(',', '.'));
                price = unitPrice * quantity;
              } else {
                price = widget.product?.price;
              }

              final product = isEditing
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
