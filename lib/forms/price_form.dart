import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart' as p;

import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/product_price.dart';

class ProductPriceForm extends StatefulWidget {
  final ProductPrice price;
  final bool isNew;
  final bool isCost;
  final int productid;

  ProductPriceForm(this.isNew, {this.price, this.isCost, this.productid});

  @override
  ProductPriceFormState createState() {
    print('createState');
    return ProductPriceFormState();
  }
}

class ProductPriceFormState extends State<ProductPriceForm> {
  final _formKey = GlobalKey<FormState>();
  ProductPrice price;
  bool _isNew = true;
  bool _isCost = true;
  DateTime _date = DateTime.now();
  List<ProductUnit> _units = [];

  void setResources() async {
    print('setResources');
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ProductUnit.table);
    setState(() {
      if (_results.length < 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Set Units first."),
              );
            });
      } else {
        _units = _results.map((item) => ProductUnit.fromMap(item)).toList();
      }
    });
  }

  @override
  void initState() {
    price = widget.price;
    _isNew = widget.isNew;
    _isCost = widget.isCost;

    if (_isNew) {
      price = new ProductPrice(iscost: _isCost);
      price.productid = widget.productid;
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
        title: Text(formTitle()),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          //decoration: Decoration(style Border.all(color: Colors.black)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                priceDetails(context),
              ])),
    );
  }

  String formTitle() {
    if (_isNew) {
      return _isCost ? 'New Cost Price' : "New Selling Price";
    } else {
      return _isCost ? 'Update Cost Price' : "Update Selling Price";
    }
  }

  Form priceDetails(BuildContext context) {
    print('priceDetails');

    TextEditingController amount = new TextEditingController();
    if (_isNew && price.productunitid == null && _units.length > 0) {
      price.productunitid = _units.first.id;
    }
    if (!_isNew) {
      _date = DateTime.parse(price.date);
      amount.text = price.amount.toString();
    }

    return Form(
      key: _formKey,
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: TextFormField(
              controller: amount,
              decoration:
                  InputDecoration(labelText: 'Amount', hintText: '19.50, 5.89'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter amount';
                }
                return null;
              },
              onChanged: (value) {
                price.amount = double.tryParse(value);
              },
            ),
          ),
          unitInfo(),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Date'),
                SizedBox(width: 10.0),
                FlatButton(
                  child: Text(p.DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(_date)
                      .toString()),
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2020, 1, 1), onChanged: (date) {
                      price.date = date.toString();
                    }, onConfirm: (date) {
                      print('confirm $date');
                      _date = date;
                      price.date = date.toString();
                    },
                        currentTime: _isNew
                            ? DateTime.now()
                            : DateTime.parse(price.date),
                        locale: LocaleType.en);
                  },
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
                        price.date = _date.toString();
                        _save(price);
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
      )),
    );
  }

  ProductUnit getUnitValue() {
    return (_units.length > 0)
        ? _isNew && price.productunitid == null
            ? _units.first
            : _units
                .where((element) => element.id == price.productunitid)
                .toList()
                .first
        : null;
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
                price.productunitid = value.id;
              },
              items: _units != null
                  ? _units.map((ProductUnit unit) {
                      return DropdownMenuItem<ProductUnit>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  void _save(ProductPrice price) async {
    print('_save');

    if (_isNew) {
      await DBHelper.insert(ProductPrice.table, price);
    } else {
      await DBHelper.update(ProductPrice.table, price);
    }
  }
}
