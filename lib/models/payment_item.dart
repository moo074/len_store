import 'package:len_store/tools/db_helper.dart';

import './store_model.dart';

class PaymentItem extends StoreModel {
  int id;
  int paymentid;
  int salesid;
  int customerid;
  DateTime date;
  double amount;
  String where = 'paymentitemid = ?';

  static String table = 'payment_items';

  PaymentItem(
      {this.id,
      this.paymentid,
      this.salesid,
      this.amount,
      this.customerid,
      this.date});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'paymentid': paymentid,
      'orderid': salesid,
      'peopleid': customerid,
      'date': date.toString(),
      'amount': amount,
    };
    if (id != null) {
      map['paymentitemid'] = id;
    }
    return map;
  }

  static PaymentItem fromMap(Map<String, dynamic> map) {
    return PaymentItem(
        id: map['paymentitemid'],
        paymentid: map['paymentid'],
        salesid: map['orderid'],
        customerid: map['peopleid'],
        date: DateTime.parse(map['date'].toString()),
        amount: map['amount']);
  }

  static void createPaymentItem(
      {int paymentid,
      int salesid,
      int customerid,
      DateTime date,
      double amount}) async {
    PaymentItem item = new PaymentItem(
        paymentid: paymentid,
        salesid: salesid,
        customerid: customerid,
        date: date,
        amount: amount);

    await DBHelper.insert(PaymentItem.table, item);
    print('payment item created');
  }
}
