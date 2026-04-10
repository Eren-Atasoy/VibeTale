import 'package:flutter/material.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;
  const BookDetailsScreen({super.key, required this.bookId});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Book Details')));
}
