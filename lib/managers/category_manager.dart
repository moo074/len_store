import 'package:flutter/material.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/product_category.dart';

class ProductCategoryManager extends StatefulWidget {
  final String title;
  ProductCategoryManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return ProductCategoryManagerState();
  }
}

class ProductCategoryManagerState extends State<ProductCategoryManager> {
  List<ProductCategory> _categories = [];

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
              Text('Category'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (BuildContext context, int position) {
                    var name = _categories[position].name;
                    return Card(
                        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: ListTile(
                            title: Text(name),
                            onTap: () {
                              _detailDialog(context, isNew: false, category:_categories[position]);
                            }));
                  })
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            ProductCategory category = new ProductCategory();
            _detailDialog(context, isNew: true, category: category);
          });
        },
      ),
    );
  }

  void refresh() async {
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ProductCategory.table);
    _categories = _results.map((item) => ProductCategory.fromMap(item)).toList();
    setState(() {});
  }

  _detailDialog(BuildContext context, {bool isNew, ProductCategory category}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isNew ? 'Add New Category' : 'Update Category Name'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop()),
              FlatButton(
                  child: Text('Save'), onPressed: () => _save(isNew: isNew, category: category))
            ],
            content: TextField(
              autofocus: true,
              controller:
                  TextEditingController(text: !isNew ? category.name : null),
              decoration: InputDecoration(
                  labelText: 'Name', hintText: 'e.g. Softdrinks, Liquor, Snacks'),
              onChanged: (value) {
                category.name = value;
              },
            ),
          );
        });
  }

  void _save({bool isNew, ProductCategory category}) async {
    if (isNew) {
      await DBHelper.insert(ProductCategory.table, category);
    } else {
      await DBHelper.update(ProductCategory.table, category);
    }

    setState(() {
      Navigator.of(context).pop();
    });
    refresh();
  }
}
