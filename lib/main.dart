import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/product_provider.dart';
import 'providers/selection_provider.dart';
import 'screens/to_buy_tab.dart';
import 'screens/purchased_tab.dart';
import 'screens/reports_tab.dart';
import 'widgets/shopping_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {
      // ignore errors silently; not all devices support display mode switching
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SelectionProvider()),
      ],
      child: Builder(
        builder:
            (context) => MaterialApp(
              title: AppLocalizations.of(context)?.appTitle ?? 'MeuGasto',
              debugShowCheckedModeBanner: false,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: context.watch<ThemeProvider>().locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              themeMode: context.watch<ThemeProvider>().themeMode,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF2E7D32),
                  primary: const Color(0xFF2E7D32),
                  secondary: const Color(0xFF66BB6A),
                  tertiary: const Color(0xFF81C784),
                  surface: Colors.white,
                  brightness: Brightness.light,
                ),
                cardTheme: CardTheme(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.black87),
                  floatingLabelStyle: const TextStyle(color: Colors.black),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                dialogTheme: DialogTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                chipTheme: ChipThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                appBarTheme: const AppBarTheme(
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF2E7D32),
                  primary: const Color(0xFF2E7D32),
                  secondary: const Color(0xFF66BB6A),
                  tertiary: const Color(0xFF81C784),
                  surface: const Color(0xFF121212),
                  brightness: Brightness.dark,
                ),
                cardTheme: CardTheme(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF2A2A2A)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  floatingLabelStyle: const TextStyle(color: Colors.white),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                dialogTheme: DialogTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                chipTheme: ChipThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
              ),
              home: const SplashScreen(),
            ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;
  bool _overlayGone = false;
  bool _fadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _rotate = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MyHomePage(),
        if (!_overlayGone)
          AnimatedOpacity(
            opacity: _fadingOut ? 0 : 1,
            duration: const Duration(milliseconds: 420),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: RotationTransition(
                        turns: _rotate,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.attach_money,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _initializeAndNavigate() async {
    final productProvider = context.read<ProductProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final loadFuture = productProvider.loadProducts();
    final themeFuture = themeProvider.loadPersistedTheme();
    final animFuture = _controller.forward();
    await Future.wait([loadFuture, themeFuture, animFuture]);
    if (!mounted) return;
    setState(() {
      _fadingOut = true;
    });
    await Future.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    setState(() {
      _overlayGone = true;
    });
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = const [ToBuyTab(), PurchasedTab(), ReportsTab()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectionProvider = context.watch<SelectionProvider>();
    final isSelectionMode = selectionProvider.isSelectionMode;

    return ShoppingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor:
              isSelectionMode
                  ? const Color(0xFF2E7D32)
                  : Theme.of(context).colorScheme.surface,
          leading:
              isSelectionMode
                  ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: selectionProvider.onCancel,
                  )
                  : null,
          title: Text(
            isSelectionMode
                ? '${selectionProvider.selectedCount} ${AppLocalizations.of(context)?.selected ?? 'selecionados'}'
                : AppLocalizations.of(context)?.expensesTitle ?? 'MeuGasto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  isSelectionMode
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            if (isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.select_all, color: Colors.white),
                tooltip:
                    AppLocalizations.of(context)?.selectAll ??
                    'Selecionar Todos',
                onPressed: () {
                  // Callback será definido pelas tabs
                  if (selectionProvider.onSelectAll != null) {
                    selectionProvider.onSelectAll!();
                  }
                },
              ),
              if (selectionProvider.selectedCount > 0)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: selectionProvider.onDelete,
                ),
            ] else
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onSelected: (value) {
                  if (value == 'settings') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: Text(
                          AppLocalizations.of(context)?.settingsTitle ??
                              'Configurações',
                        ),
                      ),
                    ],
              ),
          ],
          elevation: 0,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            // Limpa o modo de seleção ao trocar de página
            final selectionProvider = context.read<SelectionProvider>();
            if (selectionProvider.isSelectionMode) {
              selectionProvider.exitSelectionMode();
            }
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.shopping_cart_outlined),
              selectedIcon: const Icon(
                Icons.shopping_cart,
                color: Color(0xFF2E7D32),
              ),
              label: AppLocalizations.of(context)?.tabBuy ?? 'Comprar',
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined),
              selectedIcon: const Icon(
                Icons.shopping_bag,
                color: Color(0xFF2E7D32),
              ),
              label: AppLocalizations.of(context)?.tabPurchased ?? 'Comprados',
            ),
            NavigationDestination(
              icon: const Icon(Icons.analytics_outlined),
              selectedIcon: const Icon(
                Icons.analytics,
                color: Color(0xFF2E7D32),
              ),
              label: AppLocalizations.of(context)?.tabReports ?? 'Relatórios',
            ),
          ],
        ),
      ),
    );
  }
}
