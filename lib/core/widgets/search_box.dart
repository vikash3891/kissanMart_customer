import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../theme/app_colors.dart';

/// Debounced search field with voice search support.
class SearchBox extends StatefulWidget {
  final String initial;
  final Future<void> Function(String) onChanged;
  final FocusNode? focusNode;

  const SearchBox({
    super.key,
    required this.initial,
    required this.onChanged,
    this.focusNode,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void didUpdateWidget(covariant SearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initial != oldWidget.initial &&
        widget.initial != _controller.text) {
      _controller.text = widget.initial;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startVoiceSearch(BuildContext context) async {
    final provider = context.read<ProductProvider>();

    // Prevent double tap
    if (provider.isListening) {
      provider.stopVoiceSearch();
      return;
    }

    // Capture context-dependent objects before async gap
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    // Start listening FIRST — sheet only shown if successful
    final success = await provider.startVoiceSearch((words) {
      if (!mounted) return;
      final trimmed = words.trim();
      _controller.text = trimmed;
      setState(() {});
      widget.onChanged(trimmed);
    });

    if (!mounted) return;

    if (!success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            '🎤 Microphone not available. Go to Settings → Apps → Kisaan Kart → Permissions → Allow Microphone.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Show sheet after confirmed listening started
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VoiceListeningSheet(
        onCancel: () {
          provider.stopVoiceSearch();
          nav.pop();
        },
      ),
    ).then((_) {
      // Sheet closed — ensure we stop if still listening
      provider.stopVoiceSearch();
    });
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: colors.textPrimary, fontSize: 14),
      onSubmitted: (value) {
        _debounce?.cancel();
        widget.onChanged(value.trim());
      },
      onChanged: (value) {
        setState(() {});
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(milliseconds: 350),
          () async {
            await widget.onChanged(value);
          },
        );
      },
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        prefixIcon:
            Icon(Icons.search, color: colors.textSecondary, size: 20),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon:
                    Icon(Icons.clear, color: colors.textSecondary, size: 18),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  _debounce?.cancel();
                  widget.onChanged('');
                },
              )
            : Consumer<ProductProvider>(
                builder: (ctx, provider, _) => IconButton(
                  icon: Icon(
                    provider.isListening ? Icons.mic : Icons.mic_none,
                    color: provider.isListening
                        ? colors.danger
                        : colors.primary,
                    size: 20,
                  ),
                  onPressed: provider.isListening
                      ? () => provider.stopVoiceSearch()
                      : () => _startVoiceSearch(ctx),
                ),
              ),
        hintText: 'Search for wheat, rice, mustard and more',
        hintStyle: TextStyle(color: colors.hint, fontSize: 13),
        filled: true,
        fillColor: colors.searchBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide:
              BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Voice Listening Bottom Sheet
// Watches ProductProvider.isListening and auto-closes when done
// ────────────────────────────────────────────────────────────────────────────

class _VoiceListeningSheet extends StatefulWidget {
  final VoidCallback onCancel;
  const _VoiceListeningSheet({required this.onCancel});

  @override
  State<_VoiceListeningSheet> createState() => _VoiceListeningSheetState();
}

class _VoiceListeningSheetState extends State<_VoiceListeningSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Safety auto-close after 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Consumer<ProductProvider>(
      builder: (ctx, provider, _) {
        // Auto-close when isListening becomes false
        if (!provider.isListening) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                provider.isListening ? 'Listening...' : 'Processing...',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
              ),
              const SizedBox(height: 28),
              // Pulsing mic circle with ripple
              Stack(
                alignment: Alignment.center,
                children: [
                  if (provider.isListening)
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Container(
                        width: 90 * _pulseAnim.value,
                        height: 90 * _pulseAnim.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: provider.isListening ? _pulseAnim.value : 1.0,
                      child: child,
                    ),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.isListening
                            ? colors.primary
                            : colors.border,
                      ),
                      child: const Icon(Icons.mic,
                          color: Colors.white, size: 34),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                provider.partialText.isNotEmpty
                    ? '"${provider.partialText}"'
                    : 'Say a product name clearly...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: provider.partialText.isNotEmpty
                      ? colors.textPrimary
                      : colors.textSecondary,
                  fontSize: 14,
                  fontStyle: provider.partialText.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  fontWeight: provider.partialText.isNotEmpty
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
