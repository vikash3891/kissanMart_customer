import 'package:flutter/material.dart';

void main() => runApp(const KisaanKartApp());

const kGreen = Color(0xFF168A3A);
const kDarkGreen = Color(0xFF075C2A);
const kLightGreen = Color(0xFFEAF8EC);
const kBg = Color(0xFFF6F7FB);
const kOrange = Color(0xFFFF8A3D);
const kYellow = Color(0xFFFFF1C2);

class Product {
  final int id;
  final String store;
  final String name;
  final String category;
  final String subCategory;
  final String type;
  final String image;
  final String unit;
  final double price;
  final double mrp;
  final double rating;
  final int reviews;
  final String tag;
  final String origin;
  final String farmer;
  final String process;
  final bool organic;

  const Product({
    required this.id,
    required this.store,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.type,
    required this.image,
    required this.unit,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.reviews,
    required this.tag,
    required this.origin,
    required this.farmer,
    required this.process,
    required this.organic,
  });
}

class AddressItem {
  final int id;
  String title;
  String address;
  String phone;
  AddressItem({required this.id, required this.title, required this.address, required this.phone});
}

class OrderItem {
  final int id;
  final String status;
  final String date;
  final double total;
  final List<Product> products;
  const OrderItem({required this.id, required this.status, required this.date, required this.total, required this.products});
}

