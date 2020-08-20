import 'package:len_store/tools/db_helper.dart';

import './store_model.dart';

class Account extends StoreModel {
  int id;
  int accountid;
  String name;
  double balance;
  String where = 'accountid = ?';

  static String table = 'accounts';

  Account({this.accountid, this.name, this.balance}) {
    id = accountid;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'balance': balance,
    };
    if (accountid != null || id != null) {
      map['accountid'] = id;
    }
    return map;
  }

  static Account fromMap(Map<String, dynamic> map) {
    return Account(
        accountid: map['accountid'],
        name: map['name'],
        balance: map['balance']);
  }

  static void updateBalance(
      {int accountid,
      bool isNew,
      double prevValue,
      String prevType,
      String curType,
      double curValue}) async {
    Account account = new Account(accountid: accountid);
    account.whereArgs = [accountid];

    List<Map<String, dynamic>> _accresults =
        await DBHelper.getRecord(Account.table, account);

    if (_accresults.length > 0) {
      account = _accresults.map((item) => Account.fromMap(item)).toList().first;
      print('fetched account: ' + account.name);

      //if update, compute previous balance first
      if (isNew == false) {
        if (prevType == 'Capital' || prevType == 'Sales') {
          prevValue = prevValue * (-1);
        }
        account.balance = account.balance + prevValue;
      }

      //udpate new balance
      double amount = curValue;
      if (curType == 'Order' || curType == 'Expense') {
        amount = amount * (-1);
      }
      account.balance = account.balance + amount;

      await DBHelper.update(Account.table, account);
      print('new balance: ' + account.balance.toString());
    }
  }
}
