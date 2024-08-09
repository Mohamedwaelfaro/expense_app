import 'dart:io';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  File? image;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.image,
  });
}