final products = <Product>[
  Product(id: 1, store: 'Kisan Mart', name: 'Organic Wheat Atta', category: 'Grains', subCategory: 'Wheat', type: 'Organic', image: '🌾', unit: '5 kg', price: 310, mrp: 358, rating: 4.6, reviews: 14368, tag: 'No Maida', origin: 'District: Sehore, MP', farmer: 'Ramesh Organic Farm', process: 'Stone chakki flour', organic: true),
  Product(id: 2, store: 'Kisan Mart', name: 'Normal Wheat Atta', category: 'Grains', subCategory: 'Wheat', type: 'Normal', image: '🌾', unit: '10 kg', price: 520, mrp: 590, rating: 4.3, reviews: 6400, tag: 'Fresh Flour', origin: 'District: Hapur, UP', farmer: 'Local Mill Partner', process: 'Cleaned and packed', organic: false),
  Product(id: 3, store: 'Kisan Mart', name: 'Organic Rice Premium', category: 'Grains', subCategory: 'Rice', type: 'Organic', image: '🍚', unit: '5 kg', price: 690, mrp: 760, rating: 4.7, reviews: 9800, tag: 'Certified Organic', origin: 'District: Karnal, HR', farmer: 'Green Valley Farm', process: 'Naturally aged rice', organic: true),
  Product(id: 4, store: 'Radicle Mart', name: 'Normal Rice', category: 'Grains', subCategory: 'Rice', type: 'Normal', image: '🍚', unit: '10 kg', price: 720, mrp: 830, rating: 4.2, reviews: 5200, tag: 'Daily Use', origin: 'District: Raipur, CG', farmer: 'FPO Rice Cluster', process: 'Sorted and polished', organic: false),
  Product(id: 5, store: 'FPO Mart', name: 'Organic Barley Grain', category: 'Grains', subCategory: 'Barley', type: 'Organic', image: '🌱', unit: '1 kg', price: 115, mrp: 140, rating: 4.4, reviews: 1780, tag: 'High Fibre', origin: 'District: Jaipur, RJ', farmer: 'Desert Organic FPO', process: 'Sun dried and cleaned', organic: true),
  Product(id: 6, store: 'She Mart', name: 'Organic Maize Flour', category: 'Grains', subCategory: 'Maize', type: 'Organic', image: '🌽', unit: '1 kg', price: 95, mrp: 120, rating: 4.3, reviews: 1120, tag: 'Freshly Milled', origin: 'District: Mandya, KA', farmer: 'Women Farmer Group', process: 'Stone ground', organic: true),
  Product(id: 7, store: 'Kisan Mart', name: 'Black Mustard Oil', category: 'Pulses', subCategory: 'Black Mustard', type: 'Organic', image: '🛢️', unit: '1 Ltr', price: 220, mrp: 260, rating: 4.6, reviews: 5402, tag: 'Cold Pressed', origin: 'District: Alwar, RJ', farmer: 'Mustard Farmer Group', process: 'Wood pressed oil', organic: true),
  Product(id: 8, store: 'Radicle Mart', name: 'Yellow Mustard Oil', category: 'Pulses', subCategory: 'Yellow Mustard', type: 'Normal', image: '🟡', unit: '5 Ltr', price: 880, mrp: 995, rating: 4.2, reviews: 3200, tag: 'Family Pack', origin: 'District: Bharatpur, RJ', farmer: 'Partner Farm', process: 'Filtered oil', organic: false),
  Product(id: 9, store: 'FPO Mart', name: 'Organic Peanuts', category: 'Pulses', subCategory: 'Peanuts', type: 'Organic', image: '🥜', unit: '1 kg', price: 185, mrp: 230, rating: 4.5, reviews: 2410, tag: 'Protein Rich', origin: 'District: Junagadh, GJ', farmer: 'Groundnut FPO', process: 'Cleaned and roasted ready', organic: true),
  Product(id: 10, store: 'Kisan Mart', name: 'Fresh Potato', category: 'Vegetables', subCategory: 'Root Vegetables', type: 'Normal', image: '🥔', unit: '1 kg', price: 38, mrp: 48, rating: 4.1, reviews: 2100, tag: 'Farm Fresh', origin: 'Local farm', farmer: 'City Partner Farm', process: 'Washed and packed', organic: false),
  Product(id: 11, store: 'Kisan Mart', name: 'Fresh Tomato', category: 'Vegetables', subCategory: 'Daily Vegetables', type: 'Normal', image: '🍅', unit: '500 g', price: 32, mrp: 42, rating: 4.0, reviews: 1900, tag: 'Fresh Today', origin: 'Local farm', farmer: 'Local Grower', process: 'Hand picked', organic: false),
  Product(id: 12, store: 'She Mart', name: 'Organic Apple', category: 'Fruits', subCategory: 'Seasonal Fruits', type: 'Organic', image: '🍎', unit: '4 pcs', price: 180, mrp: 220, rating: 4.5, reviews: 3210, tag: 'Premium', origin: 'Himachal Pradesh', farmer: 'Hill Orchard', process: 'Quality graded', organic: true),
  Product(id: 13, store: 'Kisan Mart', name: 'Banana Robusta', category: 'Fruits', subCategory: 'Daily Fruits', type: 'Normal', image: '🍌', unit: '6 pcs', price: 54, mrp: 65, rating: 4.0, reviews: 700, tag: 'Ready to Eat', origin: 'Local market', farmer: 'Partner Supplier', process: 'Ripeness checked', organic: false),
  Product(id: 14, store: 'Radicle Mart', name: 'Organic Jaggery Powder', category: 'Others', subCategory: 'Sweeteners', type: 'Organic', image: '🍯', unit: '500 g', price: 92, mrp: 115, rating: 4.7, reviews: 1865, tag: 'Chemical Free', origin: 'District: Muzaffarnagar, UP', farmer: 'Sugarcane Farmer Group', process: 'Traditional boiling', organic: true),
  Product(id: 15, store: 'FPO Mart', name: 'Cold Pressed Groundnut Oil', category: 'Others', subCategory: 'Oil', type: 'Organic', image: '🥜', unit: '1 Ltr', price: 260, mrp: 310, rating: 4.6, reviews: 2770, tag: 'Wood Pressed', origin: 'District: Rajkot, GJ', farmer: 'Groundnut FPO', process: 'Cold pressed', organic: true),
];

