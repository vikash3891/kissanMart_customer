import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../theme/app_colors.dart';

/// Debounced search field.
///
/// Fires [onChanged] 500 ms after the user stops typing.
/// Calls the backend via [ProductProvider.search] — no local filtering.
class SearchBox extends StatefulWidget {
  final String initial;
  final Future<void> Function(String) onChanged;

  const SearchBox({
    super.key,
    required this.initial,
    required this.onChanged,
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

  void _startVoiceSearch(BuildContext context) {
    final provider = context.read<ProductProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Listening...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.mic, size: 64, color: kGreen),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  provider.stopVoiceSearch();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );

    provider.startVoiceSearch((words) {
      _controller.text = words;
      widget.onChanged(words);
      Navigator.pop(context); // Dismiss listening bottom sheet
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        _debounce?.cancel();
        widget.onChanged(value.trim());
      },
      onChanged: (value) {
        setState(() {}); // Updates the clear button visibility
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(milliseconds: 500),
          () async {
            await widget.onChanged(value);
          },
        );
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  _debounce?.cancel();
                  widget.onChanged('');
                },
              )
            : IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () => _startVoiceSearch(context),
              ),
        hintText: 'Search for wheat, rice, mustard and more',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
