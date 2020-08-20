import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/store_model.dart';

class ProductUnit extends StoreModel {
  static String table = 'product_units';
  int id;
  int productunitid;
  String name;
  String where = 'productunitid = ?';

  ProductUnit({this.productunitid, this.name}) {
    if (productunitid != null) {
      id = productunitid;
    }
  }

  //get record details
  getRecord(ProductUnit unit) async {
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ProductUnit.table);
    if (_results.length > 0) {
      unit = _results.map((item) => ProductUnit.fromMap(item)).toList().first;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {'name': name};

    if (productunitid != null || id != null) {
      map['productunitid'] = id;
      map['productunitid'] = productunitid;
    }
    return map;
  }

  static ProductUnit fromMap(Map<String, dynamic> map) {
    return ProductUnit(productunitid: map['productunitid'], name: map['name']);
  }
}
