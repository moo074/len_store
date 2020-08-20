import 'package:flutter/material.dart';

import 'package:len_store/forms/unit_conversion_form.dart';
import 'package:len_store/models/prod_unit_conversion.dart';
import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/product.dart';

class UnitConversionManager extends StatefulWidget {
  final Product product;
  UnitConversionManager(this.product);

  @override
  State<StatefulWidget> createState() {
    return UnitConversionManagerState();
  }
}

class UnitConversionManagerState extends State<UnitConversionManager> {
  List<ProductUnitConversion> _conversions = [];
  Product _product;
  List<ProductUnit> _units = [];

  @override
  void initState() {
    _product = widget.product;
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
                builder: (context) => UnitConversionForm(
                      true,
                      productid: _product.productid,
                    )),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    //get prices of the product
    ProductUnitConversion unitConversion =
        new ProductUnitConversion(productid: _product.id);
    unitConversion.where = 'productid = ?';
    unitConversion.whereArgs = [_product.id];

    List<Map<String, dynamic>> _results =
        await DBHelper.getRecord(ProductUnitConversion.table, unitConversion);

    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(ProductUnit.table);

    setState(() {
      _conversions =
          _results.map((item) => ProductUnitConversion.fromMap(item)).toList();

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
            Text('UNIT CONVERSIONS'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _conversions.length,
                itemBuilder: (BuildContext context, int position) {
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Text(unitName(
                                  _conversions[position].frproductunitid) +
                              ' to ' +
                              unitName(_conversions[position].toproductunitid)),
                          subtitle: Text(
                              _conversions[position].framount.toString() +
                                  ' to ' +
                                  _conversions[position].toamount.toString()),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        new UnitConversionForm(
                                            false,
                                            conversion:
                                                _conversions[position])),
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
