import 'package:flutter/material.dart';

import '../../main.dart';
import '../address/address.dart';

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