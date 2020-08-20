import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:len_store/models/account.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/acc_transaction.dart';

class AccountTransactionForm extends StatefulWidget {
  final AccountTransaction transaction;
  final int accountid;
  final bool isNew;

  AccountTransactionForm(this.isNew, {this.transaction, this.accountid});

  @override
  AccountTransactionFormState createState() {
    return AccountTransactionFormState();
  }
}

class AccountTransactionFormState extends State<AccountTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  AccountTransaction transaction;
  bool _isNew = true;
  String _type;
  double _prevAmountValue;
  String _prevType;
  TextEditingController _amount = new TextEditingController();

  @override
  void initState() {
    transaction = widget.transaction;
    _isNew = widget.isNew;
    if (_isNew) {
      transaction = new AccountTransaction();
      transaction.accountid = widget.accountid;
      transaction.date = DateTime.now();
    } else {
      _amount.text = transaction.amount.toString();
      _prevAmountValue = transaction.amount;
      _type = transaction.transactiontype;
      _prevType = transaction.transactiontype;
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

  Form formDetails(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          date(),
          amount(),
          transactionType(),
          Row(
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
              ])
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

  List<String> transactionTypes = ['Capital', 'Sales', 'Order', 'Expense', 'Credit Payment'];

  Container transactionType() {
    print('transactionType');
    return Container(
      child: Row(
          // Supplier or Customer
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Type'),
            SizedBox(width: 10.0),
            DropdownButton<String>(
              value: _type, //_units[_units.indexOf(_order.unit)],
              onChanged: (String value) {
                setState(() {
                  _type = value;
                  transaction.transactiontype = value;
                });
              },
              items: transactionTypes
                  .map((e) => DropdownMenuItem(child: Text(e), value: e))
                  .toList(),
            )
          ]),
    );
  }

  void _save() async {
    if (_isNew) {
      await DBHelper.insert(AccountTransaction.table, transaction);
    } else {
      await DBHelper.update(AccountTransaction.table, transaction);
    }

    Account.updateBalance(
        accountid: transaction.accountid,
        isNew: _isNew,
        curValue: transaction.amount,
        curType: transaction.transactiontype,
        prevValue: _prevAmountValue,
        prevType: _prevType);

    Navigator.pop(context);
  }
}
