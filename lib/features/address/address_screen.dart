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
    final colors = context.colors;

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
                  side: BorderSide(color: colors.primary),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(Icons.add_location_alt_outlined,
                      color: colors.primary),
                  title: Text(
                    'Add a new address',
                    style:
                        TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
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
                                  Icon(Icons.my_location, color: colors.primary),
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
                  : provider.addresses.isEmpty && provider.error == null
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
                                badgeColor = colors.primary;
                                break;
                              case 'work':
                                badgeColor = Colors.blue;
                                break;
                              default:
                                badgeColor = Colors.orange;
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isSelected ? 2 : 0.5,
                              shadowColor: Colors.black.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.border.withValues(alpha: 0.5),
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => provider.selectAddress(a),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Radio selector
                                      Radio<int>(
                                        value: a.id,
                                        groupValue: provider.selectedAddress?.id,
                                        activeColor: colors.primary,
                                        visualDensity: VisualDensity.compact,
                                        onChanged: (id) {
                                          if (id != null) provider.selectAddress(a);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      // Content column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Full name — full width
                                            Text(
                                              a.fullName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            // Badges below the name
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                _AddressBadge(
                                                  label: a.addressType.isEmpty
                                                      ? 'HOME'
                                                      : a.addressType.toUpperCase(),
                                                  icon: a.addressType.toLowerCase() == 'work'
                                                      ? Icons.work_outline
                                                      : a.addressType.toLowerCase() == 'other'
                                                          ? Icons.place_outlined
                                                          : Icons.home_outlined,
                                                  color: badgeColor,
                                                ),
                                                if (a.isDefault)
                                                  _AddressBadge(
                                                    label: 'DEFAULT',
                                                    icon: Icons.check_circle_outline,
                                                    color: colors.primary,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            // Address lines
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.location_on_outlined,
                                                    size: 14,
                                                    color: colors.textSecondary),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${a.houseNo}, ${a.area}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: colors.textPrimary,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 18),
                                              child: Text(
                                                '${a.city} • ${a.state} - ${a.pincode}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone_outlined,
                                                    size: 13,
                                                    color: colors.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  a.phone,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: colors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Menu
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert,
                                            color: colors.textSecondary),
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit location')),
                                          if (!a.isDefault)
                                            const PopupMenuItem(
                                                value: 'default',
                                                child: Text('Make Default')),
                                          const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete')),
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
                                                      leading: Icon(
                                                          Icons.my_location,
                                                          color: colors.primary),
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
                                    ],
                                  ),
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

// ─── Address Badge helper ─────────────────────────────────────────────────────

/// A pill badge chip for address type (HOME, WORK, OTHER) and DEFAULT.
class _AddressBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _AddressBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
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
    final colors = context.colors;

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
                  backgroundColor: colors.primary,
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