class AppState extends ChangeNotifier {
  bool loggedIn = false;
  int selectedTab = 0;
  String searchQuery = '';
  final Map<int, int> cart = {};
  final List<AddressItem> addresses = [
    AddressItem(id: 1, title: 'Home', address: 'Floor 4th, Room 403, Seattle House, Bellandur, Bengaluru', phone: '9911681487'),
    AddressItem(id: 2, title: 'Office', address: 'Tower Whitefield, Varthur Road, Bengaluru', phone: '9911681487'),
    AddressItem(id: 3, title: 'Parents Home', address: 'Sector 62, Noida, Uttar Pradesh', phone: '9911681487'),
  ];

  late final List<OrderItem> orders = [
    OrderItem(id: 1001, status: 'Arrived in 29 minutes', date: 'Today, 5:50 pm', total: 557, products: products.take(4).toList()),
    OrderItem(id: 1002, status: 'Arrived in 17 minutes', date: '16 Mar, 6:06 pm', total: 297, products: products.skip(6).take(4).toList()),
    OrderItem(id: 1003, status: 'Order arrived', date: '28 Feb, 8:15 pm', total: 264, products: products.skip(10).take(3).toList()),
  ];

  void login() { loggedIn = true; notifyListeners(); }
  void logout() { loggedIn = false; selectedTab = 0; cart.clear(); notifyListeners(); }
  void setTab(int index) { selectedTab = index; notifyListeners(); }
  void setSearch(String value) { searchQuery = value; notifyListeners(); }
  void add(Product p) { cart[p.id] = (cart[p.id] ?? 0) + 1; notifyListeners(); }
  void remove(Product p) { if (!cart.containsKey(p.id)) return; cart[p.id] = cart[p.id]! - 1; if (cart[p.id]! <= 0) cart.remove(p.id); notifyListeners(); }
  void clearCart() { cart.clear(); notifyListeners(); }
  int qty(Product p) => cart[p.id] ?? 0;
  int get itemCount => cart.values.fold(0, (a, b) => a + b);
  double get subtotal => cart.entries.fold(0, (sum, e) => sum + products.firstWhere((p) => p.id == e.key).price * e.value);
  double get deliveryFee => subtotal >= 199 || subtotal == 0 ? 0 : 35;
  double get handling => subtotal == 0 ? 0 : 6;
  double get gst => subtotal * 0.05;
  double get total => subtotal + deliveryFee + handling + gst;
  List<Product> get cartProducts => cart.keys.map((id) => products.firstWhere((p) => p.id == id)).toList();
  List<Product> get filteredProducts {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) => '${p.name} ${p.category} ${p.subCategory} ${p.type} ${p.store} ${p.tag}'.toLowerCase().contains(q)).toList();
  }
  void addAddress(AddressItem a) { addresses.add(a); notifyListeners(); }
  void updateAddress(AddressItem a) { final i = addresses.indexWhere((e) => e.id == a.id); if (i >= 0) addresses[i] = a; notifyListeners(); }
  void deleteAddress(int id) { addresses.removeWhere((a) => a.id == id); notifyListeners(); }
}

final appState = AppState();

