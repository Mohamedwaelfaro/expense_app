import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/db_helper.dart';
import '../models/transcation.dart';

class YearlySummaryScreen extends StatefulWidget {
  @override
  _YearlySummaryScreenState createState() => _YearlySummaryScreenState();
}

class _YearlySummaryScreenState extends State<YearlySummaryScreen> {
  Map<String, Map<String, double>> _yearlyTotals = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateYearlyTotals();
  }

  Future<void> _calculateYearlyTotals() async {
    final dataList = await DBHelper.getData('transactions');
    final transactions = dataList
        .map((item) => Transaction(
              id: item['id'],
              title: item['title'],
              amount: item['amount'],
              date: DateTime.parse(item['date']),
            ))
        .toList();

    final Map<String, Map<String, double>> yearlyTotals = {};

    transactions.forEach((tx) {
      final yearKey = DateFormat.y().format(tx.date);
      final monthKey = DateFormat.MMM().format(tx.date);
      if (!yearlyTotals.containsKey(yearKey)) {
        yearlyTotals[yearKey] = {};
      }
      if (!yearlyTotals[yearKey]!.containsKey(monthKey)) {
        yearlyTotals[yearKey]![monthKey] = 0.0;
      }
      yearlyTotals[yearKey]![monthKey] =
          yearlyTotals[yearKey]![monthKey]! + tx.amount;
    });

    setState(() {
      _yearlyTotals = yearlyTotals;
      _isLoading = false;
    });
  }

  double _calculateYearTotal(String year) {
    return _yearlyTotals[year]!
        .values
        .fold(0.0, (sum, element) => sum + element);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yearly Summary',
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
              itemCount: _yearlyTotals.length,
              itemBuilder: (ctx, index) {
                final year = _yearlyTotals.keys.elementAt(index);
                final yearTotal = _calculateYearTotal(year);
                final months = _yearlyTotals[year];
                return _buildYearlyCard(year, yearTotal, months!);
              },
            ),
    );
  }

  Widget _buildYearlyCard(
      String year, double yearTotal, Map<String, double> months) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              year,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '\$${yearTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        children: months.entries.map((entry) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent.withOpacity(0.1),
                  Colors.blueAccent.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
