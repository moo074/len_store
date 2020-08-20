import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:len_store/forms/payment_form.dart';
import 'package:len_store/models/payment_info.dart';

import 'package:len_store/models/people.dart';
import 'package:len_store/tools/db_helper.dart';

class PaymentsManager extends StatefulWidget {
  PaymentsManager() {
    print('constructor');
  }

  @override
  State<StatefulWidget> createState() {
    return PaymentsManagerState();
  }
}

class PaymentsManagerState extends State<PaymentsManager> {
  List<PaymentInfo> _paymentinfo = [];
  List<People> _customers = [];

  @override
  void initState() {
    print('initState');
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
            MaterialPageRoute(builder: (context) => PaymentForm(true)),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    print('refresh');
    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(People.table);

    List<Map<String, dynamic>> _results =
        await DBHelper.query(PaymentInfo.table);

    setState(() {
      _paymentinfo = _results.map((item) => PaymentInfo.fromMap(item)).toList();

      _customers = _resultUnits.map((item) => People.fromMap(item)).toList();
    });
  }

  Widget _bodyContent() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Payments'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _paymentinfo.length,
                itemBuilder: (BuildContext context, int i) {
                  print(_paymentinfo[i].toString());
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Row(
                            children: [
                              Text(customerName(_paymentinfo[i].customerid)),
                              Text(NumberFormat('0.00')
                                  .format(_paymentinfo[i].amount)
                                  .toString())
                            ],
                          ),
                          subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                              .format(_paymentinfo[i].date)
                              .toString()),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PaymentForm(false,
                                        payment: _paymentinfo[i])),
                              ).then((value) => refresh());
                            });
                          }));
                })
          ]),
    );
  }

  String customerName(int id) =>
      _customers.where((element) => element.id == id).first.name;
}