class KisaanKartApp extends StatelessWidget {
  const KisaanKartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kisaan Kart',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
          scaffoldBackgroundColor: kBg,
          cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: kBg, elevation: 0),
        ),
        home: appState.loggedIn ? const MainShell() : const LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  bool otpSent = false;
  String? error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [kLightGreen, Color(0xFFFFF7DC)]), borderRadius: BorderRadius.circular(32)),
              child: const Column(children: [
                Text('🌿', style: TextStyle(fontSize: 56)),
                SizedBox(height: 8),
                Text('Kisaan Kart', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                Text('Organic groceries delivered fast', style: TextStyle(color: Colors.black54)),
              ]),
            ),
            const SizedBox(height: 28),
            TextField(controller: phone, keyboardType: TextInputType.phone, maxLength: 10, decoration: InputDecoration(labelText: '10 digit phone number', prefixText: '+91 ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), counterText: '')),
            if (otpSent) ...[
              const SizedBox(height: 14),
              TextField(controller: otp, keyboardType: TextInputType.number, maxLength: 4, decoration: InputDecoration(labelText: 'OTP', helperText: 'Use OTP 1234', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), counterText: '')),
            ],
            if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kGreen, padding: const EdgeInsets.all(16)),
              onPressed: () {
                setState(() => error = null);
                if (phone.text.length != 10) { setState(() => error = 'Enter valid 10 digit phone number'); return; }
                if (!otpSent) { setState(() => otpSent = true); return; }
                if (otp.text != '1234') { setState(() => error = 'Invalid OTP. Please enter 1234'); return; }
                appState.login();
              },
              child: Text(otpSent ? 'Verify & Continue' : 'Send OTP'),
            ),
          ]),
        ),
      ),
    ),
  );
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});
  @override
  Widget build(BuildContext context) {
    final screens = [const HomeScreen(), const CategoriesScreen(), const CartScreen(), const OrdersScreen(), const ProfileScreen()];
    return Scaffold(
      body: SafeArea(child: screens[appState.selectedTab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: appState.selectedTab,
        onDestinationSelected: appState.setTab,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Categories'),
          NavigationDestination(icon: Badge(label: Text('${appState.itemCount}'), isLabelVisible: appState.itemCount > 0, child: const Icon(Icons.shopping_cart_outlined)), selectedIcon: const Icon(Icons.shopping_cart), label: 'Cart'),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final categories = ['Grains', 'Pulses', 'Vegetables', 'Fruits', 'Others'];
    final list = appState.filteredProducts;
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE5FFD8), Color(0xFFFFE5C8)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kisaan Kart in', style: TextStyle(fontWeight: FontWeight.w800)), Text('15 minutes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)), Text('HOME - Floor 4th, Room 403 ▼') ])),
            IconButton.filledTonal(onPressed: () => appState.setTab(2), icon: const Icon(Icons.shopping_cart_outlined)),
            IconButton.filledTonal(onPressed: () => appState.setTab(4), icon: const Icon(Icons.person_outline)),
          ]),
          const SizedBox(height: 14),
          SearchBox(initial: appState.searchQuery, onChanged: appState.setSearch),
          const SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(
                      title: categories[i],
                      products: products.where((p) => p.category == categories[i]).toList(),
                    ),
                  ),
                ), // Added missing closing brackets here
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(
                        categoryIcon(categories[i]),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categories[i],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PromoBanner(),
        const SizedBox(height: 18),
        sectionTitle(appState.searchQuery.isEmpty ? 'Shop by Category' : 'Search Results'),
        if (appState.searchQuery.isEmpty) CategoryGrid(categories: categories),
        const SizedBox(height: 18),
        sectionTitle(appState.searchQuery.isEmpty ? 'Frequently bought' : '${list.length} products found'),
      ]))),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverGrid(delegate: SliverChildBuilderDelegate((context, index) => ProductCard(product: list[index]), childCount: list.length), gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 230, mainAxisExtent: 285, crossAxisSpacing: 12, mainAxisSpacing: 12)),
      ),
    ]);
  }
}

class SearchBox extends StatelessWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const SearchBox({super.key, required this.initial, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(
    controller: TextEditingController(text: initial)..selection = TextSelection.collapsed(offset: initial.length),
    onChanged: onChanged,
    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), suffixIcon: const Icon(Icons.mic_none), hintText: 'Search for wheat, rice, mustard and more', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)),
  );
}

class PromoBanner extends StatelessWidget { const PromoBanner({super.key}); @override Widget build(BuildContext context) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(color: kYellow, borderRadius: BorderRadius.circular(24), image: const DecorationImage(image: NetworkImage('https://dummyimage.com/900x280/fff1c2/fff1c2'), fit: BoxFit.cover)),
  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('GET READY TO CELEBRATE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
    SizedBox(height: 8),
    Text('Fresh organic staples', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    Text('Rice • Wheat • Oil • Peanuts • Fruits'),
  ]),
); }

