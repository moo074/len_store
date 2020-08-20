import './store_model.dart';

class AccountTransaction extends StoreModel {
  int id;
  int accountid;
  DateTime date;
  String transactiontype;
  int transactionid;
  double amount;
  String where = 'acctransactionid = ?';

  static String table = 'account_transactions';

  AccountTransaction({
    this.id,
    this.accountid,
    this.date,
    this.amount,
    this.transactiontype,
    this.transactionid,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'accountid': accountid,
      'amount': amount,
      'date': date.toString(),
      'transactiontype': transactiontype,
      'transactionid': transactionid
    };
    if (id != null) {
      map['acctransactionid'] = id;
    }

    return map;
  }

  static AccountTransaction fromMap(Map<String, dynamic> map) {
    return AccountTransaction(
        id: map['acctransactionid'],
        accountid: map['accountid'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        transactiontype: map['transactiontype'],
        transactionid: map['transactionid'],);
  }
}
