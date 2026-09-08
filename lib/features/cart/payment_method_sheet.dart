import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/payment/payment_gateway.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/payment_provider.dart';

class PaymentMethodSheet extends StatefulWidget {
  final double amount;

  const PaymentMethodSheet({
    super.key,
    required this.amount,
  });

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  final _upiController = TextEditingController();
  final _cardNoController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _upiController.dispose();
    _cardNoController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProv = context.watch<PaymentProvider>();
    final gateways = paymentProv.availableGateways;
    final selected = paymentProv.selectedMethod;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle/Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount to pay: ₹${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Gateways List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: gateways.length,
                itemBuilder: (context, index) {
                  final gateway = gateways[index];
                  final isSelected = gateway.method == selected;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: colors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    elevation: 0,
                    child: Column(
                      children: [
                        RadioListTile<PaymentMethod>(
                          value: gateway.method,
                          groupValue: selected,
                          onChanged: (val) {
                            if (val != null) {
                              paymentProv.selectMethod(val);
                            }
                          },
                          activeColor: colors.primary,
                          title: Row(
                            children: [
                              Icon(_getIconForMethod(gateway.method),
                                  color: colors.primary),
                              const SizedBox(width: 12),
                              Text(
                                gateway.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) _buildDetailsForm(gateway.method),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Payment Mode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMethod(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cod:
        return Icons.handshake_outlined;
      case PaymentMethod.upi:
        return Icons.account_balance_outlined;
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
      case PaymentMethod.wallet:
        return Icons.wallet_outlined;
      case PaymentMethod.netBanking:
        return Icons.language_outlined;
      case PaymentMethod.razorpay:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethod.phonepe:
        return Icons.phone_android_outlined;
      case PaymentMethod.googlepay:
        return Icons.payment;
    }
  }

  Widget _buildDetailsForm(PaymentMethod m) {
    if (m == PaymentMethod.upi) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextFormField(
          controller: _upiController,
          decoration: const InputDecoration(
            hintText: 'Enter UPI ID (e.g. user@okhdfcbank)',
            prefixIcon: Icon(Icons.alternate_email, size: 18),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'UPI ID is required';
            }
            if (!v.contains('@')) {
              return 'Enter a valid UPI ID';
            }
            return null;
          },
        ),
      );
    }

    if (m == PaymentMethod.card) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            TextFormField(
              controller: _cardNoController,
              decoration: const InputDecoration(
                hintText: 'Card Number',
                prefixIcon: Icon(Icons.credit_card, size: 18),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Card number is required';
                }
                if (v.replaceAll(' ', '').length < 15) {
                  return 'Invalid card length';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cardExpiryController,
                    decoration: const InputDecoration(
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Expiry required';
                      }
                      if (!v.contains('/')) {
                        return 'Use MM/YY';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _cardCvvController,
                    decoration: const InputDecoration(
                      hintText: 'CVV',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'CVV required';
                      }
                      if (v.length < 3) {
                        return 'Invalid CVV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
