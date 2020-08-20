import 'package:flutter/material.dart';

import 'package:len_store/models/product.dart';
import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/storage.dart';

class StorageManager extends StatefulWidget {
  StorageManager() {
    print('StorageManager constructor');
  }

  @override
  State<StatefulWidget> createState() {
    return StorageManagerState();
  }
}

class StorageManagerState extends State<StorageManager> {
  List<Storage> _items = [];
  List<ProductUnit> _unitNames = [];
  List<Product> _productNames = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Opening Balance')),
      body: _bodyContent(),
    );
  }

  void refresh() async {
    print('refresh');
    List<Map<String, dynamic>> _results = await DBHelper.query(Storage.table);

    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(ProductUnit.table);

    List<Map<String, dynamic>> _resultProducts =
        await DBHelper.query(Product.table);

    setState(() {
      _items = _results.map((item) => Storage.fromMap(item)).toList();
      print('_items' + _items.length.toString());

      _unitNames =
          _resultUnits.map((item) => ProductUnit.fromMap(item)).toList();
      print('_unitNames' + _unitNames.length.toString());
      _productNames =
          _resultProducts.map((item) => Product.fromMap(item)).toList();
      print('_productNames' + _productNames.length.toString());
    });
  }

  Widget _bodyContent() {
    print('_bodyContent');
    return Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Product Storage Count List'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int i) {
                    print(_items[i].toString());
                    return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: Text(prodName(_items[i].productid)),
                              //alignment: Alignment.centerRight,
                              //decoration: Border.all(),
                            ),
                            Text(_items[i].count.toString()),
                            Text(unitName(_items[i].productunitid)),
                          ],
                        ),
                      ),
                    );
                  })
            ]));
  }

  String unitName(int id) =>
      _unitNames.where((element) => element.id == id).first.name;

  String prodName(int id) =>
      _productNames.where((element) => element.id == id).first.name;
}
