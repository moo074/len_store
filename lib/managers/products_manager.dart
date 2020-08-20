import 'package:flutter/material.dart';

import 'package:len_store/forms/product_form.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/product.dart';

class ProductsManager extends StatefulWidget {
  final String title;
  ProductsManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return ProductsManagerState();
  }
}

class ProductsManagerState extends State<ProductsManager> {
  List<Product> _products = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductForm(true)),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DBHelper.query(Product.table);

    setState(() {
      _products = _results.map((item) => Product.fromMap(item)).toList();
    });
  }

  Widget _bodyContent() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Products'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _products.length,
                itemBuilder: (BuildContext context, int position) {
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Text(_products[position].name),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new ProductForm(false,
                                        product: _products[position])),
                              ).then((value) => refresh());
                            });
                          }));
                })
          ]),
    );
  }
}
