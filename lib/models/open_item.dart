import './store_model.dart';

class OpeningItem extends StoreModel {
  int id;
  int openingid;
  int productid;
  int categoryid;
  int productunitid;
  int costpriceid;
  int count = 1;
  String date;
  double price = 1.0;
  //double get totalamount => price * count;
  String where = 'openingid = ?';
  static String table = 'openingbalance';

  OpeningItem(
      {this.openingid,
      this.count,
      this.price,
      this.categoryid,
      this.productid,
      this.productunitid,
      this.costpriceid,
      this.date}) {
    id = openingid;
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
      map['openingid'] = id;
    }
    return map;
  }

  static OpeningItem fromMap(Map<String, dynamic> map) {
    return OpeningItem(
      openingid: map['openingid'],
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
    return 'openingid: $openingid, productid: $productid, categoryid: $categoryid, costpriceid: $costpriceid, ' +
        'productunitid: $productunitid, count: $count, price: $price, date: $date,  ';
  }
}
