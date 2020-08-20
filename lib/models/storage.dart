import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/store_model.dart';
//import 'package:len_store/models/.dart';

class Storage extends StoreModel {
  int id;
  int storageid;
  int productid;
  int categoryid;
  int productunitid;
  int costpriceid;
  int count = 1;
  double price = 1;
  String date;
  String where = 'storageid = ?';
  static String table = 'product_storage';

  Storage(
      {this.storageid,
      this.count,
      this.price,
      this.categoryid,
      this.productid,
      this.productunitid,
      this.costpriceid,
      this.date}) {
    id = storageid;
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
      map['storageid'] = id;
    }
    return map;
  }

  static Storage fromMap(Map<String, dynamic> map) {
    return Storage(
      storageid: map['storageid'],
      categoryid: map['categoryid'],
      productid: map['productid'],
      productunitid: map['productunitid'],
      costpriceid: map['priceid'],
      count: map['count'],
      price: map['price'],
      date: map['date'],
    );
  }

  static void updateBalance(
      {bool isUpdate,
      bool isDeduct,
      int categoryid,
      int productid,
      int productunitid,
      int costpriceid,
      int prevValue,
      int curValue,
      double price}) async {
    Storage storage = new Storage(
        categoryid: categoryid,
        productid: productid,
        productunitid: productunitid,
        costpriceid: costpriceid);
    storage.where = 'productid = ? AND productunitid = ? AND priceid = ?';
    storage.whereArgs = [productid, productunitid, costpriceid];

    List<Map<String, dynamic>> _results =
        await DBHelper.getRecord(Storage.table, storage);

    if (_results.length > 0) {
      storage = _results.map((item) => Storage.fromMap(item)).toList().first;
      print('fetched product storage: ' + storage.productid.toString());

      //set correct process if add or deduct storage
      if (isDeduct) {
        prevValue = -1 * (prevValue == null ? 0 : prevValue);
        curValue = -1 * curValue;
      }

      //if update, compute previous balance first
      if (isUpdate) {
        storage.count = storage.count - prevValue;
      }

      //udpate new balance
      storage.count = storage.count + curValue;

      await DBHelper.update(Storage.table, storage);
      print('new balance: ' + storage.count.toString());
    } else {
      storage.date = DateTime.now().toString();
      storage.price = price;
      storage.count = curValue;
      addNewBalance(storage);
    }
  }

  static void addNewBalance(Storage storage) async {
    await DBHelper.insert(Storage.table, storage);
    print('new storage balance created ');
  }

  String toString() {
    return 'storageid: $storageid, productid: $productid, categoryid: $categoryid, costpriceid: $costpriceid, ' +
        'productunitid: $productunitid, count: $count, price: $price, date: $date,  ';
  }
}
