import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/environment_config.dart';
import 'core/config/remote_config_service.dart';
import 'core/storage/hive_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';

import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/location_provider.dart';
import 'providers/review_provider.dart';
import 'providers/home_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/coupon_provider.dart';
import 'providers/network_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/payment_provider.dart';
import 'core/widgets/connectivity_banner.dart';

import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/categories/categories_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment (change to .qa or .prod for other builds)
  EnvironmentConfig.initialize(AppEnvironment.dev);

  // Initialize Hive local database
  await HiveStorageService.init();

  // Initialize remote config
  final remoteConfig = MockRemoteConfigService();
  await remoteConfig.fetchAndActivate();

  runApp(
    MultiProvider(
      providers: [
        // ThemeProvider handles Dark Mode persistence.
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Network connectivity monitor.
        ChangeNotifierProvider(create: (_) => NetworkProvider()),

        // Auth must be registered first — others may depend on its token.
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // Products and categories start loading immediately on app launch.
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),

        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()..loadOrders()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const KisaanKartApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// App root
// ─────────────────────────────────────────────────────────────────────────────

class KisaanKartApp extends StatefulWidget {
  const KisaanKartApp({super.key});

  @override
  State<KisaanKartApp> createState() => _KisaanKartAppState();
}

class _KisaanKartAppState extends State<KisaanKartApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  /// Controls whether the splash screen is still visible.
  /// Set to false once the splash animation completes.
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    ApiService.onSessionExpired = () {
      if (mounted) {
        context.read<AuthProvider>().logout();
        
        // Clear all provider states
        context.read<CartProvider>().clear();
        context.read<AddressProvider>().clear();
        context.read<OrderProvider>().clear();
        context.read<ProfileProvider>().clear();
        context.read<WishlistProvider>().clear();
        context.read<NotificationProvider>().clear();

        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please login again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();

    final ThemeData lightTheme = AppTheme.getTheme(
      preset: theme.preset,
      brightness: Brightness.light,
      isAmoled: theme.isAmoled,
    );
    final ThemeData darkTheme = AppTheme.getTheme(
      preset: theme.preset,
      brightness: Brightness.dark,
      isAmoled: theme.isAmoled,
    );

    // Show the branded Kisaan Kart splash until animation completes
    // AND auth initialization is done. This ensures the splash is shown
    // for a minimum of ~2.4 s regardless of how fast auth resolves.
    if (_showSplash || auth.isInitializing) {
      return MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: theme.themeMode,
        home: SplashScreen(
          onComplete: () {
            // Capture provider reference before any async gap.
            final authProvider = auth;
            if (!authProvider.isInitializing) {
              // Auth already done — dismiss immediately.
              setState(() => _showSplash = false);
            } else {
              // Auth still running — listen for it to finish, then dismiss.
              void listener() {
                if (!authProvider.isInitializing && mounted) {
                  authProvider.removeListener(listener);
                  setState(() => _showSplash = false);
                }
              }
              authProvider.addListener(listener);
            }
          },
        ),
      );
    }

    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Kisaan Kart',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: theme.themeMode,
      home: auth.loggedIn
          ? const ConnectivityBanner(child: MainShell())
          : const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main shell with bottom navigation
// ─────────────────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    // Load backend-driven data once the user is logged in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
      context.read<AddressProvider>().loadAddresses();
      context.read<WishlistProvider>().loadWishlist();
      context.read<NotificationProvider>().loadNotifications();
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();
    final cart = context.watch<CartProvider>();
    final notifications = context.watch<NotificationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: navigation.selectedTab,
        children: const [
          HomeScreen(),
          CategoriesScreen(),
          CartScreen(),
          OrdersScreen(),
          ProfilePage(showBack: false),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigation.selectedTab,
        onDestinationSelected: navigation.setTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text(notifications.unreadCount.toString()),
              isLabelVisible: notifications.unreadCount > 0,
              child: const Icon(Icons.person_outline),
            ),
            selectedIcon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
