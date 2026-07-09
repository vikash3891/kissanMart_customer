import 'package:flutter/material.dart';

/// Generic scrollable screen with an [AppBar] and padded [children].
///
/// Drop-in replacement for the inline ListScreen that was inside main.dart.
class ListScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ListScreen({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: children
            .map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: w,
              ),
            )
            .toList(),
      ),
    );
  }
}
