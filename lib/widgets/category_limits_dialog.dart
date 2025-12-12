import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class CategoryLimitsDialog extends StatefulWidget {
  final int year;
  final int month;

  const CategoryLimitsDialog({
    Key? key,
    required this.year,
    required this.month,
  }) : super(key: key);

  @override
  State<CategoryLimitsDialog> createState() => _CategoryLimitsDialogState();
}

class _CategoryLimitsDialogState extends State<CategoryLimitsDialog> {
  final Map<ProductCategory, TextEditingController> _controllers = {};
  final Map<ProductCategory, double?> _limits = {};
  bool _isLoading = true;
  double? _salary;

  @override
  void initState() {
    super.initState();
    _loadLimits();
    _loadSalary();
  }

  Future<void> _loadLimits() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final limits = await provider.getCategoryLimits(widget.year, widget.month);

    setState(() {
      for (var category in ProductCategory.values) {
        final categoryStr = category.toString().split('.').last;
        final limit = limits[categoryStr];
        _limits[category] = limit;
        _controllers[category] = TextEditingController(
          text:
              limit != null
                  ? limit.toStringAsFixed(2).replaceAll('.', ',')
                  : '',
        );
        // Add listener to update total when text changes
        _controllers[category]!.addListener(() {
          setState(() {});
        });
      }
      _isLoading = false;
    });
  }

  Future<void> _loadSalary() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final salary = await provider.getSalary(widget.year, widget.month);
    setState(() {
      _salary = salary;
    });
  }

  double _calculateTotalLimits() {
    double total = 0.0;
    for (var controller in _controllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        final value = double.tryParse(text.replaceAll(',', '.'));
        if (value != null && value > 0) {
          total += value;
        }
      }
    }
    return total;
  }

  String _dateLocale() {
    final name =
        AppLocalizations.of(context)?.localeName ??
        Localizations.localeOf(context).toLanguageTag();
    if (name == 'zh_Hans' || name == 'zh-Hans') return 'zh_CN';
    if (name == 'zh_Hant' || name == 'zh-Hant') return 'zh_TW';
    return name.replaceAll('-', '_');
  }

  String _currencySymbol() {
    final name =
        AppLocalizations.of(context)?.localeName ??
        Localizations.localeOf(context).toLanguageTag();
    final loc =
        (name == 'zh_Hans' || name == 'zh-Hans')
            ? 'zh_CN'
            : (name == 'zh_Hant' || name == 'zh-Hant')
            ? 'zh_TW'
            : name.replaceAll('-', '_');
    switch (loc) {
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
        return NumberFormat.simpleCurrency(locale: loc).currencySymbol;
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
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

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.alimentos:
        return Colors.green;
      case ProductCategory.bebidas:
        return Colors.blue;
      case ProductCategory.tecnologia:
        return Colors.purple;
      case ProductCategory.contasDeCasa:
        return Colors.orange;
      case ProductCategory.higienePessoal:
        return Colors.pink;
      case ProductCategory.limpeza:
        return Colors.teal;
      case ProductCategory.vestuario:
        return Colors.indigo;
      case ProductCategory.saude:
        return Colors.red;
      case ProductCategory.entretenimento:
        return Colors.amber;
      case ProductCategory.outros:
        return Colors.grey;
    }
  }

  Future<void> _saveLimits() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final l = AppLocalizations.of(context);

    for (var category in ProductCategory.values) {
      final text = _controllers[category]!.text.trim();
      final categoryStr = category.toString().split('.').last;

      if (text.isEmpty) {
        // Remove limit if empty
        if (_limits[category] != null) {
          await provider.deleteCategoryLimit(
            widget.year,
            widget.month,
            categoryStr,
          );
        }
      } else {
        // Save limit
        final value = double.tryParse(text.replaceAll(',', '.'));
        if (value != null && value > 0) {
          await provider.setCategoryLimit(
            widget.year,
            widget.month,
            categoryStr,
            value,
          );
        }
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l?.categoryLimitsSaved ?? 'Limites salvos!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = NumberFormat.currency(
      locale: _dateLocale(),
      symbol: _currencySymbol(),
    );
    final totalLimits = _calculateTotalLimits();
    final exceedsSalary = _salary != null && totalLimits > _salary!;

    return AlertDialog(
      title: Text(l?.categoryLimitsTitle ?? 'Limites por Categoria'),
      content:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Budget Summary Card
                    if (_salary != null || totalLimits > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color:
                              exceedsSalary
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: exceedsSalary ? Colors.red : Colors.blue,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    l?.totalLimitsLabel ?? 'Total dos Limites:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currency.format(totalLimits),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        exceedsSalary
                                            ? Colors.red
                                            : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            if (_salary != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      l?.salaryLabel ?? 'Salário:',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currency.format(_salary),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (exceedsSalary)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l?.limitsExceedSalaryWarning ??
                                            'Os limites excedem o salário!',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l?.limitsWithinSalary ??
                                            'Limites dentro do salário',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ],
                        ),
                      ),
                    // Category List
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: ProductCategory.values.length,
                        itemBuilder: (context, index) {
                          final category = ProductCategory.values[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getCategoryColor(
                                    category,
                                  ).withOpacity(0.2),
                                  radius: 20,
                                  child: Icon(
                                    Icons.category,
                                    color: _getCategoryColor(category),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _controllers[category],
                                    decoration: InputDecoration(
                                      labelText: _categoryName(category, l),
                                      hintText: '0,00',
                                      prefixText: '${_currencySymbol()} ',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                      helperText:
                                          l?.categoryLimitHelper ??
                                          'Deixe vazio para sem limite',
                                      helperStyle: const TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9,.]'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l?.cancel ?? 'Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveLimits,
          child: Text(l?.save ?? 'Salvar'),
        ),
      ],
    );
  }
}
