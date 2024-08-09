import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/db_helper.dart';
import '../models/transcation.dart';

class MonthlySummaryScreen extends StatefulWidget {
  @override
  _MonthlySummaryScreenState createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  Map<String, double> _monthlyTotals = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateMonthlyTotals();
  }

  Future<void> _calculateMonthlyTotals() async {
    final dataList = await DBHelper.getData('transactions');
    final transactions = dataList
        .map((item) => Transaction(
              id: item['id'],
              title: item['title'],
              amount: item['amount'],
              date: DateTime.parse(item['date']),
            ))
        .toList();

    final Map<String, double> monthlyTotals = {};

    transactions.forEach((tx) {
      final monthKey = DateFormat.yM().format(tx.date);
      if (!monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] = 0.0;
      }
      monthlyTotals[monthKey] = monthlyTotals[monthKey]! + tx.amount;
    });

    setState(() {
      _monthlyTotals = monthlyTotals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Summary',
            style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _monthlyTotals.length,
              itemBuilder: (ctx, index) {
                final month = _monthlyTotals.keys.elementAt(index);
                final total = _monthlyTotals[month];
                return _buildSummaryCard(month, total!);
              },
            ),
    );
  }

  Widget _buildSummaryCard(String month, double total) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          _showDetailsDialog(month, total);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(String month, double total) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$month Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text('Total spending for $month is \$${total.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
