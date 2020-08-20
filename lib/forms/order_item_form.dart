import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart' as p;
import 'package:len_store/models/order_info.dart';
import 'package:len_store/models/order_item.dart';
import 'package:len_store/models/product.dart';
import 'package:len_store/models/product_category.dart';
import 'package:len_store/models/product_price.dart';

import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';

class OrderItemForm extends StatefulWidget {
  final OrderItem orderItem;
  final OrderInfo order;
  final bool isNew;

  OrderItemForm(this.isNew, {this.order, this.orderItem});

  @override
  OrderFormState createState() {
    print('createState');
    return OrderFormState();
  }
}

class OrderFormState extends State<OrderItemForm> {
  final _formKey = GlobalKey<FormState>();
  OrderItem _orderitem;
  bool _isNew = true;
  bool _isOrder = true;
  DateTime _date = DateTime.now();
  List<ProductUnit> _unitNames = [];
  List<Product> _productNames = [];
  List<ProductCategory> _categories = [];
  TextEditingController _count = new TextEditingController();
  double _price = 0.0;
  double _totalAmount = 0.0;

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
    print('initState');
    _orderitem = widget.orderItem;

    _isNew = widget.isNew;
    if (_isNew) {
      _isOrder = widget.order.isorder;
      _orderitem = new OrderItem();
      _orderitem.orderid = widget.order.id;
      _orderitem.isorder = _isOrder;
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
        title: Text('Order Item'),
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
      print(_orderitem.toString());
      _date = DateTime.parse(_orderitem.date);
      _price = _orderitem.price;
      _count.text = _orderitem.count.toString();
      _totalAmount = _orderitem.price * _orderitem.count;
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
                    onPressed: widget.order.iscomplete
                        ? null
                        : () {
                            if (_formKey.currentState.validate()) {
                              _orderitem.date = _date.toString();
                              _orderitem.orderid = widget.order.id;
                              _save(_orderitem);
                            }
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
          } else if (value == '0' || int.tryParse(value) == null) {
            return 'Please enter valid number';
          }
          return null;
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            _orderitem.count = int.tryParse(value);
            updateTotalAmount();
            print('onChanged countText');
            setState(() {});
          }
        },
      );

  ProductUnit getUnitValue() {
    return _orderitem.productunitid == null
        ? null
        : (_unitNames.length > 0)
            ? _unitNames
                .where((element) => element.id == _orderitem.productunitid)
                .toList()
                .first
            : null;
  }

  Product geProductValue() {
    return _orderitem.productid == null
        ? null
        : (_productNames.length > 0)
            ? _productNames
                .where((element) => element.id == _orderitem.productid)
                .toList()
                .first
            : null;
  }

  ProductCategory getCategoryValue() {
    return _orderitem.categoryid == null
        ? null
        : (_categories.length > 0)
            ? _categories
                .where((element) => element.id == _orderitem.categoryid)
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
                _orderitem.categoryid = value.id;
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
                _orderitem.productid = value.id;
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
                _orderitem.productunitid = value.id;
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
          Text(p.NumberFormat('0.00').format(_totalAmount).toString()),
        ]);
  }

  updateTotalAmount() {
    print('updateTotalAmount');
    if (_orderitem.count == null || _orderitem.price == null) {
      print('count ' + _orderitem.count.toString());
      print('price ' + _orderitem.price.toString());
      _totalAmount = 0.00;
    } else {
      _totalAmount = _orderitem.count * _orderitem.price;
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
                _orderitem.date = date.toString();
              }, onConfirm: (date) {
                print('confirm $date');
                _date = date;
                _orderitem.date = date.toString();
              },
                  currentTime:
                      _isNew ? DateTime.now() : DateTime.parse(_orderitem.date),
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
    if (_orderitem.productid == null || _orderitem.productunitid == null) {
      _price = 0.0;
    } else {
      ProductPrice price = await ProductPrice.getProductUnitPrice(
          true, _orderitem.productid, _orderitem.productunitid);
      if (price.id == null) {
        _price = 0.00;
      } else {
        _orderitem.price = price.amount;
        _orderitem.costpriceid = price.id;
        _price = price.amount;
      }
    }
    setState(() {});
  }

  updateProductList() async {
    Product product = new Product();
    product.where = 'categoryid = ?';
    product.whereArgs = [_orderitem.categoryid];

    List<Map<String, dynamic>> _resultProducts =
        await DBHelper.getRecord(Product.table, product);
    setState(() {
      _productNames =
          _resultProducts.map((item) => Product.fromMap(item)).toList();
    });
  }

  void _save(OrderItem _orderitem) async {
    print('_save');
    _orderitem.orderid = widget.order.id;
    print(_orderitem.toString());
    if (_isNew) {
      await DBHelper.insert(OrderItem(isorder: _isOrder).table, _orderitem);
    } else {
      await DBHelper.update(OrderItem(isorder: _isOrder).table, _orderitem);
    }

    //close form
    Navigator.pop(context);
  }
}
