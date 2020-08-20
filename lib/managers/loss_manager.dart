import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:len_store/forms/loss_form.dart';

import 'package:len_store/models/product.dart';
import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/loss.dart';

class LossManager extends StatefulWidget {
  LossManager() {
    print('constructor');
  }

  @override
  State<StatefulWidget> createState() {
    return LossManagerState();
  }
}

class LossManagerState extends State<LossManager> {
  List<LossItem> _items = [];
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LossItemForm(true)),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    print('refresh');
    List<Map<String, dynamic>> _results = await DBHelper.query(LossItem.table);

    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(ProductUnit.table);

    List<Map<String, dynamic>> _resultProducts =
        await DBHelper.query(Product.table);

    setState(() {
      _items = _results.map((item) => LossItem.fromMap(item)).toList();
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
            Text('Opening Balance'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int i) {
                  print(_items[i].toString());
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(prodName(_items[i].productid)),
                              Text(_items[i].count.toString()),
                              Text(unitName(_items[i].productunitid)),
                            ],
                          ),
                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(DateFormat('yyyy-MM-dd HH:mm')
                                  .format(DateTime.parse(_items[i].date))
                                  .toString()),
                              Text((_items[i].count * _items[i].price)
                                  .toString()),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LossItemForm(false,
                                        lossItem: _items[i])),
                              ).then((value) => refresh());
                            });
                          }));
                })
          ]),
    );
  }

  String unitName(int id) =>
      _unitNames.where((element) => element.id == id).first.name;

  String prodName(int id) =>
      _productNames.where((element) => element.id == id).first.name;
}
