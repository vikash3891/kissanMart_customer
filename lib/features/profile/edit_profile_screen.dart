import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _profileImagePath;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _profileImagePath = profile?.profileImagePath;
    _nameController.addListener(_onChanged);
    _emailController.addListener(_onChanged);
  }

  void _onChanged() {
    final profile = context.read<ProfileProvider>().profile;
    final changed = _nameController.text != (profile?.name ?? '') ||
        _emailController.text != (profile?.email ?? '') ||
        _profileImagePath != profile?.profileImagePath;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Choose Source dialog
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (_profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, null),
              ),
          ],
        ),
      ),
    );

    if (source == null &&
        _profileImagePath != null &&
        source != ImageSource.gallery &&
        source != ImageSource.camera) {
      // User chose to remove photo
      setState(() {
        _profileImagePath = null;
        _onChanged();
      });
      return;
    }

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
          _onChanged();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<ProfileProvider>().updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          profileImagePath: _profileImagePath,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Profile updated'),
            backgroundColor: context.colors.primary),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final colors = context.colors;
    final profile = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasLocalImage =
        _profileImagePath != null && File(_profileImagePath!).existsSync();

    // Capitalize role properly: "customer" → "Customer"
    final rawRole = profile?.role ?? 'customer';
    final displayRole = rawRole.isEmpty
        ? 'Customer'
        : '${rawRole[0].toUpperCase()}${rawRole.substring(1).toLowerCase()}';

    // Shared input decoration factory for uniform fields
    InputDecoration _fieldDec({
      required String label,
      required IconData icon,
      bool readOnly = false,
    }) {
      final bg = readOnly
          ? (isDark
              ? colors.surface.withValues(alpha: 0.5)
              : const Color(0xFFF0F0F0))
          : colors.surface;
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: readOnly
                  ? colors.border.withValues(alpha: 0.4)
                  : colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.danger, width: 2),
        ),
        labelStyle: TextStyle(
          color: readOnly ? colors.textSecondary : colors.hint,
          fontSize: 14,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar ─────────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor:
                              colors.primary.withValues(alpha: 0.1),
                          backgroundImage: hasLocalImage
                              ? FileImage(File(_profileImagePath!))
                              : null,
                          child: !hasLocalImage
                              ? Text(
                                  (profile?.name.isNotEmpty == true)
                                      ? profile!.name[0].toUpperCase()
                                      : '👤',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: colors.surface, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 32),

              // ── Phone (read-only) ───────────────────────────────────────────
              TextFormField(
                initialValue: profile?.phone ?? '',
                readOnly: true,
                style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500),
                decoration: _fieldDec(
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 16),

              // ── Full Name ───────────────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500),
                decoration: _fieldDec(
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Email ───────────────────────────────────────────────────────
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500),
                decoration: _fieldDec(
                  label: 'Email',
                  icon: Icons.email_outlined,
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && !v.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Account Type (read-only, capitalized) ───────────────────────
              TextFormField(
                initialValue: displayRole,
                readOnly: true,
                style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500),
                decoration: _fieldDec(
                  label: 'Account Type',
                  icon: Icons.badge_outlined,
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 32),

              // ── Save Button ─────────────────────────────────────────────────
              AnimatedOpacity(
                opacity: _hasChanges ? 1.0 : 0.6,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed:
                        _hasChanges && !provider.loading ? _save : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: provider.loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
