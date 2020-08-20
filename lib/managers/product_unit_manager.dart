import 'package:flutter/material.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/product_unit.dart';

class ProductUnitManager extends StatefulWidget {
  final String title;
  ProductUnitManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return ProductUnitManagerState();
  }
}

class ProductUnitManagerState extends State<ProductUnitManager> {
  List<ProductUnit> _units = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Product Units'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _units.length,
                  itemBuilder: (BuildContext context, int position) {
                    var name = _units[position].name;
                    return Card(
                        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: ListTile(
                            title: Text(name),
                            onTap: () {
                              _detailDialog(context, isNew: false, unit:_units[position]);
                            }));
                  })
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            ProductUnit unit = new ProductUnit();
            _detailDialog(context, isNew: true, unit: unit);
          });
        },
      ),
    );
  }

  void refresh() async {
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ProductUnit.table);
    _units = _results.map((item) => ProductUnit.fromMap(item)).toList();
    setState(() {});
  }

  _detailDialog(BuildContext context, {bool isNew, ProductUnit unit}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isNew ? 'Add New Unit' : 'Update Unit Name'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop()),
              FlatButton(
                  child: Text('Save'), onPressed: () => _save(isNew: isNew, unit: unit))
            ],
            content: TextField(
              autofocus: true,
              controller:
                  TextEditingController(text: !isNew ? unit.name : null),
              decoration: InputDecoration(
                  labelText: 'Name', hintText: 'e.g. Liter, Kilo, 12Oz, Case'),
              onChanged: (value) {
                unit.name = value;
              },
            ),
          );
        });
  }

  void _save({bool isNew, ProductUnit unit}) async {
    if (isNew) {
      await DBHelper.insert(ProductUnit.table, unit);
    } else {
      await DBHelper.update(ProductUnit.table, unit);
    }

    setState(() {
      Navigator.of(context).pop();
    });
    refresh();
  }
}
