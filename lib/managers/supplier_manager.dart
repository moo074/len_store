import 'package:flutter/material.dart';

import 'package:len_store/forms/supplier_form.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/people.dart';

class SuppliersManager extends StatefulWidget {
  final String title;
  SuppliersManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return SuppliersManagerState();
  }
}

class SuppliersManagerState extends State<SuppliersManager> {
  List<People> _suppliers = [];

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
            MaterialPageRoute(builder: (context) => SupplierForm(true)),
          ).then((value) => refresh());
        },
      ),
    );
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DBHelper.query(People.table);

    setState(() {
      _suppliers = _results.map((item) => People.fromMap(item)).toList();
      if(_suppliers.length > 0){
        _suppliers = _suppliers.where((element) => element.iscustomer == false).toList();
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
            Text('Suppliers'),
            ListView.builder(
                shrinkWrap: true,
                itemCount: _suppliers.length,
                itemBuilder: (BuildContext context, int position) {
                  return Card(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ListTile(
                          title: Text(_suppliers[position].name),
                          subtitle: Text(_suppliers[position].address),
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new SupplierForm(false,
                                        supplier: _suppliers[position])),
                              ).then((value) => refresh());
                            });
                          }));
                })
          ]),
    );
  }
}
