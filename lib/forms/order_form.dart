import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart' as p;
import 'package:len_store/forms/order_item_form.dart';
import 'package:len_store/models/account.dart';
import 'package:len_store/models/storage.dart';
import 'package:len_store/models/people.dart';
import 'package:len_store/models/order_item.dart';
import 'package:len_store/models/product_unit.dart';
import 'package:len_store/models/product.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/order_info.dart';

class OrderForm extends StatefulWidget {
  final OrderInfo order;
  final bool isNew;
  final bool isOrder;
  final int id;

  OrderForm(this.isNew, {this.order, this.isOrder, this.id});

  @override
  OrderFormState createState() {
    print('createState');
    return OrderFormState();
  }
}

class OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  OrderInfo _order;
  bool _isNew = true;
  bool _isOrder = true;
  bool _isPaid = true;
  bool _isComplete = false;
  DateTime _date = DateTime.now();
  List<People> _infonames = [];
  List<Account> _accounts = [];
  List<OrderItem> _orderItems = [];
  List<Product> _products = [];
  List<ProductUnit> _units = [];
  double _totalAmount = 0.0;

  void setResources() async {
    print('setResources');
    List<Map<String, dynamic>> _resultInfo = await DBHelper.query(People.table);

    List<Map<String, dynamic>> _resultAccounts =
        await DBHelper.query(Account.table);

    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(ProductUnit.table);

    List<Map<String, dynamic>> _resultProducts =
        await DBHelper.query(Product.table);

    setState(() {
      _infonames = _resultInfo.map((item) => People.fromMap(item)).toList();
      if (_infonames.length > 0) {
        _infonames = _infonames
            .where(
                (e) => e.iscustomer == !_isOrder) //get only customers if order
            .toList();
      }

      _accounts = _resultAccounts.map((item) => Account.fromMap(item)).toList();

      _units = _resultUnits.map((item) => ProductUnit.fromMap(item)).toList();

      _products = _resultProducts.map((item) => Product.fromMap(item)).toList();
    });
  }

  @override
  void initState() {
    _order = widget.order;
    _isNew = widget.isNew;
    _isOrder = widget.isOrder;

    setResources();

    if (_isNew) {
      _order = new OrderInfo(isorder: _isOrder);
      _order.ispaid = true;
      _order.iscomplete = false;
    } else {
      _isPaid = _order.ispaid;
      _isComplete = _order.iscomplete;
      getOrderItems();
    }
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
                formDetails(context),
                orderItems(),
              ])),
      floatingActionButton: _isNew
          ? null
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OrderItemForm(true, order: _order)),
                  ).then((value) => getOrderItems());
                });
              },
            ),
    );
  }

  String formTitle() {
    if (_isNew) {
      return _isOrder ? 'New Order' : "New Sales";
    } else {
      return _isOrder ? 'Update Order' : "Update Sales";
    }
  }

  Form formDetails(BuildContext context) {
    print('formDetails ' + OrderInfo.table);

    if (_isNew && _order.peopleid == null && _infonames.length > 0) {
      print('sets peopleid');
      _order.peopleid = _infonames.first.id;
    }

    if (_isNew && _order.accountid == null && _accounts.length > 0) {
      print('sets accountid');
      _order.accountid = _accounts.first.id;
    }

    if (!_isNew) {
      _date = DateTime.parse(_order.date);
    }

    return Form(
      key: _formKey,
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          orderInfo(_order.peopleid),
          date(), // Supplier or Customer
          totalAmount(),
          isPaid(),
          accountInfo(),
          formButtons(),
        ],
      )),
    );
  }

  People getInfoValue() {
    return (_infonames.length > 0)
        ? _isNew && _order.peopleid == null
            ? _infonames.first
            : _infonames
                .where((element) => element.id == _order.peopleid)
                .toList()
                .first
        : null;
  }

  Container orderInfo(int peopleid) {
    return Container(
      child: Row(
          // Supplier or Customer
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(_isOrder ? 'Suppliers' : 'Customers'),
            SizedBox(width: 10.0),
            DropdownButton<People>(
              value: getInfoValue(), //_units[_units.indexOf(_order.unit)],
              onChanged: (People value) {
                setState(() {
                  _order.peopleid = value.id;
                  print(value.name);
                });
              },
              items: _infonames != null
                  ? _infonames.map((People unit) {
                      return DropdownMenuItem<People>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  Account getAccountValue() {
    return (_accounts.length > 0)
        ? _isNew && _order.accountid == null
            ? _accounts.first
            : _accounts
                .where((element) => element.id == _order.accountid)
                .toList()
                .first
        : null;
  }

  Container accountInfo() {
    return Container(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Accounts'),
            SizedBox(width: 10.0),
            DropdownButton<Account>(
              value: getAccountValue(),
              onChanged: (Account value) {
                setState(() {
                  _order.accountid = value.id;
                });
              },
              items: _accounts != null
                  ? _accounts.map((Account unit) {
                      return DropdownMenuItem<Account>(
                          value: unit, child: Text(unit.name));
                    }).toList()
                  : null,
            )
          ]),
    );
  }

  Row totalAmount() {
    if (_order.totalamount == null) _order.totalamount = 0.0;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Total Amount '),
          Text(p.NumberFormat('0.00').format(_order.totalamount).toString()),
        ]);
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
                _order.date = date.toString();
              }, onConfirm: (date) {
                print('confirm $date');
                _date = date;
                _order.date = date.toString();
              },
                  currentTime:
                      _isNew ? DateTime.now() : DateTime.parse(_order.date),
                  locale: LocaleType.en);
            },
          )
        ]);
  }

  Row isPaid() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Checkbox(
            value: _isPaid,
            onChanged: (value) {
              setState(() {
                _isPaid = value;
                _order.ispaid = value;
              });
            },
          ),
          Text('is Paid'),
          Checkbox(
            value: _isComplete,
            onChanged: (value) {
              setState(() {});
            },
          ),
          Text('is Complete')
        ]);
  }

  Row formButtons() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: RaisedButton(
              onPressed: _isComplete
                  ? null
                  : () {
                      _order.ispaid = _isPaid;
                      _order.date = _date.toString();
                      _order.iscomplete = false;
                      _save();
                      _isNew = false;
                      setState(() {});
                    },
              child: Text('Save'),
            ),
          ),
          SizedBox(width: 10.0),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: RaisedButton(
              onPressed: _isComplete
                  ? null
                  : () {
                      _complete();
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
              child: Text('Complete'),
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
        ]);
  }

  void _save() async {
    print('_save');
    print(_order.toString());
    _order.totalamount = _totalAmount;

    if (_isNew) {
      await DBHelper.insert(OrderInfo.table, _order);
      _getOrderId();
    } else {
      await DBHelper.update(OrderInfo.table, _order);
    }
  }

  _getOrderId() async {
    _order.where = 'date = ?';
    _order.whereArgs = [_order.date];
    List<Map<String, dynamic>> resultInfo =
        await DBHelper.getRecord(OrderInfo.table, _order);
    if (resultInfo.length > 0)
      _order = resultInfo.map((e) => OrderInfo.fromMap(e)).toList().first;
    _order.where = 'orderid = ?'; //re set original where value
  }

  void _complete() async {
    print('_complete');
    print(_order.toString());

    //update storage
    for (var i = 0; i < _orderItems.length; i++) {
      Storage.updateBalance(
          isUpdate: false,
          isDeduct: !_isOrder, //depends if Opening, order, sales or loss
          categoryid: _orderItems[i].categoryid,
          productid: _orderItems[i].productid,
          productunitid: _orderItems[i].productunitid,
          costpriceid: _orderItems[i].costpriceid,
          price: _orderItems[i].price,
          curValue: _orderItems[i].count);
    }

    //update account
    Account.updateBalance(
      accountid: _order.accountid,
      isNew: true, // you only complete once so this is always true
      curValue: _order.totalamount,
      curType: _isOrder ? 'Order' : 'Sales',
    );

    //then update transaction to complete
    _order.iscomplete = true;
    _save();
  }

  String unitName(int id) => _units.length == 0
      ? ''
      : _units.where((element) => element.id == id).first.name;

  String prodName(int id) => _products.length == 0
      ? ''
      : _products.where((element) => element.id == id).first.name;

  getOrderItems() async {
    OrderItem item = new OrderItem(isorder: _isOrder);
    item.where = 'orderid = ?';
    item.whereArgs = [_order.id];
    List<Map<String, dynamic>> _resultItems =
        await DBHelper.getRecord(item.table, item);
    setState(() {
      print('getOrderItems');
      _orderItems =
          _resultItems.map((item) => OrderItem.fromMap(item)).toList();
      updateTotalAmount();
      print(_orderItems.length.toString());
    });
  }

  updateTotalAmount() {
    print('updateTotalAmount');
    _totalAmount = 0;
    for (var item in _orderItems) {
      _totalAmount = _totalAmount + item.totalamount;
    }
    _order.totalamount = _totalAmount;
  }

  ListView orderItems() {
    print('orderItems');
    print(_products.length.toString());
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _orderItems.length,
        itemBuilder: (BuildContext context, int i) {
          return Card(
              margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(prodName(_orderItems[i].productid)),
                      Text(_orderItems[i].count.toString()),
                      Text(unitName(_orderItems[i].productunitid)),
                      SizedBox(
                        width: 20,
                      ),
                      Text((p.NumberFormat('0.00')
                          .format(_orderItems[i].totalamount)
                          .toString())),
                      SizedBox(
                        width: 20,
                      ),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: _isComplete
                              ? null
                              : () {
                                  _deleteItem(_orderItems[i]);
                                  getOrderItems();
                                })
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderItemForm(false,
                                order: _order, orderItem: _orderItems[i])),
                      ).then((value) => getOrderItems());
                    });
                  }));
        });
  }

  _deleteItem(OrderItem item) async {
    print('_deleteItem');
    print(item.toString());
    await DBHelper.delete(item.table, item);
  }
}
