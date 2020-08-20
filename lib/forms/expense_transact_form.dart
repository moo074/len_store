import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:len_store/models/account.dart';
import 'package:len_store/models/expense_type.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/expense_transaction.dart';

class ExpenseTransactionForm extends StatefulWidget {
  final ExpenseTransaction transaction;
  final bool isNew;

  ExpenseTransactionForm(this.isNew, {this.transaction});

  @override
  ExpenseTransactionFormState createState() {
    return ExpenseTransactionFormState();
  }
}

class ExpenseTransactionFormState extends State<ExpenseTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  ExpenseTransaction transaction;
  bool _isNew = true;
  double _prevAmountValue;
  List<ExpenseType> _types = [];
  List<Account> _accounts = [];
  TextEditingController _amount = new TextEditingController();
  TextEditingController _desc = new TextEditingController();

  @override
  void initState() {
    transaction = widget.transaction;
    _isNew = widget.isNew;
    setResources();

    if (_isNew) {
      transaction = new ExpenseTransaction();
      transaction.date = DateTime.now();
      if (_accounts.length > 0) transaction.accountid = _accounts.first.id;
      if (_types.length > 0) transaction.expensetypeid = _types.first.id;
    } else {
      _amount.text = transaction.amount.toString();
      _desc.text = transaction.description;
      _prevAmountValue = transaction.amount;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_isNew);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isNew ? 'New Account Transaction' : "Update Account Transaction"),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          //decoration: Decoration(style Border.all(color: Colors.black)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [formDetails(context)])),
    );
  }

  void setResources() async {
    print('setResources');
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ExpenseType.table);

    List<Map<String, dynamic>> _resultsAcc =
        await DBHelper.query(ExpenseType.table);

    setState(() {
      if (_results.length < 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Set Expense Types first."),
              );
            });
      } else {
        _types = _results.map((item) => ExpenseType.fromMap(item)).toList();
      }
      
      _accounts = _resultsAcc.map((item) => Account.fromMap(item)).toList();
    });
  }

  Form formDetails(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          date(),
          amount(),
          account(),
          expenseType(),
          formButtons(),
        ],
      ),
    );
  }

  TextFormField amount() {
    return TextFormField(
      controller: _amount,
      decoration: InputDecoration(labelText: 'Amount', hintText: '1.00'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter amount';
        }
        return null;
      },
      onChanged: (value) {
        transaction.amount = double.tryParse(value);
      },
    );
  }

  TextFormField description() {
    return TextFormField(
      controller: _desc,
      decoration:
          InputDecoration(labelText: 'Description', hintText: 'New case'),
      onChanged: (value) {
        transaction.description = value;
      },
    );
  }

  Row date() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Total Amount '),
          Text(DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(transaction.date)
              .toString()),
        ]);
  }

  ExpenseType getExpenseValue() {
    return (_types.length > 0)
        ? _isNew && transaction.expensetypeid == null
            ? _types.first
            : _types
                .where((element) => element.id == transaction.expensetypeid)
                .toList()
                .first
        : null;
  }

  Container expenseType() {
    return Container(
      child: Row(
          // Supplier or Customer
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Expense Type'),
            SizedBox(width: 10.0),
            DropdownButton<ExpenseType>(
              value: getExpenseValue(),
              onChanged: (ExpenseType value) {
                setState(() {
                  transaction.expensetypeid = value.id;
                  print(value.name);
                });
              },
              items: _types != null
                  ? _types.map((ExpenseType unit) {
                      return DropdownMenuItem<ExpenseType>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  Account getAccountValue() {
    return (_accounts.length > 0)
        ? _isNew && transaction.accountid == null
            ? _accounts.first
            : _accounts
                .where((element) => element.id == transaction.accountid)
                .toList()
                .first
        : null;
  }

  Container account() {
    return Container(
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Account'),
            SizedBox(width: 10.0),
            DropdownButton<Account>(
              value: getAccountValue(),
              onChanged: (Account value) {
                setState(() {
                  transaction.accountid = value.id;
                  print(value.name);
                });
              },
              items: _accounts != null
                  ? _accounts.map((Account unit) {
                      return DropdownMenuItem<Account>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  Row formButtons() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _save();
                }
              },
              child: Text('Save'),
            ),
          ),
          SizedBox(width: 10.0),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ),
        ]);
  }

  void _save() async {
    if (_isNew) {
      await DBHelper.insert(ExpenseTransaction.table, transaction);
    } else {
      await DBHelper.update(ExpenseTransaction.table, transaction);
    }

    Account.updateBalance(
        accountid: transaction.accountid,
        isNew: _isNew,
        curValue: transaction.amount,
        curType: 'Expense',
        prevValue: _prevAmountValue,
        prevType: 'Expense');

    Navigator.pop(context);
  }
}
