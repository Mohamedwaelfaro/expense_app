import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/new_transactio.dart';
import './widgets/chart.dart';
import 'helpers/db_helper.dart';
import 'models/transcation.dart';
import 'screens/monthly_summary_screen.dart';
import 'screens/yearly_summary_screen.dart';
import 'widgets/transactio_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expesnses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        hintColor: Colors.amber,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              titleLarge: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.purple,
              ),
              labelLarge: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          toolbarTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                titleLarge: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
              .bodyMedium,
          titleTextStyle: ThemeData.light()
              .textTheme
              .copyWith(
                titleLarge: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
              .titleLarge,
          color: Colors.purple, // Set a vibrant app bar color
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.purple, // Make FAB match the app theme
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.purple, // Set button colors
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: MyHomePage(),
      routes: {
        '/monthly-summary': (ctx) => MonthlySummaryScreen(),
        '/yearly-summary': (ctx) => YearlySummaryScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final dataList = await DBHelper.getData('transactions');
    setState(() {
      _userTransactions = dataList
          .map((item) => Transaction(
                id: item['id'],
                title: item['title'],
                amount: item['amount'],
                date: DateTime.parse(item['date']),
              ))
          .toList();
    });
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) async {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });

    await DBHelper.insert('transactions', {
      'id': newTx.id,
      'title': newTx.title,
      'amount': newTx.amount,
      'date': newTx.date.toIso8601String(),
    });
  }

  void _deleteTransaction(String id) async {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
    await DBHelper.delete('transactions', id);
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction), // Add _selectedLocation
          behavior: HitTestBehavior.opaque,
        );
      },
      backgroundColor: Colors.purple.shade50, // Change background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Expenses'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          ),
          IconButton(
            icon: Icon(Icons.calendar_view_month),
            onPressed: () =>
                Navigator.of(context).pushNamed('/monthly-summary'),
          ),
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () => Navigator.of(context).pushNamed('/yearly-summary'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Card(
              elevation: 6,
              margin: EdgeInsets.all(10),
              child: Chart(_recentTransactions),
              color: Colors.purple.shade50,
            ),
            TransactionList(_userTransactions, _deleteTransaction),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
