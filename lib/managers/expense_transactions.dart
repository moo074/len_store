import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:len_store/forms/expense_transact_form.dart';
import 'package:len_store/models/expense_transaction.dart';
import 'package:len_store/models/expense_type.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/account.dart';

class ExpenseTransactions extends StatefulWidget {
  ExpenseTransactions();

  @override
  State<StatefulWidget> createState() {
    return ExpenseTransactionsState();
  }
}

class ExpenseTransactionsState extends State<ExpenseTransactions> {
  List<ExpenseTransaction> _expTransactions = [];
  List<Account> _accounts = [];
  List<ExpenseType> _types = [];
  Row _titleRow;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _titleRow,
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _expTransactions.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Card(
                        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: ListTile(
                            title: getTitle(
                                _types,
                                _expTransactions[i].expensetypeid,
                                _expTransactions[i].amount.toString()),
                            subtitle: getTitle(
                                _accounts,
                                _expTransactions[i].accountid,
                                DateFormat('yyyy-MM-dd HH:MM')
                                    .format(_expTransactions[i].date)
                                    .toString()),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ExpenseTransactionForm(false,
                                            transaction: _expTransactions[i])),
                              ).then((value) => refresh());
                            }));
                  })
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExpenseTransactionForm(true)))
                .then((value) => refresh());
          });
        },
      ),
    );
  }

  Row getTitle(List list, int id, String rightSide) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 150,
          child: Text(list.length > 0
              ? list.where((element) => element.id == id).first.name
              : 'Expense/Account'),
        ),
        SizedBox(width: 100),
        Container(alignment: Alignment.centerRight, child: Text(rightSide)),
      ],
    );
  }

  void refresh() async {
    print('expeense transaction refresh ');
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ExpenseType.table);

    List<Map<String, dynamic>> _resultsTypes =
        await DBHelper.query(ExpenseType.table);

    List<Map<String, dynamic>> _resultsAcc =
        await DBHelper.query(ExpenseType.table);

    setState(() {
      _expTransactions =
          _results.map((item) => ExpenseTransaction.fromMap(item)).toList();
      _types = _resultsTypes.map((item) => ExpenseType.fromMap(item)).toList();
      _accounts = _resultsAcc.map((item) => Account.fromMap(item)).toList();
    });
  }
}
