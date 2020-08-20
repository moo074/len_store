import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/store_model.dart';

class ProductPrice extends StoreModel {
  int id;
  int productid;
  int productunitid;
  double amount;
  String date;
  bool iscost = true;
  String where = 'priceid = ?';
  static String table = 'product_price';

  ProductPrice(
      {this.id,
      this.amount,
      this.productid,
      this.productunitid,
      this.date,
      this.iscost});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'amount': amount,
      'productid': productid,
      'iscost': iscost ? 1 : 0,
      'productunitid': productunitid,
      'date': date
    };
    if (id != null) {
      map['priceid'] = id;
    }
    return map;
  }

  static ProductPrice fromMap(Map<String, dynamic> map) {
    return ProductPrice(
        id: map['priceid'],
        amount: map['amount'],
        productid: map['productid'],
        productunitid: map['productunitid'],
        date: map['date'],
        iscost: map['date'] == 1);
  }

  String toString() {
    return 'id: $id, productid: $productid, productunitid: $productunitid, amount: $amount, iscost: $iscost';
  }

  static Future<ProductPrice> getProductUnitPrice(
      bool isCost, int productid, int productunitid) async {
    ProductPrice price = new ProductPrice(iscost: isCost);
    price.where = 'productid = ? AND productunitid = ? AND iscost = ?';
    price.whereArgs = [productid, productunitid, isCost ? 1 : 0];

    List<Map<String, dynamic>> _results =
        await DBHelper.getRecord(ProductPrice.table, price);

    List<ProductPrice> prices =
        _results.map((item) => ProductPrice.fromMap(item)).toList();

    if (prices.length > 0) {
      //sort by date
      prices.sort((a, b) => b.date.compareTo(a.date));

      return prices.first;
    }

    return price;
  }
}
