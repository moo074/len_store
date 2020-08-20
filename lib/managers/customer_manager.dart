import 'package:flutter/material.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/People.dart';
import 'package:len_store/forms/customer_form.dart';

class CustomersManager extends StatefulWidget {
  final String title;
  CustomersManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return CustomersManagerState();
  }
}

class CustomersManagerState extends State<CustomersManager> {
  List<People> _customers = [];

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
            MaterialPageRoute(builder: (context) => CustomerForm(true)),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DBHelper.query(People.table);

    setState(() {
      _customers = _results.map((item) => People.fromMap(item)).toList();
      
      if(_customers.length > 0){
        _customers = _customers.where((element) => element.iscustomer == true).toList();
        print('filtered');
      }
    });
  }

  Widget _bodyContent() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Customers'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _customers.length,
                itemBuilder: (BuildContext context, int position) {
                  print(_customers[position].toString());
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Text(_customers[position].name),
                          subtitle: Text(_customers[position].address),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new CustomerForm(false,
                                        customer: _customers[position])),
                              ).then((value) => refresh());
                            });
                          }));
                })
          ]),
    );
  }
}
