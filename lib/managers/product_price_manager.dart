import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:len_store/forms/price_form.dart';
import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/product_price.dart';
import 'package:len_store/models/product.dart';

class ProductPriceManager extends StatefulWidget {
  final bool iscost;
  final Product product;
  ProductPriceManager(this.product, {this.iscost});

  @override
  State<StatefulWidget> createState() {
    return ProductPriceManagerState();
  }
}

class ProductPriceManagerState extends State<ProductPriceManager> {
  List<ProductPrice> _prices = [];
  bool _isCost = true;
  Product _product;
  List<ProductUnit> _units = [];

  @override
  void initState() {
    _product = widget.product;
    _isCost = widget.iscost;
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_product.name)),
      body: _bodyContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductPriceForm(
                      true,
                      isCost: _isCost,
                      productid: _product.productid,
                    )),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    //get prices of the product
    ProductPrice price = new ProductPrice(
        productid: _product.id,
        productunitid: _product.productunitid,
        iscost: _isCost);
    price.where = 'productid = ? AND iscost = ?';
    price.whereArgs = [_product.id, _isCost ? 1 : 0];

    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(ProductUnit.table);

    List<Map<String, dynamic>> _results =
        await DBHelper.getRecord(ProductPrice.table, price);
    setState(() {
      _prices = _results.map((item) => ProductPrice.fromMap(item)).toList();

      _units = _resultUnits.map((item) => ProductUnit.fromMap(item)).toList();
    });
  }

  Widget _bodyContent() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_isCost ? 'Cost Prices' : 'Selling Prices'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _prices.length,
                itemBuilder: (BuildContext context, int position) {
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Text(_prices[position].amount.toString() +
                              ' per ' +
                              unitName(_prices[position].productunitid)),
                          subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                              .format(DateTime.parse(_prices[position].date))
                              .toString()),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new ProductPriceForm(
                                        false,
                                        isCost: _isCost,
                                        price: _prices[position])),
                              ).then((value) => refresh());
                            });
                          }));
                })
          ]),
    );
  }

  String unitName(int productunitid) => _units
      .where((element) => element.productunitid == productunitid)
      .first
      .name;
}
