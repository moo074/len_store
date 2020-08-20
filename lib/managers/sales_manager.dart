import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:len_store/forms/order_form.dart';

import 'package:len_store/models/people.dart';
import 'package:len_store/models/store_model.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/order_info.dart';

class SalesManager extends StatefulWidget {
  SalesManager() {
    print('constructor');
  }

  @override
  State<StatefulWidget> createState() {
    return SalesManagerState();
  }
}

class SalesManagerState extends State<SalesManager> {
  List<OrderInfo> _orders = [];
  bool _isOrder = false;
  List<StoreModel> _infonames = [];

  @override
  void initState() {
    print('initState');
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text(_isOrder ? 'Orders' : 'Sales')),
      body: _bodyContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderForm(
                      true,
                      isOrder: _isOrder,
                    )),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    print('refresh');
    List<Map<String, dynamic>> _resultUnits =
        await DBHelper.query(People.table);

    List<Map<String, dynamic>> _results = await DBHelper.query(OrderInfo.table);

    setState(() {
      _orders = _results.map((item) => OrderInfo.fromMap(item)).toList();
      print(_isOrder);
      if(_orders.length > 0){
        _orders = _orders.where((element) => element.isorder == _isOrder).toList();
      }      
      _infonames = _resultUnits.map((item) => People.fromMap(item)).toList();
    });
  }

  Widget _bodyContent() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_isOrder ? 'Orders' : 'Sales'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _orders.length,
                itemBuilder: (BuildContext context, int position) {
                  print(_orders[position].toString());
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Row(
                            children: [
                              Text(unitName(_orders[position].peopleid)),
                              Text(_orders[position].totalamount.toString())
                            ],
                          ),
                          subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                              .format(DateTime.parse(_orders[position].date))
                              .toString()),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderForm(false,
                                        isOrder: _isOrder,
                                        order: _orders[position])),
                              ).then((value) => refresh());
                            });
                          }));
                })
          ]),
    );
  }

  String unitName(int id) =>
      _infonames.where((element) => element.id == id).first.name;
}
