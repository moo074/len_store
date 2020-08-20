import 'package:flutter/material.dart';

import 'package:len_store/managers/prod_unit_conv_manager.dart';
import 'package:len_store/models/product_category.dart';
import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/product.dart';
import 'package:len_store/models/product_price.dart';
import 'package:len_store/managers/product_price_manager.dart';

class ProductForm extends StatefulWidget {
  final Product product;
  final bool isNew;

  ProductForm(this.isNew, {this.product});

  @override
  ProductFormState createState() {
    return ProductFormState();
  }
}

class ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  Product product;
  bool _isNew = true;
  List<ProductUnit> _units = [];
  List<ProductCategory> _categories = [];
  double _costPrice = 19.50;
  double _sellPrice = 25.00;

  void setResources() async {
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ProductUnit.table);

    List<Map<String, dynamic>> _resultsCat =
        await DBHelper.query(ProductCategory.table);

    setState(() {
      if (_results.length < 1 || _resultsCat.length < 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Set Units or Product Categories first."),
              );
            });
      } else {
        _units = _results.map((item) => ProductUnit.fromMap(item)).toList();
        _categories =
            _resultsCat.map((item) => ProductCategory.fromMap(item)).toList();
      }

      if (!_isNew) {
        updatePrices(true);
        updatePrices(false);
      }
    });
  }

  void updatePrices(bool isCost) async {
    //get prices of the product
    ProductPrice price = new ProductPrice(iscost: isCost);
    price.where = 'productid = ? AND productunitid = ? AND iscost = ?';
    price.whereArgs = [product.id, product.productunitid, isCost ? 1 : 0];

    List<Map<String, dynamic>> _results =
        await DBHelper.getRecord(ProductPrice.table, price);

    List<ProductPrice> prices =
        _results.map((item) => ProductPrice.fromMap(item)).toList();

    print('price update');
    setState(() {
      if (prices.length > 0) {
        //sort by date
        prices.sort((a, b) => b.date.compareTo(a.date));

        print(prices.first.amount.toString());
        if (isCost) {
          _costPrice = prices.first.amount;
        } else {
          _sellPrice = prices.first.amount;
        }
      }
    });
  }

  @override
  void initState() {
    product = widget.product;
    _isNew = widget.isNew;
    if (_isNew) product = new Product();
    print('it goes here too XD ');
    setResources();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_isNew);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_isNew ? 'New Product' : "Update Product"),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          //decoration: Decoration(style Border.all(color: Colors.black)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                productDetails(context),
                productPrices(),
                unitConversions(),
              ])),
    );
  }

  Form productDetails(BuildContext context) {
    print(product.toString());
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: TextEditingController(text: product.code),
            decoration:
                InputDecoration(labelText: 'Code', hintText: 'RK, RH1L'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter code';
              }
              return null;
            },
            onChanged: (value) {
              product.code = value;
            },
          ),
          TextFormField(
            controller: TextEditingController(text: product.name),
            decoration: InputDecoration(
                labelText: 'Name', hintText: 'Royal, Red Horse'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
            onChanged: (value) {
              product.name = value;
            },
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Main Product Unit'),
                SizedBox(width: 10.0),
                DropdownButton<ProductUnit>(
                  hint: Text('Main Product Unit'),
                  value: getUnitValue(), //_units[_units.indexOf(product.unit)],
                  onChanged: (ProductUnit value) {
                    setState(() {
                      product.productunitid = value.id;
                    });
                  },
                  items: _units != null
                      ? _units.map((ProductUnit unit) {
                          return DropdownMenuItem<ProductUnit>(
                              value: unit, child: Text(unit.name));
                        }).toList()
                      : null,
                )
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Product Category'),
                SizedBox(width: 10.0),
                DropdownButton<ProductCategory>(
                  hint: Text('Product Category'),
                  value: getCatValue(),
                  onChanged: (ProductCategory value) {
                    setState(() {
                      product.categoryid = value.id;
                    });
                  },
                  items: _categories != null
                      ? _categories.map((ProductCategory category) {
                          return DropdownMenuItem<ProductCategory>(
                              value: category, child: Text(category.name));
                        }).toList()
                      : null,
                )
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _save(product);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save'),
                  ),
                ),
                SizedBox(width: 10.0),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ),
              ])
        ],
      ),
    );
  }

  ProductUnit getUnitValue() {
    return product.productunitid == null
        ? null
        : (_units.length > 0)
            ? _units
                .where((element) => element.id == product.productunitid)
                .toList()
                .first
            : null;
  }

  ProductCategory getCatValue() {
    return product.categoryid == null
        ? null
        : (_categories.length > 0)
            ? _categories
                .where((element) => element.id == product.categoryid)
                .toList()
                .first
            : null;
  }

  Container unitConversions() {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(0.0),
        child: MaterialButton(
            onPressed: product.id == null
                ? null
                : () {
                    setState(() {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      new UnitConversionManager(product)))
                          .then((value) => updatePrices(true));
                    });
                  },
            child: Text('Unit Conversions')));
  }

  Container productPrices() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(0.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialButton(
                      onPressed: product.id == null
                          ? null
                          : () {
                              setState(() {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                new ProductPriceManager(product,
                                                    iscost: true)))
                                    .then((value) => updatePrices(true));
                              });
                            },
                      child: Text('Cost Price: $_costPrice')),
                  MaterialButton(
                      onPressed: product.id == null
                          ? null
                          : () {
                              setState(() {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                new ProductPriceManager(product,
                                                    iscost: false)))
                                    .then((value) => updatePrices(false));
                              });
                            },
                      child: Text('Sell Price: $_sellPrice'))
                ]),
          ]),
    );
  }

  void _save(Product product) async {
    if (_isNew) {
      await DBHelper.insert(Product.table, product);
    } else {
      await DBHelper.update(Product.table, product);
    }
  }
}
