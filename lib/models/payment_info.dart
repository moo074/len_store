import './store_model.dart';

class PaymentInfo extends StoreModel {
  int id;
  int customerid;
  int accountid;
  bool iscomplete;
  DateTime date;
  double amount;
  String where = 'paymentid = ?';

  static String table = 'payments';

  PaymentInfo(
      {this.id,
      this.amount,
      this.customerid,
      this.accountid,
      this.iscomplete,
      this.date});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'peopleid': customerid,
      'accountid': accountid,
      'iscomplete': iscomplete ? 1 : 0,
      'date': date.toString(),
      'amount': amount,
    };
    if (id != null) {
      map['paymentid'] = id;
    }
    return map;
  }

  static PaymentInfo fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
        id: map['paymentid'],
        customerid: map['peopleid'],
        accountid: map['accountid'],
        iscomplete: map['iscomplete'] == 1,
        date: DateTime.parse(map['date'].toString()),
        amount: map['amount']);
  }

  String toString() {
    return 'paymentid: $id, peopleid: $customerid, accountid: $accountid, iscomplete: $iscomplete, date: $date, amount: $amount,';
  }
}
