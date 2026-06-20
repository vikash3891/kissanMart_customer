import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/addressItems.dart';

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