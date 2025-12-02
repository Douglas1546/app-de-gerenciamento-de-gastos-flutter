import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({Key? key}) : super(key: key);

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  late int _selectedYear;
  late int _selectedMonth;
  late DateTime _selectedDate;
  bool _isDaily = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDate = DateTime(now.year, now.month, now.day);
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

  String _categoryName(ProductCategory category) {
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

  Widget _buildEvolutionChart(ProductProvider provider, NumberFormat currency) {
    final evolution = provider.getSpendingEvolution(6);

    if (evolution.isEmpty || evolution.every((e) => e['total'] == 0.0)) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.noDataToShow ?? 'Sem dados para exibir',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }

    final maxY = evolution
        .map((e) => e['total'] as double)
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= evolution.length) {
                  return const SizedBox();
                }
                final data = evolution[value.toInt()];
                final date = data['date'] as DateTime;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM', _dateLocale()).format(date),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                final currency0 = NumberFormat.currency(
                  locale: _dateLocale(),
                  symbol: _currencySymbol(),
                  decimalDigits: 0,
                );
                return Text(
                  currency0.format(value),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
            left: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        minX: 0,
        maxX: (evolution.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final data = evolution[spot.x.toInt()];
                final date = data['date'] as DateTime;
                return LineTooltipItem(
                  '${DateFormat('MMM/yy', _dateLocale()).format(date)}\n${currency.format(spot.y)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots:
                evolution.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value['total'] as double,
                  );
                }).toList(),
            isCurved: false,
            color: const Color(0xFF2E7D32),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF2E7D32),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2E7D32).withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: _dateLocale(),
      symbol: _currencySymbol(),
    );
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final report =
            _isDaily
                ? provider.getDailyReport(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                )
                : provider.getMonthlyReport(_selectedYear, _selectedMonth);
        final totalSpent =
            _isDaily
                ? provider.getTotalSpentOnDay(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                )
                : provider.getTotalSpentInMonth(_selectedYear, _selectedMonth);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Period Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : const Color.fromARGB(137, 255, 255, 255),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 0, 0),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isDaily) {
                                _selectedDate = _selectedDate.subtract(
                                  const Duration(days: 1),
                                );
                              } else {
                                if (_selectedMonth == 1) {
                                  _selectedMonth = 12;
                                  _selectedYear--;
                                } else {
                                  _selectedMonth--;
                                }
                              }
                            });
                          },
                        ),
                        Text(
                          _isDaily
                              ? DateFormat(
                                'dd/MM/yyyy',
                                _dateLocale(),
                              ).format(_selectedDate)
                              : DateFormat(
                                'MMMM yyyy',
                                _dateLocale(),
                              ).format(DateTime(_selectedYear, _selectedMonth)),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 0, 0),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isDaily) {
                                _selectedDate = _selectedDate.add(
                                  const Duration(days: 1),
                                );
                              } else {
                                if (_selectedMonth == 12) {
                                  _selectedMonth = 1;
                                  _selectedYear++;
                                } else {
                                  _selectedMonth++;
                                }
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilterChip(
                          label: Text(
                            AppLocalizations.of(context)?.month ?? 'Mês',
                          ),
                          selected: !_isDaily,
                          onSelected: (selected) {
                            setState(() {
                              _isDaily = false;
                            });
                          },
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.grey[200],
                          selectedColor: const Color(0xFF2E7D32),
                          labelStyle: TextStyle(
                            color:
                                !_isDaily
                                    ? Colors.white
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(
                            AppLocalizations.of(context)?.day ?? 'Dia',
                          ),
                          selected: _isDaily,
                          onSelected: (selected) {
                            setState(() {
                              _isDaily = true;
                              // sync selectedDate to current selected month/year if needed
                              _selectedDate = DateTime(
                                _selectedYear,
                                _selectedMonth,
                                _selectedDate.day,
                              );
                            });
                          },
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.grey[200],
                          selectedColor: const Color(0xFF2E7D32),
                          labelStyle: TextStyle(
                            color:
                                _isDaily
                                    ? Colors.white
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Total Spent
              Container(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 3,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          _isDaily
                              ? (AppLocalizations.of(context)?.totalSpentDay ??
                                  'Total Gasto no Dia')
                              : (AppLocalizations.of(
                                    context,
                                  )?.totalSpentMonth ??
                                  'Total Gasto no Mês'),
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currency.format(totalSpent),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: const Color(0xFF2E7D32),
                    dividerTheme: const DividerThemeData(
                      color: Color(0xFF2E7D32),
                      thickness: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF2E7D32),
                      child: Icon(
                        Icons.show_chart,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context)?.spendingEvolutionTitle ??
                          'Evolução dos Gastos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        AppLocalizations.of(context)?.lastSixMonthsSubtitle ??
                            'Últimos 6 meses',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 200,
                          child: _buildEvolutionChart(provider, currency),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (report.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isDaily
                            ? (AppLocalizations.of(context)?.noSpendingDay ??
                                'Nenhum gasto neste dia')
                            : (AppLocalizations.of(context)?.noSpendingMonth ??
                                'Nenhum gasto neste mês'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Bar Chart
                if (report.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: const Color(0xFF2E7D32),
                        dividerTheme: const DividerThemeData(
                          color: Color(0xFF2E7D32),
                          thickness: 1,
                        ),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF2E7D32),
                          child: Icon(
                            Icons.bar_chart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          AppLocalizations.of(
                                context,
                              )?.spendingByCategoryTitle ??
                              'Gastos por Categoria',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _isDaily
                                ? (AppLocalizations.of(
                                      context,
                                    )?.distributionSelectedDay ??
                                    'Distribuição do dia selecionado')
                                : (AppLocalizations.of(
                                      context,
                                    )?.distributionSelectedMonth ??
                                    'Distribuição do mês selecionado'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY:
                                      report.values
                                          .map((e) => e['totalSpent'] as double)
                                          .reduce((a, b) => a > b ? a : b) *
                                      1.2,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (
                                        group,
                                        groupIndex,
                                        rod,
                                        rodIndex,
                                      ) {
                                        final category = report.keys.elementAt(
                                          groupIndex,
                                        );
                                        return BarTooltipItem(
                                          '${_categoryName(category)}\n',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: currency.format(rod.toY),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval:
                                        report.values
                                            .map(
                                              (e) => e['totalSpent'] as double,
                                            )
                                            .reduce((a, b) => a > b ? a : b) /
                                        4,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[300]!,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 48,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= report.length) {
                                            return const SizedBox();
                                          }
                                          final category = report.keys
                                              .elementAt(value.toInt());
                                          final label = _categoryName(
                                            category,
                                          ).substring(
                                            0,
                                            _categoryName(category).length > 10
                                                ? 10
                                                : _categoryName(
                                                  category,
                                                ).length,
                                          );
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Transform.rotate(
                                              angle: -math.pi / 6,
                                              child: Text(
                                                label,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 50,
                                        getTitlesWidget: (value, meta) {
                                          final currency0 =
                                              NumberFormat.currency(
                                                locale: _dateLocale(),
                                                symbol: _currencySymbol(),
                                                decimalDigits: 0,
                                              );
                                          return Text(
                                            currency0.format(value),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      left: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  barGroups:
                                      report.entries.map((entry) {
                                        final index = report.keys
                                            .toList()
                                            .indexOf(entry.key);
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY:
                                                  entry.value['totalSpent']
                                                      as double,
                                              color: _getCategoryColor(
                                                entry.key,
                                              ),
                                              width: 20,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(6),
                                                  ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Category Details
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: report.length,
                  itemBuilder: (context, index) {
                    final category = report.keys.elementAt(index);
                    final data = report[category]!;
                    final totalSpent = data['totalSpent'] as double;
                    final quantity = data['quantity'] as int;
                    final items = data['items'] as List<Product>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: _getCategoryColor(category),
                          dividerTheme: DividerThemeData(
                            color: _getCategoryColor(category),
                            thickness: 1,
                          ),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(category),
                            child: const Icon(
                              Icons.shopping_basket,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            _categoryName(category),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${currency.format(totalSpent)} • $quantity ${quantity == 1 ? (AppLocalizations.of(context)?.itemSingular ?? 'item') : (AppLocalizations.of(context)?.itemPlural ?? 'itens')}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          children:
                              items.map((product) {
                                return ListTile(
                                  dense: true,
                                  title: Text(product.name),
                                  subtitle: Text(
                                    'Qtd: ${product.quantity} • ${DateFormat('dd/MM/yyyy', _dateLocale()).format(product.purchasedAt!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Text(
                                    product.price != null
                                        ? currency.format(product.price!)
                                        : currency.format(0),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E7D32),
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
