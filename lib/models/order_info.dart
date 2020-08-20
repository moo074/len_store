import './store_model.dart';

class OrderInfo extends StoreModel {
  int id;
  int peopleid;
  int accountid;
  String date;
  double totalamount;
  bool ispaid = true;
  bool isorder = true;
  bool iscomplete = false;
  String where = 'orderid = ?';
  static String table = 'orders';

  OrderInfo(
      {this.id,
      this.peopleid,
      this.accountid,
      this.date,
      this.totalamount,
      this.ispaid,
      this.iscomplete,
      this.isorder});

  @override
  Map<String, dynamic> toMap() {
    print(ispaid);
    Map<String, dynamic> map = {
      'peopleid': peopleid,
      'accountid': accountid,
      'date': date,
      'totalamount': totalamount,
      'ispaid': ispaid ? 1 : 0,
      'isorder': isorder ? 1 : 0,
      'iscomplete': iscomplete ? 1 : 0,
    };
    if (id != null) {
      map['orderid'] = id;
    }
    return map;
  }

  static OrderInfo fromMap(Map<String, dynamic> map) {
    return OrderInfo(
        id: map['orderid'],
        accountid: map['accountid'],
        peopleid: map['peopleid'],
        date: map['date'],
        totalamount: map['totalamount'],
        ispaid: (map['ispaid'] == 1),
        isorder: (map['isorder'] == 1),
        iscomplete: (map['iscomplete'] == 1));
  }

  String toString() {
    return 'iscomplete: $iscomplete, id: $id, peopleid: $peopleid, isorder: $isorder, ' +
        'date: $date, accountid: $accountid, totalamount: $totalamount, ispaid: $ispaid ';
  }
}
