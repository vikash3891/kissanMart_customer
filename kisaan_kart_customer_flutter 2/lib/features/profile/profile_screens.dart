import 'package:flutter/material.dart';

const kGreen = Color(0xFF1B7F3A);
const kBg = Color(0xFFF6F7FB);
const kDark = Color(0xFF24272D);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required bool showBack});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final items1 = [
      _ProfileItem(Icons.receipt_long, 'Your orders', () => _open(context, const OrderHistoryPage())),
      _ProfileItem(Icons.favorite_border, 'Your wishlist', () {}),
      _ProfileItem(Icons.restaurant_menu, 'Bookmarked recipes', () {}),
      _ProfileItem(Icons.description_outlined, 'Your prescriptions', () {}),
      _ProfileItem(Icons.fact_check_outlined, 'Address book', () => _open(context, const AddressBookPage())),
      _ProfileItem(Icons.article_outlined, 'GST details', () {}),
      _ProfileItem(Icons.card_giftcard, 'E-gift cards', () {}, showDot: true),
    ];

    final items2 = [
      _ProfileItem(Icons.volunteer_activism, 'Your impact', () {}, showDot: true),
      _ProfileItem(Icons.receipt, 'Get donation receipt', () {}, showDot: true),
    ];

    final items3 = [
      _ProfileItem(Icons.credit_card, 'Payment settings', () {}),
      _ProfileItem(Icons.account_balance_wallet_outlined, 'Kisaan Money', () {}, showDot: true),
      _ProfileItem(Icons.wallet_giftcard, 'Claim Gift Card', () {}, showDot: true),
      _ProfileItem(Icons.percent, 'Your collected rewards', () {}, showDot: true),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
              children: [
                _Header(title: 'Profile'),
                const SizedBox(height: 28),
                _SectionTitle('YOUR INFORMATION'),
                ...items1.map((e) => _ProfileRow(item: e)),
                const SizedBox(height: 22),
                _SectionTitle('FEEDING INDIA'),
                ...items2.map((e) => _ProfileRow(item: e)),
                const SizedBox(height: 22),
                _SectionTitle('PAYMENT AND COUPONS'),
                ...items3.map((e) => _ProfileRow(item: e)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  final addresses = [
    AppAddress(
      'Home',
      'Flat 1204, Green Meadows Residency, Sarjapur Road, Bengaluru, Karnataka',
      '9876543210',
      'You’re here',
      true,
    ),

    AppAddress(
      'Office',
      'Prestige Tech Park, Marathahalli Outer Ring Road, Bengaluru, Karnataka',
      '9876543210',
      '4.82 km',
      false,
    ),

    AppAddress(
      'Parents Home',
      'House No. 24, Shanti Nagar Colony, Gomti Nagar Extension, Lucknow, Uttar Pradesh',
      '9123456780',
      '1950.34 km',
      false,
    ),

    AppAddress(
      'Weekend Stay',
      'Villa 18, Hill View Retreat, Vythiri, Wayanad, Kerala',
      '9456781230',
      '286.73 km',
      false,
    ),

    AppAddress(
      'Warehouse',
      'Logistics Hub, Industrial Area Phase 2, Chandigarh',
      '9871234567',
      '2235.81 km',
      false,
    ),
  ];

  void _addAddress() {
    setState(() {
      addresses.insert(
        0,
        AppAddress('New Address', 'Add full address here, landmark, city and pincode', '9911681487', 'New', false),
      );
    });
  }

  void _deleteAddress(int index) {
    setState(() => addresses.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
              children: [
                const _Header(title: 'My Addresses'),
                const SizedBox(height: 24),
                _ActionCard(children: [
                  _ActionRow(Icons.add, 'Add new address', _addAddress, green: true),
                  _ActionRow(Icons.chat, 'Request address from someone else', () {}),
                ]),
                const SizedBox(height: 14),
                _ActionCard(children: [
                  _ActionRow(Icons.download, 'Import your addresses from Zomato', () {}),
                ]),
                const SizedBox(height: 24),
                const Text('Your saved addresses', style: TextStyle(fontSize: 18, color: Colors.black54)),
                const SizedBox(height: 14),
                ...List.generate(addresses.length, (i) {
                  return _AddressCard(
                    address: addresses[i],
                    onDelete: () => _deleteAddress(i),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      AppOrder('Arrived in 17 minutes', '₹574', '13 Jun, 12:03 am', ['🌾', '🛢️']),
      AppOrder('Arrived in 15 minutes', '₹546', '12 Jun, 2:43 pm', ['🍨', '🍪', '🥟', '🍚']),
      AppOrder('Arrived in 22 minutes', '₹683', '11 Jun, 10:24 am', ['🌾', '🧃', '🫘', '🥤', '+5']),
      AppOrder('Arrived in 25 minutes', '₹222', '10 Jun, 10:21 am', ['🥜', '🍅']),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
              children: [
                const _Header(title: 'Order History'),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search your grocery orders',
                    prefixIcon: const Icon(Icons.search, color: kGreen, size: 32),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...orders.map((o) => _OrderCard(order: o)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back_ios_new, color: kDark, size: 20),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black54, letterSpacing: .8)),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDot;

  _ProfileItem(this.icon, this.title, this.onTap, {this.showDot = false});
}

class _ProfileRow extends StatelessWidget {
  final _ProfileItem item;
  const _ProfileRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF0F1F5),
            child: Icon(item.icon, color: kDark),
          ),
          if (item.showDot)
            const Positioned(
              top: 0,
              right: -2,
              child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
            ),
        ],
      ),
      title: Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final List<Widget> children;
  const _ActionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool green;

  const _ActionRow(this.icon, this.title, this.onTap, {this.green = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: green ? kGreen : Colors.black54),
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: green ? kGreen : kDark)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class AppAddress {
  final String title, address, phone, distance;
  final bool selected;

  AppAddress(this.title, this.address, this.phone, this.distance, this.selected);
}

class _AddressCard extends StatelessWidget {
  final AppAddress address;
  final VoidCallback onDelete;

  const _AddressCard({required this.address, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: address.selected ? const Color(0xFFE9FFF0) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: address.selected ? Colors.green.shade200 : Colors.black12),
                  ),
                  child: const Icon(Icons.home, color: Color(0xFFE6B932), size: 34),
                ),
                const SizedBox(height: 4),
                Text(address.distance, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(address.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(address.address, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.25)),
                const SizedBox(height: 8),
                Text('Phone number: ${address.phone}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
                const SizedBox(height: 8),
                Row(children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: kGreen)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share, color: kGreen)),
                  IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.red)),
                ]),
              ]),
            ),
            const Icon(Icons.push_pin_outlined, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class AppOrder {
  final String status, amount, date;
  final List<String> items;

  AppOrder(this.status, this.amount, this.date, this.items);
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            leading: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFE9FFF0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.check, color: kGreen, size: 36),
            ),
            title: Text(order.status, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            subtitle: Text('${order.amount} • ${order.date}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            trailing: const Icon(Icons.more_vert),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: order.items.map((e) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(child: TextButton(onPressed: () {}, child: const Text('Reorder', style: TextStyle(color: kGreen, fontSize: 18)))),
              Container(width: 1, height: 48, color: Colors.black12),
              Expanded(child: TextButton(onPressed: () {}, child: const Text('Rate order', style: TextStyle(color: kGreen, fontSize: 18)))),
            ],
          ),
        ],
      ),
    );
  }
}