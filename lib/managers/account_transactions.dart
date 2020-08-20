import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/acc_transaction.dart';
import 'package:len_store/models/account.dart';
import 'package:len_store/forms/acc_transact_form.dart';

class AccountTransactions extends StatefulWidget {
  final Account account;
  AccountTransactions(this.account);

  @override
  State<StatefulWidget> createState() {
    return AccountTransactionsState();
  }
}

class AccountTransactionsState extends State<AccountTransactions> {
  List<AccountTransaction> _accTransactions = [];
  Account _account;
  Row _titleRow;

  @override
  void initState() {
    _account = widget.account;
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
                  itemCount: _accTransactions.length,
                  itemBuilder: (BuildContext context, int position) {
                    return Card(
                        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        color: getColor(_accTransactions[position].transactiontype),
                        child: ListTile(
                            title: getTitle(
                                _accTransactions[position].transactiontype,
                                _accTransactions[position].amount.toString()),
                            subtitle: Text(DateFormat('yyyy-MM-dd HH:MM')
                                .format(_accTransactions[position].date)
                                .toString()),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AccountTransactionForm(false,
                                            transaction:
                                                _accTransactions[position])),
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
                        builder: (context) => AccountTransactionForm(true,
                            accountid: widget.account.accountid)))
                .then((value) => refresh());
          });
        },
      ),
    );
  }

  Color getColor(String type) {
    if (type == 'Order' || type == 'Expense')
      return Colors.red[100];
    else
      return Colors.lightGreen[100];
  }

  Row getTitle(String leftSide, String rightSide) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 150,
          child: Text(leftSide),
        ),
        SizedBox(width: 100),
        Container(alignment: Alignment.centerRight, child: Text(rightSide)),
      ],
    );
  }

  void refresh() async {
    print('account transaction refresh ');
    AccountTransaction acctran = new AccountTransaction();
    acctran.where = 'accountid = ?';
    acctran.whereArgs = [widget.account.accountid];

    List<Map<String, dynamic>> _results =
        await DBHelper.getRecord(AccountTransaction.table, acctran);

    Account account = new Account(accountid: widget.account.accountid);
    account.where = 'accountid = ?';
    account.whereArgs = [widget.account.accountid];

    List<Map<String, dynamic>> _accresults =
        await DBHelper.getRecord(Account.table, account);

    setState(() {
      _accTransactions =
          _results.map((item) => AccountTransaction.fromMap(item)).toList();

      _account =
          _accresults.map((item) => Account.fromMap(item)).toList().first;
      _titleRow = getTitle(_account.name, _account.balance.toString());
    });
  }
}
