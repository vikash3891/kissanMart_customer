import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// OTP login screen.
///
/// Integrates with the backend /auth/send-otp and /auth/verify-otp APIs.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();

  bool _otpSent = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _onPress() async {
    setState(() => _error = null);

    final phoneText = _phone.text.trim();
    if (phoneText.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    if (!_otpSent) {
      final success = await authProvider.sendOtp(phoneText);
      if (success) {
        setState(() => _otpSent = true);
      } else {
        setState(() => _error = authProvider.error ?? 'Failed to send OTP');
      }
      return;
    }

    final otpText = _otp.text.trim();
    if (otpText.isEmpty) {
      setState(() => _error = 'Enter OTP');
      return;
    }

    final success = await authProvider.verifyOtp(phoneText, otpText);
    if (!success) {
      setState(() => _error = authProvider.error ?? 'Verification failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Brand card ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kLightGreen, Color(0xFFFFF7DC)],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Column(
                    children: [
                      Text('🌿', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 8),
                      Text(
                        'Kisaan Kart',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Organic groceries delivered fast',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Phone field ────────────────────────────────────────────
                TextField(
                  controller: _phone,
                  enabled: !authProvider.isLoading,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: '10 digit phone number',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    counterText: '',
                  ),
                ),

                // ── OTP field ──────────────────────────────────────────────
                if (_otpSent)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: TextField(
                      controller: _otp,
                      enabled: !authProvider.isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 6, // Support standard 4 or 6 digit OTPs
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        helperText: 'Enter the code sent to your phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        counterText: '',
                      ),
                    ),
                  ),

                // ── Error message ──────────────────────────────────────────
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 18),

                // ── CTA button ─────────────────────────────────────────────
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: authProvider.isLoading ? null : _onPress,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_otpSent ? 'Verify & Continue' : 'Send OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
