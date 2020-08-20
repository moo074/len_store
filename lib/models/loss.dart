import './store_model.dart';

class LossItem extends StoreModel {
  int id;
  int lossid;
  int productid;
  int categoryid;
  int productunitid;
  int costpriceid;
  int count = 1;
  String date;
  double price = 1.0;
  double get totalamount => price * count;
  String where = 'lossid = ?';
  static String table = 'loss';

  LossItem(
      {this.lossid,
      this.count,
      this.price,
      this.categoryid,
      this.productid,
      this.productunitid,
      this.costpriceid,
      this.date}) {
    id = lossid;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'count': count,
      'price': price,
      'categoryid': categoryid,
      'productid': productid,
      'productunitid': productunitid,
      'priceid': costpriceid,
      'date': date,
    };
    if (id != null) {
      map['lossid'] = id;
    }
    return map;
  }

  static LossItem fromMap(Map<String, dynamic> map) {
    return LossItem(
      lossid: map['lossid'],
      categoryid: map['categoryid'],
      productid: map['productid'],
      productunitid: map['productunitid'],
      costpriceid: map['priceid'],
      count: map['count'],
      price: map['price'],
      date: map['date'],
    );
  }

  String toString() {
    return 'lossid: $lossid, productid: $productid, categoryid: $categoryid, costpriceid: $costpriceid, ' +
        'productunitid: $productunitid, count: $count, price: $price, date: $date,  ';
  }
}
