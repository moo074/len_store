import 'package:len_store/models/store_model.dart';

class ProductUnitConversion extends StoreModel {
  int id;
  int produnitconvid;
  int productid;
  int frproductunitid;
  int toproductunitid;
  int toamount;
  int framount;
  String where = 'produnitconvid = ?';

  static String table = 'prod_unit_conversion';

  ProductUnitConversion({
    this.productid,
    this.frproductunitid,
    this.toproductunitid,
    this.toamount,
    this.framount,
    this.produnitconvid,
  }) {
    id = produnitconvid;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'toamount': toamount,
      'framount': framount,
      'productid': productid,
      'frproductunitid': frproductunitid,
      'toproductunitid': toproductunitid,
    };

    if (id != null) {
      map['produnitconvid'] = id;
    }
    return map;
  }

  static ProductUnitConversion fromMap(Map<String, dynamic> map) {
    return ProductUnitConversion(
        toamount: map['toamount'],
        framount: map['framount'],
        productid: map['productid'],
        frproductunitid: map['frproductunitid'],
        toproductunitid: map['toproductunitid'],
        produnitconvid: map['produnitconvid']);
  }

  String toString() {
    return 'produnitconvid: $produnitconvid, productid: $productid, ' +
        'frproductunitid: $frproductunitid, framount: $framount, toproductunitid: $toproductunitid, toamount: $toamount, ';
  }
}
