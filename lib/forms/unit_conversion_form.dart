import 'package:flutter/material.dart';

import 'package:len_store/models/prod_unit_conversion.dart';
import 'package:len_store/models/product_unit.dart';
import 'package:len_store/tools/db_helper.dart';

class UnitConversionForm extends StatefulWidget {
  final ProductUnitConversion conversion;
  final int productid;
  final bool isNew;

  UnitConversionForm(this.isNew, {this.conversion, this.productid});

  @override
  ProductFormState createState() {
    return ProductFormState();
  }
}

class ProductFormState extends State<UnitConversionForm> {
  final _formKey = GlobalKey<FormState>();
  ProductUnitConversion unitConversion;
  bool _isNew = true;
  List<ProductUnit> _units = [];
  TextEditingController _framount = new TextEditingController();
  TextEditingController _toamount = new TextEditingController();

  void setResources() async {
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
    _isNew = widget.isNew;
    if (_isNew) {
      unitConversion = new ProductUnitConversion();
      unitConversion.productid = widget.productid;
    } else {
      unitConversion = widget.conversion;
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
        title: Text(_isNew ? 'New Unit Conversion' : "Update Unit Conversion"),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          //decoration: Decoration(style Border.all(color: Colors.black)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                unitDetails(context),
              ])),
    );
  }

  Form unitDetails(BuildContext context) {
    print('unitDetails');
    print(unitConversion.toString());
    if (!_isNew) {
      _framount.text = unitConversion.framount.toString();
      _toamount.text = unitConversion.toamount.toString();
    }
    if (_isNew && unitConversion.frproductunitid == null) {
      if (_units.length > 0) {
        unitConversion.frproductunitid = _units.first.id;
        unitConversion.toproductunitid = _units.first.id;
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          getUnitDropdown('From Unit', true),
          getTextField('From Amount', true, _framount),
          getUnitDropdown('To Unit', false),
          getTextField('To Amount', false, _toamount),
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
                        if (unitConversion.toproductunitid !=
                            unitConversion.frproductunitid) {
                          _save(unitConversion);
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            _validationDialog(context,
                                'Selected From and To Units are the same');
                          });
                        }
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

  TextFormField getTextField(
          String label, bool isFrom, TextEditingController amt) =>
      TextFormField(
        textAlign: TextAlign.center,
        controller: amt,
        decoration: InputDecoration(labelText: label, hintText: '12, 6, 1'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter amount';
          } else if (value == '0') {
            return 'Please enter valid number';
          }
          return null;
        },
        onChanged: (value) {
          if (isFrom) {
            unitConversion.framount = int.tryParse(value);
          } else {
            unitConversion.toamount = int.tryParse(value);
          }
        },
      );

  Row getUnitDropdown(String lbl, bool isFrom) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(lbl),
            SizedBox(width: 10.0),
            DropdownButton<ProductUnit>(
              value: getUnitValue(isFrom
                  ? unitConversion.frproductunitid
                  : unitConversion
                      .toproductunitid), //_units[_units.indexOf(product.unit)],
              onChanged: (ProductUnit value) {
                setState(() {
                  if (isFrom) {
                    unitConversion.frproductunitid = value.id;
                  } else {
                    unitConversion.toproductunitid = value.id;
                  }
                });
              },
              items: _units != null
                  ? _units.map((ProductUnit unit) {
                      return DropdownMenuItem<ProductUnit>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]);

  ProductUnit getUnitValue(int productunitid) {
    return (_units.length < 1)
        ? null
        : _isNew && productunitid == null
            ? _units.first
            : _units
                .where((element) => element.id == productunitid)
                .toList()
                .first;
  }

  void _validationDialog(BuildContext context, String errmessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(errmessage),
          actions: <Widget>[
            FlatButton(
                child: Text('Ok'), onPressed: () => Navigator.pop(context)),
          ],
        );
      },
    );
  }

  void _save(ProductUnitConversion unitconversion) async {
    if (_isNew) {
      await DBHelper.insert(ProductUnitConversion.table, unitconversion);
    } else {
      await DBHelper.update(ProductUnitConversion.table, unitconversion);
    }
  }
}
