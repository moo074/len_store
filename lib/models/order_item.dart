import './store_model.dart';

class OrderItem extends StoreModel {
  int id;
  int orderid;
  int categoryid;
  int productid;
  int productunitid;
  int costpriceid;
  int count = 1;
  String date;
  double price = 1.0;
  double get totalamount => price * count;
  bool isorder = true;
  String where = 'orderitemid = ?';
  String table = 'orderitems';

  OrderItem(
      {this.id,
      this.orderid,
      this.count,
      this.price,
      this.categoryid,
      this.costpriceid,
      this.productid,
      this.productunitid,
      this.isorder,
      this.date});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'orderid': orderid,
      'count': count,
      'price': price,
      'productid': productid,
      'priceid': costpriceid,
      'categoryid': categoryid,
      'productunitid': productunitid,
      'date': date,
      'isorder': isorder ? 1 : 0,
    };
    if (id != null) {
      map['orderitemid'] = id;
    }
    return map;
  }

  static OrderItem fromMap(Map<String, dynamic> map) {
    return OrderItem(
        id: map['orderitemid'],
        orderid: map['orderid'],
        categoryid: map['categoryid'],
        productid: map['productid'],
        costpriceid: map['priceid'],
        productunitid: map['productunitid'],
        count: map['count'],
        price: map['price'],
        date: map['date'],
        isorder: map['date'] == 1);
  }

  String toString() {
    return 'id: $id, orderid: $orderid, productid: $productid, ' +
        'categoryid: $categoryid, count: $count, price: $price, date: $date,  ' +
        'productunitid: $productunitid, costpriceid: $costpriceid,  isorder:$isorder';
  }
}
