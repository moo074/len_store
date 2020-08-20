import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart' as p;
import 'package:len_store/models/account.dart';
import 'package:len_store/models/payment_info.dart';
import 'package:len_store/models/payment_item.dart';
import 'package:len_store/models/people.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/order_info.dart';

class PaymentForm extends StatefulWidget {
  final PaymentInfo payment;
  final bool isNew;

  PaymentForm(this.isNew, {this.payment});

  @override
  OrderFormState createState() {
    print('createState');
    return OrderFormState();
  }
}

class OrderFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  PaymentInfo _paymentInfo;
  bool _isNew = true;
  bool _isComplete = false;
  DateTime _date = DateTime.now();
  List<People> _customers = [];
  List<Account> _accounts = [];
  List<OrderInfo> _orders = [];
  List<PaymentItem> _paymentItems = [];
  double _totalAmount = 0.0;

  void setResources() async {
    print('setResources');
    List<Map<String, dynamic>> _resultAccounts =
        await DBHelper.query(Account.table);

    List<Map<String, dynamic>> _resultCustomers =
        await DBHelper.query(People.table);

    setState(() {
      _customers =
          _resultCustomers.map((item) => People.fromMap(item)).toList();

      _accounts = _resultAccounts.map((item) => Account.fromMap(item)).toList();
    });
  }

  @override
  void initState() {
    _isNew = widget.isNew;
    setResources();

    if (_isNew) {
      _paymentInfo = new PaymentInfo();
      _paymentInfo.iscomplete = false;
      _paymentInfo.iscomplete = _isComplete;
    } else {
      _isComplete = _paymentInfo.iscomplete;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Payment Info'),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          //decoration: Decoration(style Border.all(color: Colors.black)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                formDetails(context),
                getList(),
              ])),
    );
  }

  Form formDetails(BuildContext context) {
    print('formDetails');

    if (!_isNew) {
      _date = _paymentInfo.date;
    }

    return Form(
      key: _formKey,
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          customer(),
          date(), // Supplier or Customer
          totalAmount(),
          isCompelete(),
          accountInfo(),
          formButtons(),
        ],
      )),
    );
  }

  People getCustomerValue() {
    return (_customers.length > 0)
        ? _isNew && _paymentInfo.customerid == null
            ? _customers.first
            : _customers
                .where((element) => element.id == _paymentInfo.customerid)
                .toList()
                .first
        : null;
  }

  Container customer() {
    return Container(
      child: Row(
          // Supplier or Customer
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Customer'),
            SizedBox(width: 10.0),
            DropdownButton<People>(
              value:
                  getCustomerValue(), //_units[_units.indexOf(_paymentinfo.unit)],
              onChanged: (People value) {
                setState(() {
                  _paymentInfo.customerid = value.id;
                  print(value.name);
                });
              },
              items: _customers != null
                  ? _customers.map((People unit) {
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
        ? _isNew && _paymentInfo.accountid == null
            ? _accounts.first
            : _accounts
                .where((element) => element.id == _paymentInfo.accountid)
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
                  _paymentInfo.accountid = value.id;
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
    if (_paymentInfo.amount == null) _paymentInfo.amount = 0.0;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Total Amount '),
          Text(p.NumberFormat('0.00').format(_paymentInfo.amount).toString()),
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
                _paymentInfo.date = date;
              }, onConfirm: (date) {
                print('confirm $date');
                _date = date;
                _paymentInfo.date = date;
              },
                  currentTime: _isNew ? DateTime.now() : _paymentInfo.date,
                  locale: LocaleType.en);
            },
          )
        ]);
  }

  Row isCompelete() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
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
                      _paymentInfo.date = _date;
                      _paymentInfo.iscomplete = false;
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
    print(_paymentInfo.toString());
    _paymentInfo.amount = _totalAmount;

    if (_isNew) {
      await DBHelper.insert(OrderInfo.table, _paymentInfo);
      _getPaymentId();
    } else {
      await DBHelper.update(OrderInfo.table, _paymentInfo);
    }
  }

  _getPaymentId() async {
    List<Map<String, dynamic>> resultInfo = await DBHelper.getRecords(
        PaymentInfo.table, 'date = ?', [_paymentInfo.date]);
    if (resultInfo.length > 0)
      _paymentInfo =
          resultInfo.map((e) => PaymentInfo.fromMap(e)).toList().first;
  }

  void _complete() async {
    print('_complete');
    print(_paymentInfo.toString());

    //update account
    Account.updateBalance(
      accountid: _paymentInfo.accountid,
      isNew: true, // you only complete once so this is always true
      curValue: _paymentInfo.amount,
      curType: 'Credit Payment',
    );

    //then update transaction to complete
    _paymentInfo.iscomplete = true;
    _save();
  }

  ListView getList() {
    if (_paymentInfo.iscomplete) {
      getPaymentItems();
      return paymentItems();
    } else {
      getUnpaidSales();
      return salesList();
    }
  }

  getUnpaidSales() async {
    List<Map<String, dynamic>> _resultItems = await DBHelper.getRecords(
        OrderInfo.table,
        'peopleid = ? AND ispaid = 0',
        [_paymentInfo.customerid]);
    setState(() {
      print('getOrderItems');
      _orders = _resultItems.map((item) => OrderInfo.fromMap(item)).toList();
      print(_orders.length.toString());
    });
  }

  getPaymentItems() async {
    List<Map<String, dynamic>> _resultPayItems = await DBHelper.getRecords(
        PaymentItem.table, 'paymentid = ?', [_paymentInfo.id]);
    setState(() {
      _paymentItems =
          _resultPayItems.map((item) => PaymentItem.fromMap(item)).toList();
    });
  }

  updateTotalAmount() {
    print('updateTotalAmount');
    _totalAmount = 0;
    for (var item in _orders) {
      if (item.ispaid) _totalAmount = _totalAmount + item.totalamount;
    }
    _paymentInfo.amount = _totalAmount;
  }

  ListView salesList() {
    print('salesList');
    print(_orders.length.toString());
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _orders.length,
        itemBuilder: (BuildContext context, int i) {
          return Card(
              margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Checkbox(
                      value: _orders[i].ispaid,
                      onChanged: (value) {
                        _orders[i].ispaid = value;
                        setState(() {
                          updateTotalAmount();
                        });
                      },
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Text(_orders[i].date.toString()),
                    SizedBox(
                      width: 50,
                    ),
                    Text((p.NumberFormat('0.00')
                        .format(_orders[i].totalamount)
                        .toString())),
                  ],
                ),
                onTap: () {},
              ));
        });
  }

  ListView paymentItems() {
    print('paymentItems');
    print(_paymentItems.length.toString());
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _paymentItems.length,
        itemBuilder: (BuildContext context, int i) {
          return Card(
              margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(_paymentItems[i].date.toString()),
                    SizedBox(
                      width: 50,
                    ),
                    Text((p.NumberFormat('0.00')
                        .format(_paymentItems[i].amount)
                        .toString())),
                  ],
                ),
                onTap: () {},
              ));
        });
  }
}
