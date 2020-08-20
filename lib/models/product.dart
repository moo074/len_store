import 'package:len_store/models/product_category.dart';
import 'package:len_store/models/store_model.dart';
import 'package:len_store/models/product_unit.dart';

class Product extends StoreModel {
  int id;
  int productid;
  int productunitid;
  int categoryid;
  String name;
  String code;
  String where = 'productid = ?';
  ProductUnit unit;
  ProductCategory category;

  static String table = 'products';

  Product(
      {this.productid,
      this.name,
      this.productunitid,
      this.code,
      this.categoryid}) {
    id = productid;
    // unit = ProductUnit(productunitid: productunitid);
    // unit.getRecord(unit);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'code': code,
      'productunitid': productunitid,
      'categoryid': categoryid,
    };

    // if (productid != null || id != null) {
    //   map['productid'] = id;
    //   map['productid'] = productid;
    // }
    return map;
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
        productid: map['productid'],
        code: map['code'],
        name: map['name'],
        productunitid: map['productunitid'],
        categoryid: map['categoryid']);
  }

  String toString() {
    return 'id: $id, productid: $productid, productunitid: $productunitid, ' +
        'categoryid: $categoryid, name: $name, code: $code';
  }
}
