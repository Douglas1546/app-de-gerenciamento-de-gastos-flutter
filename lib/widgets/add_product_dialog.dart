import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

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
  late TextEditingController _storeController;
  late ProductCategory _selectedCategory;
  late FocusNode _nameFocus;
  late FocusNode _quantityFocus;
  late FocusNode _priceFocus;
  late FocusNode _storeFocus;

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
    _storeController = TextEditingController(text: widget.product?.store ?? '');
    _selectedCategory = widget.product?.category ?? ProductCategory.alimentos;
    _nameFocus = FocusNode()..addListener(() => setState(() {}));
    _quantityFocus = FocusNode()..addListener(() => setState(() {}));
    _priceFocus = FocusNode()..addListener(() => setState(() {}));
    _storeFocus = FocusNode()..addListener(() => setState(() {}));
    _nameController.addListener(() => setState(() {}));
    _quantityController.addListener(() => setState(() {}));
    _priceController.addListener(() => setState(() {}));
    _storeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _quantityFocus.dispose();
    _priceFocus.dispose();
    _storeFocus.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final isPurchased = widget.product?.isPurchased ?? false;

    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        isEditing
            ? (l?.editProductTitle ?? 'Editar Produto')
            : (l?.addProductTitle ?? 'Adicionar Produto'),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8),
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
                              color: const Color(0xFF2E7D32).withOpacity(0.12),
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
                    labelText: l?.productNameLabel ?? 'Nome do Produto',
                    border: const OutlineInputBorder(),
                    hintText: l?.productNameHint ?? 'Ex.: Arroz, Feijão',
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
                      return l?.productNameRequired ??
                          'Por favor, insira o nome do produto';
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
                              color: const Color(0xFF2E7D32).withOpacity(0.12),
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
                    labelText: l?.quantityLabel ?? 'Quantidade',
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
                                  int.tryParse(_quantityController.text) ?? 0;
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
                      return l?.quantityRequired ??
                          'Por favor, insira a quantidade';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return l?.quantityInvalid ??
                          'Quantidade deve ser um número válido';
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
                                  0xFF2E7D32,
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
                      labelText: l?.unitPriceLabel ?? 'Preço Unitário',
                      border: const OutlineInputBorder(),
                      prefixText:
                          _isCurrencyPrefix(context)
                              ? _currencySymbol(context)
                              : null,
                      suffixText:
                          _isCurrencyPrefix(context)
                              ? null
                              : _currencySymbol(context).trim().isEmpty
                              ? null
                              : ' ${_currencySymbol(context).trim()}',
                      hintText: l?.unitPriceHint ?? 'Use vírgula para centavos',
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
                        return l?.priceRequired ?? 'Por favor, insira o preço';
                      }
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return l?.priceInvalid ?? 'Preço inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    final allStores = provider.getAllStores();

                    if (allStores.isEmpty) {
                      return TextFormField(
                        controller: _storeController,
                        focusNode: _storeFocus,
                        decoration: InputDecoration(
                          labelText: l?.storeLabel ?? 'Loja (opcional)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.store_outlined),
                          hintText: l?.storeHint ?? 'Ex: Mercado X, Farmácia Y',
                        ),
                        textCapitalization: TextCapitalization.words,
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<String>(
                          initialValue: TextEditingValue(
                            text: _storeController.text,
                          ),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return allStores;
                            }
                            return allStores.where((String store) {
                              return store.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                            });
                          },
                          onSelected: (String selection) {
                            _storeController.text = selection;
                          },
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            if (_storeController.text.isNotEmpty &&
                                fieldTextEditingController.text.isEmpty) {
                              fieldTextEditingController.text =
                                  _storeController.text;
                            }

                            fieldTextEditingController.addListener(() {
                              _storeController.text =
                                  fieldTextEditingController.text;
                            });

                            return TextFormField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              decoration: InputDecoration(
                                labelText: l?.storeLabel ?? 'Loja (opcional)',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.store_outlined),
                                hintText:
                                    l?.storeHint ?? 'Ex: Mercado X, Farmácia Y',
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                              textCapitalization: TextCapitalization.words,
                              onFieldSubmitted: (String value) {
                                onFieldSubmitted();
                              },
                            );
                          },
                          optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(8),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: constraints.maxWidth,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final String option = options.elementAt(
                                        index,
                                      );
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(
                                          Icons.store,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                        title: Text(
                                          option,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        onTap: () {
                                          onSelected(option);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l?.categoryLabel ?? 'Categoria',
                  border: const OutlineInputBorder(),
                ),
                isExpanded: true,
                menuMaxHeight: 300,
                items:
                    ProductCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_localizedCategoryName(context, category)),
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
          child: Text(l?.cancel ?? 'Cancelar'),
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

              final store =
                  _storeController.text.trim().isEmpty
                      ? null
                      : _storeController.text.trim();

              final product =
                  isEditing
                      ? widget.product!.copyWith(
                        name: name,
                        quantity: quantity,
                        category: _selectedCategory,
                        price: price,
                        store: store,
                      )
                      : Product(
                        name: name,
                        quantity: quantity,
                        category: _selectedCategory,
                        store: store,
                        createdAt: DateTime.now(),
                      );
              Navigator.of(context).pop(product);
            }
          },
          child: Text(
            isEditing ? (l?.save ?? 'Salvar') : (l?.add ?? 'Adicionar'),
          ),
        ),
      ],
    );
  }

  String _localizedCategoryName(
    BuildContext context,
    ProductCategory category,
  ) {
    final l = AppLocalizations.of(context);
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

  String _currencySymbol(BuildContext context) {
    final name =
        AppLocalizations.of(context)?.localeName ??
        Localizations.localeOf(context).toLanguageTag();
    final locale =
        (name == 'zh_Hans' || name == 'zh-Hans')
            ? 'zh_CN'
            : (name == 'zh_Hant' || name == 'zh-Hant')
            ? 'zh_TW'
            : name.replaceAll('-', '_');
    switch (locale) {
      case 'pt_BR':
        return 'R\$';
      case 'pt':
        return '€';
      case 'en':
      case 'en_US':
        return '\$';
      case 'es':
      case 'fr':
      case 'de':
      case 'it':
        return '€';
      case 'ja':
        return '¥';
      case 'ko':
        return '₩';
      case 'pl':
        return 'zł';
      case 'ru':
        return '₽';
      case 'zh_CN':
        return '¥';
      case 'zh_TW':
        return 'NT\$';
      default:
        return NumberFormat.simpleCurrency(locale: locale).currencySymbol;
    }
  }

  bool _isCurrencyPrefix(BuildContext context) {
    final name =
        AppLocalizations.of(context)?.localeName ??
        Localizations.localeOf(context).toLanguageTag();
    final locale =
        (name == 'zh_Hans' || name == 'zh-Hans')
            ? 'zh_CN'
            : (name == 'zh_Hant' || name == 'zh-Hant')
            ? 'zh_TW'
            : name.replaceAll('-', '_');
    final symbol = _currencySymbol(context);
    final sample = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
    ).format(1);
    return sample.trim().startsWith(symbol);
  }
}