class CategoryGrid extends StatelessWidget {
  final List<String> categories;
  const CategoryGrid({super.key, required this.categories});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: categories.length,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180, mainAxisExtent: 130, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemBuilder: (_, i) => InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(title: categories[i], products: products.where((p) => p.category == categories[i]).toList()))),
      child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(categoryIcon(categories[i]), style: const TextStyle(fontSize: 36)), const SizedBox(height: 8), Text(categories[i], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900))]))),
    ),
  );
}

Widget sectionTitle(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)));
String categoryIcon(String c) => {'Grains': '🌾', 'Pulses': '🥜', 'Vegetables': '🥦', 'Fruits': '🍎', 'Others': '🛒'}[c] ?? '🛒';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final categories = ['Grains', 'Pulses', 'Vegetables', 'Fruits', 'Others'];
    return ListScreen(title: 'Categories', children: [
      ...categories.map((c) {
        final sub = products.where((p) => p.category == c).map((p) => p.subCategory).toSet().toList();
        return Card(child: ExpansionTile(leading: Text(categoryIcon(c), style: const TextStyle(fontSize: 28)), title: Text(c, style: const TextStyle(fontWeight: FontWeight.w900)), children: [
          ...sub.map((s) => ListTile(title: Text(s), subtitle: Text('${products.where((p) => p.subCategory == s).length} products'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(title: s, products: products.where((p) => p.subCategory == s).toList()))))),
        ]));
      }),
    ]);
  }
}

class ProductListScreen extends StatelessWidget {
  final String title;
  final List<Product> products;
  const ProductListScreen({super.key, required this.title, required this.products});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: [IconButton(onPressed: () => appState.setTab(2), icon: const Icon(Icons.shopping_cart_outlined))]),
    body: GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 230, mainAxisExtent: 285, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    ),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
    child: Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: kLightGreen, borderRadius: BorderRadius.circular(18)), child: Center(child: Text(product.image, style: const TextStyle(fontSize: 54))))),
      const SizedBox(height: 8),
      Row(children: [Text(product.unit, style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), QtyButton(p: product)]),
      Text('₹${product.price.toStringAsFixed(0)} ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      Text('${discount(product)}% OFF • MRP ₹${product.mrp.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w800)),
      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
      Text('${product.type} • ${product.store}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      Row(children: [const Icon(Icons.timer_outlined, size: 14, color: Colors.black54), const Text(' 15 mins', style: TextStyle(fontSize: 12)), const Spacer(), const Icon(Icons.star, size: 14, color: Colors.amber), Text(product.rating.toString(), style: const TextStyle(fontSize: 12))]),
    ]))),
  );
}

int discount(Product p) => (((p.mrp - p.price) / p.mrp) * 100).round();

