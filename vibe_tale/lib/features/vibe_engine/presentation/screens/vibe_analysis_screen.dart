import 'package:flutter/material.dart';

class VibeAnalysisScreen extends StatelessWidget {
  final String bookId;
  const VibeAnalysisScreen({super.key, required this.bookId});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Vibe Analysis')));
}
