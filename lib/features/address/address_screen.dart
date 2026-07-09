import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../api_models/address.dart';
import '../../providers/address_provider.dart';
import 'location_picker_screen.dart';

/// Address book screen — lists addresses from [AddressProvider].
class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  Future<void> _showDeleteConfirm(
      BuildContext context, ApiAddress address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final success =
          await context.read<AddressProvider>().deleteAddress(address.id);
      if (!success && context.mounted) {
        final error =
            context.read<AddressProvider>().error ?? 'Failed to delete address';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          if (provider.loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: Column(
          children: [
            // ── Error Banner ────────────────────────────────────────────────
            if (provider.error != null)
              Container(
                color: Colors.red[50],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                width: double.infinity,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: () => provider.refresh(),
                    ),
                  ],
                ),
              ),

            // ── Add new address CTA (Opens Google Maps Picker) ────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: kGreen),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.add_location_alt_outlined,
                      color: kGreen),
                  title: const Text(
                    'Add a new address',
                    style:
                        TextStyle(color: kGreen, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Choose Address Method',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              leading:
                                  const Icon(Icons.my_location, color: kGreen),
                              title: const Text('Use Google Maps',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle:
                                  const Text('Pinpoint your location on maps'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const LocationPickerScreen()),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.edit_note,
                                  color: Colors.orange),
                              title: const Text('Enter Address Manually',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text(
                                  'Fill details manually without maps'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AddressForm()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Content Area ────────────────────────────────────────────────
            Expanded(
              child: provider.loading && provider.addresses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.addresses.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2),
                            const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.location_off_outlined,
                                      size: 72, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text(
                                    'No Addresses Found',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    'Please add a delivery address to checkout.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.addresses.length,
                          itemBuilder: (context, index) {
                            final a = provider.addresses[index];
                            final isSelected =
                                provider.selectedAddress?.id == a.id;

                            Color badgeColor;
                            switch (a.addressType.toLowerCase()) {
                              case 'home':
                                badgeColor = kGreen;
                                break;
                              case 'work':
                                badgeColor = Colors.blue;
                                break;
                              default:
                                badgeColor = Colors.orange;
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color:
                                      isSelected ? kGreen : Colors.transparent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                // ignore: deprecated_member_use
                                leading: Radio<int>(
                                  value: a.id,
                                  // ignore: deprecated_member_use
                                  groupValue: provider.selectedAddress?.id,
                                  activeColor: kGreen,
                                  // ignore: deprecated_member_use
                                  onChanged: (id) {
                                    if (id != null) {
                                      provider.selectAddress(a);
                                    }
                                  },
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        a.fullName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            badgeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        a.addressType.toUpperCase(),
                                        style: TextStyle(
                                          color: badgeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    if (a.isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: kLightGreen,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'DEFAULT',
                                          style: TextStyle(
                                            color: kGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${a.houseNo}, ${a.area}\n${a.city}, ${a.state} - ${a.pincode}\nPhone: ${a.phone}',
                                    style: const TextStyle(height: 1.3),
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit location')),
                                    if (!a.isDefault)
                                      const PopupMenuItem(
                                          value: 'default',
                                          child: Text('Make Default')),
                                    const PopupMenuItem(
                                        value: 'delete', child: Text('Delete')),
                                  ],
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              const Text(
                                                'Choose Edit Method',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 20),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.my_location,
                                                    color: kGreen),
                                                title: const Text(
                                                    'Use Google Maps',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: const Text(
                                                    'Move map pin to update coordinates'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          LocationPickerScreen(
                                                              editItem: a),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Divider(),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.edit_note,
                                                    color: Colors.orange),
                                                title: const Text(
                                                    'Edit Details Manually',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: const Text(
                                                    'Directly edit name, phone, house details'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddressForm(item: a),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (v == 'default') {
                                      provider.setDefaultAddress(a.id);
                                    } else if (v == 'delete') {
                                      _showDeleteConfirm(context, a);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Address Form Screen ───────────────────────────────────────────────────────

class AddressForm extends StatefulWidget {
  final ApiAddress? item;
  final bool isNewPrefill;

  const AddressForm({super.key, this.item, this.isNewPrefill = false});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _pincode;
  late final TextEditingController _state;
  late final TextEditingController _city;
  late final TextEditingController _houseNo;
  late final TextEditingController _area;
  late final TextEditingController _landmark;
  late String _addressType;

  String? _error;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.item?.fullName ?? '');
    _phone = TextEditingController(text: widget.item?.phone ?? '');
    _pincode = TextEditingController(text: widget.item?.pincode ?? '');
    _state = TextEditingController(text: widget.item?.state ?? '');
    _city = TextEditingController(text: widget.item?.city ?? '');
    _houseNo = TextEditingController(text: widget.item?.houseNo ?? '');
    _area = TextEditingController(text: widget.item?.area ?? '');
    _landmark = TextEditingController(text: widget.item?.landmark ?? '');
    _addressType = widget.item?.addressType ?? 'home';
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _pincode.dispose();
    _state.dispose();
    _city.dispose();
    _houseNo.dispose();
    _area.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);

    final fullName = _fullName.text.trim();
    final phone = _phone.text.trim();
    final pincode = _pincode.text.trim();
    final state = _state.text.trim();
    final city = _city.text.trim();
    final houseNo = _houseNo.text.trim();
    final area = _area.text.trim();
    final landmark = _landmark.text.trim();

    final provider = context.read<AddressProvider>();
    bool success;

    if (widget.item == null || widget.isNewPrefill) {
      success = await provider.addAddress(
        fullName: fullName,
        phone: phone,
        pincode: pincode,
        state: state,
        city: city,
        houseNo: houseNo,
        area: area,
        landmark: landmark.isNotEmpty ? landmark : null,
        addressType: _addressType,
      );
    } else {
      success = await provider.updateAddress(
        id: widget.item!.id,
        fullName: fullName,
        phone: phone,
        pincode: pincode,
        state: state,
        city: city,
        houseNo: houseNo,
        area: area,
        landmark: landmark.isNotEmpty ? landmark : null,
        addressType: _addressType,
      );
    }

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _error = provider.error ?? 'Save failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text((widget.item == null || widget.isNewPrefill)
            ? 'Add Details'
            : 'Edit Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(
                    labelText: 'Full Name *', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone Number *', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 10 || v.trim().length > 15)
                    return 'Invalid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pincode,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Pincode *', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (v.trim().length != 6) return 'Must be 6 digits';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(
                          labelText: 'City *', border: OutlineInputBorder()),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _state,
                decoration: const InputDecoration(
                    labelText: 'State *', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _houseNo,
                decoration: const InputDecoration(
                    labelText: 'Flat / House No. *',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _area,
                decoration: const InputDecoration(
                    labelText: 'Area / Street / Colony *',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _landmark,
                decoration: const InputDecoration(
                    labelText: 'Landmark (Optional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text(
                'Address Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Home'),
                    selected: _addressType == 'home',
                    onSelected: (selected) {
                      if (selected) setState(() => _addressType = 'home');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Work'),
                    selected: _addressType == 'work',
                    onSelected: (selected) {
                      if (selected) setState(() => _addressType = 'work');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Other'),
                    selected: _addressType == 'other',
                    onSelected: (selected) {
                      if (selected) setState(() => _addressType = 'other');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: provider.loading ? null : _save,
                child: provider.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
