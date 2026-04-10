import 'package:flutter/material.dart';

class ImmersiveReadScreen extends StatelessWidget {
  final String bookId;
  const ImmersiveReadScreen({super.key, required this.bookId});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Immersive Read')));
}
