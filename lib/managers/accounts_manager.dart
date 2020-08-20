import 'package:flutter/material.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/account.dart';

import 'account_transactions.dart';

class AccountsManager extends StatefulWidget {
  final String title;
  AccountsManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return AccountsManagerState();
  }
}

class AccountsManagerState extends State<AccountsManager> {
  List<Account> _accounts = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Accounts'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _accounts.length,
                  itemBuilder: (BuildContext context, int position) {
                    return Card(
                        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: ListTile(
                            title: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 130, child: Text(_accounts[position].name)),
                                SizedBox(width: 100,),
                                SizedBox(child: Text(_accounts[position].balance.toString())),
                                IconButton(
                                  alignment: Alignment.centerRight,
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _detailDialog(context,
                                        isNew: false,
                                        account: _accounts[position]);
                                  },
                                )
                              ],
                            )),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AccountTransactions(_accounts[position])
                                          ),
                              ).then((value) => refresh());
                            }));
                  })
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            Account account = new Account();
            _detailDialog(context, isNew: true, account: account);
          });
        },
      ),
    );
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DBHelper.query(Account.table);
    _accounts = _results.map((item) => Account.fromMap(item)).toList();
    setState(() {});
  }

  _detailDialog(BuildContext context, {bool isNew, Account account}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isNew ? 'Add New Account' : 'Update Account Name'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop()),
              FlatButton(
                  child: Text('Save'),
                  onPressed: () => _save(isNew: isNew, account: account))
            ],
            content: TextField(
              autofocus: true,
              controller:
                  TextEditingController(text: !isNew ? account.name : null),
              decoration: InputDecoration(
                  labelText: 'Name', hintText: 'e.g. Cash In Hand, Bank'),
              onChanged: (value) {
                account.name = value;
              },
            ),
          );
        });
  }

  void _save({bool isNew, Account account}) async {
    if (isNew) {
      await DBHelper.insert(Account.table, account);
    } else {
      await DBHelper.update(Account.table, account);
    }

    setState(() {
      Navigator.of(context).pop();
    });
    refresh();
  }
}
