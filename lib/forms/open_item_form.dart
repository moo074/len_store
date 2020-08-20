import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart' as p;
import 'package:len_store/models/open_item.dart';
import 'package:len_store/models/product.dart';
import 'package:len_store/models/product_category.dart';
import 'package:len_store/models/product_price.dart';

import 'package:len_store/models/product_unit.dart';
import 'package:len_store/models/storage.dart';
import 'package:len_store/tools/db_helper.dart';

class OpeningItemForm extends StatefulWidget {
  final OpeningItem openingItem;
  final bool isNew;

  OpeningItemForm(this.isNew, {this.openingItem});

  @override
  OrderFormState createState() {
    print('createState');
    return OrderFormState();
  }
}

class OrderFormState extends State<OpeningItemForm> {
  final _formKey = GlobalKey<FormState>();
  OpeningItem _openingitem;
  bool _isNew = true;
  DateTime _date = DateTime.now();
  List<ProductUnit> _unitNames = [];
  List<Product> _productNames = [];
  List<ProductCategory> _categories = [];
  TextEditingController _count = new TextEditingController();
  double _price = 0.0;
  double _totalAmount = 0.0;
  int _prevValue;

  void setResources() async {
    print('setResources');
    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(ProductUnit.table);

    List<Map<String, dynamic>> _resultProducts =
        await DBHelper.query(Product.table);

    List<Map<String, dynamic>> _resultCat =
        await DBHelper.query(ProductCategory.table);

    setState(() {
      _unitNames =
          _resultUnits.map((item) => ProductUnit.fromMap(item)).toList();

      _productNames =
          _resultProducts.map((item) => Product.fromMap(item)).toList();

      _categories =
          _resultCat.map((item) => ProductCategory.fromMap(item)).toList();

      print('_unitNames: ' + _unitNames.length.toString());
      print('_productNames: ' + _productNames.length.toString());
      print('_categories: ' + _categories.length.toString());
    });
  }