class QtyButton extends StatelessWidget {
  final Product p;
  const QtyButton({super.key, required this.p});
  @override
  Widget build(BuildContext context) {
    final q = appState.qty(p);
    if (q == 0) return OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: kGreen, side: const BorderSide(color: kGreen), visualDensity: VisualDensity.compact), onPressed: () => appState.add(p), child: const Text('ADD'));
    return Container(decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [InkWell(onTap: () => appState.remove(p), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, color: Colors.white, size: 16))), Text('$q', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), InkWell(onTap: () => appState.add(p), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, color: Colors.white, size: 16)))]));
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF2B2B2B),
    body: SafeArea(child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Card(margin: const EdgeInsets.all(18), color: kBg, child: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [IconButton.filled(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.keyboard_arrow_down)), const Spacer(), IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.favorite_border)), IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.search)), IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.share))]),
        Container(height: 260, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Center(child: Text(product.image, style: const TextStyle(fontSize: 130)))),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [infoChip(product.tag), infoChip('Shelf life 90 days'), infoChip(product.type), infoChip(product.store)]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.timer_outlined, size: 18), const Text(' 15 mins'), const SizedBox(width: 18), const Icon(Icons.star, color: Colors.amber, size: 18), Text(' ${product.rating} (${product.reviews})')]),
          const SizedBox(height: 10),
          Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(product.unit, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(width: 8), Text('MRP ₹${product.mrp.toStringAsFixed(0)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black54))]),
          Text('${discount(product)}% OFF on MRP', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900)),
          const Divider(height: 28),
          const Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          detailRow('Category', '${product.category} / ${product.subCategory}'),
          detailRow('Origin', product.origin),
          detailRow('Farmer Name', product.farmer),
          detailRow('Process', product.process),
          detailRow('Organic', product.organic ? 'Yes' : 'No'),
        ]))),
      ])),
      Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(product.unit, style: const TextStyle(fontWeight: FontWeight.bold)), Text('₹${product.price.toStringAsFixed(0)}  MRP ₹${product.mrp.toStringAsFixed(0)}') ])), SizedBox(width: 170, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen, padding: const EdgeInsets.all(16)), onPressed: () => appState.add(product), child: Text(appState.qty(product) == 0 ? 'Add to cart' : 'Added: ${appState.qty(product)}')))])),
    ]))))),
  );
}

Widget infoChip(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
Widget detailRow(String a, String b) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 110, child: Text(a, style: const TextStyle(color: Colors.black54))), Expanded(child: Text(b, style: const TextStyle(fontWeight: FontWeight.w700)))]));

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    if (appState.cart.isEmpty) return EmptyState(title: 'Your cart is empty', message: 'Add organic staples and fresh groceries.', action: () => appState.setTab(0));
    return ListScreen(title: 'My Cart', children: [
      ...appState.cartProducts.map((p) => Card(child: ListTile(leading: Text(p.image, style: const TextStyle(fontSize: 34)), title: Text(p.name), subtitle: Text('${p.unit} • ₹${p.price.toStringAsFixed(0)}'), trailing: QtyButton(p: p), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)))))),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [billRow('Item total', appState.subtotal), billRow('Delivery fee', appState.deliveryFee), billRow('Handling charge', appState.handling), billRow('GST 5%', appState.gst), const Divider(), billRow('To pay', appState.total, bold: true)]))),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen, padding: const EdgeInsets.all(16)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())), child: const Text('Proceed to Checkout')),
    ]);
  }
}

Widget billRow(String label, double value, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.normal))), Text(value == 0 ? 'FREE' : '₹${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.normal))]));

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) => ListScreen(title: 'Checkout', children: [
    const Text('Deliver to', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    Card(child: ListTile(leading: const Icon(Icons.home, color: kGreen), title: Text(appState.addresses.first.title), subtitle: Text(appState.addresses.first.address), trailing: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())), child: const Text('Change')))),
    const Text('Delivery Type', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    const Card(child: ListTile(leading: Icon(Icons.delivery_dining, color: kGreen), title: Text('Home delivery'), subtitle: Text('Expected in 15-30 minutes'))),
    const Text('Payment', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    const Card(child: ListTile(leading: Icon(Icons.payments, color: kGreen), title: Text('Cash on Delivery'), subtitle: Text('UPI/Card can be integrated later'))),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: billRow('Total payable', appState.total, bold: true))),
    FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen, padding: const EdgeInsets.all(16)), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dummy order placed successfully'))); appState.clearCart(); appState.setTab(3); Navigator.pop(context); }, child: const Text('Place Order')),
  ]);
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => ListScreen(title: 'Your orders', children: appState.orders.map((o) => Card(child: ListTile(leading: const CircleAvatar(backgroundColor: kLightGreen, child: Icon(Icons.check, color: kGreen)), title: Text(o.status, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('₹${o.total.toStringAsFixed(0)} • ${o.date}\n${o.products.map((p) => p.image).join('  ')}'), isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o)))))).toList());
}