  @override
  void initState() {
    _openingitem = widget.openingItem;
    _isNew = widget.isNew;
    if (_isNew) {
      _openingitem = new OpeningItem();
    } else {
      _prevValue = widget.openingItem.count;
    }
    setResources();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Opening Balance Item'),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                formDetails(context),
              ])),
    );
  }

  Form formDetails(BuildContext context) {
    print('formDetails ');

    if (!_isNew) {
      print(_openingitem.toString());
      _date = DateTime.parse(_openingitem.date);
      _price = _openingitem.price;
      _count.text = _openingitem.count.toString();
      _totalAmount = _openingitem.price * _openingitem.count;
    }

    return Form(
      key: _formKey,
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          date(),
          categoryInfo(),
          productInfo(),
          unitInfo(),
          productUnitPrice(),
          countText(),
          totalAmount(),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: RaisedButton(
                    onPressed: () {
                      _openingitem.date = _date.toString();
                      _save(_openingitem);
                      //Navigator.pop(context);
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
      )),
    );
  }

  TextFormField countText() => TextFormField(
        textAlign: TextAlign.center,
        controller: _count,
        decoration: InputDecoration(labelText: 'Count', hintText: '12, 6, 1'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter amount';
          } else if (value == '0') {
            return 'Please enter valid number';
          }
          return null;
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            _openingitem.count = int.tryParse(value);
            updateTotalAmount();
            print('onChanged countText');
            setState(() {});
          }
        },
      );

  ProductUnit getUnitValue() {
    return _openingitem.productunitid == null
        ? null
        : (_unitNames.length > 0)
            ? _unitNames
                .where((element) => element.id == _openingitem.productunitid)
                .toList()
                .first
            : null;
  }

  Product geProductValue() {
    return _openingitem.productid == null
        ? null
        : (_productNames.length > 0)
            ? _productNames
                .where((element) => element.id == _openingitem.productid)
                .toList()
                .first
            : null;
  }

  ProductCategory getCategoryValue() {
    return _openingitem.categoryid == null
        ? null
        : (_categories.length > 0)
            ? _categories
                .where((element) => element.id == _openingitem.categoryid)
                .toList()
                .first
            : null;
  }

  Container categoryInfo() {
    return Container(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Category'),
            SizedBox(width: 10.0),
            DropdownButton<ProductCategory>(
              value: getCategoryValue(),
              onChanged: (ProductCategory value) {
                _openingitem.categoryid = value.id;
                updateProductList();
              },
              items: _categories != null
                  ? _categories.map((ProductCategory unit) {
                      return DropdownMenuItem<ProductCategory>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  Container productInfo() {
    return Container(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Product'),
            SizedBox(width: 10.0),
            DropdownButton<Product>(
              value: geProductValue(),
              onChanged: (Product value) {
                print('selected product' + value.id.toString());
                _openingitem.productid = value.id;
                getPrice();
              },
              items: _productNames != null
                  ? _productNames.map((Product unit) {
                      return DropdownMenuItem<Product>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  Container unitInfo() {
    return Container(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Unit'),
            SizedBox(width: 10.0),
            DropdownButton<ProductUnit>(
              value: getUnitValue(),
              onChanged: (ProductUnit value) {
                _openingitem.productunitid = value.id;
                getPrice();
              },
              items: _unitNames != null
                  ? _unitNames.map((ProductUnit unit) {
                      return DropdownMenuItem<ProductUnit>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  Row totalAmount() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Total Amount '),
          Text(_totalAmount.toString()),
        ]);
  }

  updateTotalAmount() {
    print('updateTotalAmount');
    if (_openingitem.count == null || _openingitem.price == null) {
      print('count ' + _openingitem.count.toString());
      print('price ' + _openingitem.price.toString());
      _totalAmount = 0.00;
    } else {
      _totalAmount = _openingitem.count * _openingitem.price;
    }
  }

  Row date() {
    return Row(
        //date
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Date'),
          SizedBox(width: 10.0),
          FlatButton(
            child: Text(
                p.DateFormat('yyyy-MM-dd HH:mm:ss').format(_date).toString()),
            onPressed: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2020, 1, 1), onChanged: (date) {
                _openingitem.date = date.toString();
              }, onConfirm: (date) {
                print('confirm $date');
                _date = date;
                _openingitem.date = date.toString();
              },
                  currentTime: _isNew
                      ? DateTime.now()
                      : DateTime.parse(_openingitem.date),
                  locale: LocaleType.en);
            },
          )
        ]);
  }

  Row productUnitPrice() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Unit Price '),
          Text(p.NumberFormat('0.00').format(_price).toString()),
        ]);
  }

  getPrice() async {
    if (_openingitem.productid == null || _openingitem.productunitid == null) {
      _price = 0.0;
    } else {
      ProductPrice price = await ProductPrice.getProductUnitPrice(
          true, _openingitem.productid, _openingitem.productunitid);
      if (price.id == null) {
        _price = 0.00;
      } else {
        _openingitem.price = price.amount;
        _openingitem.costpriceid = price.id;
        _price = price.amount;
      }
    }
    setState(() {});
  }

  updateProductList() async {
    Product product = new Product();
    product.where = 'categoryid = ?';
    product.whereArgs = [_openingitem.categoryid];

    List<Map<String, dynamic>> _resultProducts =
        await DBHelper.getRecord(Product.table, product);
    setState(() {
      _productNames =
          _resultProducts.map((item) => Product.fromMap(item)).toList();
    });
  }

  void _save(OpeningItem _openingitem) async {
    print('_save');
    print(_openingitem.toString());
    if (_isNew) {
      await DBHelper.insert(OpeningItem.table, _openingitem);
    } else {
      await DBHelper.update(OpeningItem.table, _openingitem);
    }

    //update storage
    Storage.updateBalance(
        isUpdate: !_isNew,
        isDeduct: false, //depends if Opening, order, sales or loss
        categoryid: _openingitem.categoryid,
        productid: _openingitem.productid,
        productunitid: _openingitem.productunitid,
        costpriceid: _openingitem.costpriceid,
        price: _openingitem.price,
        prevValue: _prevValue,
        curValue: _openingitem.count);

    //close form
    Navigator.pop(context);
  }
}