class OrderDetailScreen extends StatelessWidget {
  final OrderItem order;
  const OrderDetailScreen({super.key, required this.order});
  @override
  Widget build(BuildContext context) => ListScreen(title: 'Order #${order.id}', children: [
    Text(order.status, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    Text(order.date),
    const SizedBox(height: 12),
    ...order.products.map((p) => Card(child: ListTile(leading: Text(p.image, style: const TextStyle(fontSize: 32)), title: Text(p.name), subtitle: Text('${p.unit} • ${p.store}',), trailing: Text('₹${p.price.toStringAsFixed(0)}'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)))))),
    FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen), onPressed: () { for (final p in order.products) { appState.add(p); } appState.setTab(2); Navigator.pop(context); }, child: const Text('Reorder')),
    OutlinedButton(onPressed: () {}, child: const Text('Rate order')),
  ]);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => ListScreen(title: 'Profile', children: [
    const Card(child: ListTile(leading: CircleAvatar(backgroundColor: kLightGreen, child: Icon(Icons.person, color: kGreen)), title: Text('Kisaan Kart User'), subtitle: Text('+91 9911681487'))),
    profileTile(context, Icons.receipt_long, 'Your orders', () => appState.setTab(3)),
    profileTile(context, Icons.favorite_border, 'Your wishlist', () {}),
    profileTile(context, Icons.location_on_outlined, 'Address book', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()))),
    profileTile(context, Icons.business, 'GST details', () {}),
    profileTile(context, Icons.payment, 'Payment settings', () {}),
    profileTile(context, Icons.card_giftcard, 'Collected rewards', () {}),
    profileTile(context, Icons.logout, 'Logout', appState.logout),
  ]);
}

Widget profileTile(BuildContext c, IconData i, String t, VoidCallback onTap) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: kBg, child: Icon(i)), title: Text(t), trailing: const Icon(Icons.chevron_right), onTap: onTap));

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('My Addresses')), body: ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(leading: const Icon(Icons.add, color: kGreen), title: const Text('Add new address', style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressForm())))),
    ...appState.addresses.map((a) => Card(child: ListTile(leading: const Icon(Icons.home, color: kGreen), title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${a.address}\nPhone: ${a.phone}'), isThreeLine: true, trailing: PopupMenuButton<String>(itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))], onSelected: (v) { if (v == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => AddressForm(item: a))); if (v == 'delete') appState.deleteAddress(a.id); })))),
  ]));
}

class AddressForm extends StatefulWidget { final AddressItem? item; const AddressForm({super.key, this.item}); @override State<AddressForm> createState() => _AddressFormState(); }
class _AddressFormState extends State<AddressForm> {
  late final title = TextEditingController(text: widget.item?.title ?? '');
  late final address = TextEditingController(text: widget.item?.address ?? '');
  late final phone = TextEditingController(text: widget.item?.phone ?? '9911681487');
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.item == null ? 'Add Address' : 'Edit Address')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    TextField(controller: title, decoration: const InputDecoration(labelText: 'Address title')),
    TextField(controller: address, decoration: const InputDecoration(labelText: 'Full address')),
    TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
    const SizedBox(height: 20),
    FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen), onPressed: () { final a = AddressItem(id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch, title: title.text, address: address.text, phone: phone.text); widget.item == null ? appState.addAddress(a) : appState.updateAddress(a); Navigator.pop(context); }, child: const Text('Save Address')),
  ])));
}

class ListScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const ListScreen({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: ListView(padding: const EdgeInsets.all(16), children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w)).toList()));
}

class EmptyState extends StatelessWidget {
  final String title, message;
  final VoidCallback action;
  const EmptyState({super.key, required this.title, required this.message, required this.action});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('🛒', style: TextStyle(fontSize: 72)),
    Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    Text(message, textAlign: TextAlign.center),
    const SizedBox(height: 16),
    FilledButton(style: FilledButton.styleFrom(backgroundColor: kGreen), onPressed: action, child: const Text('Start Shopping')),
  ])));
}
