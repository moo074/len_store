import 'package:flutter/material.dart';


import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/people.dart';

class SupplierForm extends StatefulWidget {
  final People supplier;
  final bool isNew;

  SupplierForm(this.isNew, {this.supplier});

  @override
  SupplierFormState createState() {
    return SupplierFormState();
  }
}

class SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  People supplier;
  bool _isNew = true;

  @override
  void initState() {
    supplier = widget.supplier;
    _isNew = widget.isNew;
    if (_isNew) supplier = new People();    
    supplier.iscustomer = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_isNew);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New Supplier' : "Update Supplier"),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          //decoration: Decoration(style Border.all(color: Colors.black)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [productDetails(context), supplierRecords()])),
    );
  }

  Form productDetails(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: TextEditingController(text: supplier.name),
            decoration: InputDecoration(
                labelText: 'Name', hintText: 'Jane, Sidney'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
            onChanged: (value) {
              supplier.name = value.toString();
            },
          ),
          TextFormField(
            controller: TextEditingController(text: supplier.address),
            decoration: InputDecoration(
                labelText: 'Address', hintText: 'Narra'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
            onChanged: (value) {
              supplier.address = value.toString();
            },
          ),
          TextFormField(
            controller: TextEditingController(text: supplier.contact),
            decoration: InputDecoration(
                labelText: 'Contact Info', hintText: 'e.g. 09124123412, supplier@gmail.com'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter contact';
              }
              return null;
            },
            onChanged: (value) {
              supplier.contact = value.toString();
            },
          ),
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
                        _save(supplier);
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
      ),
    );
  }

  Container supplierRecords() {
    return Container(
      child: Text('Supplier Records'),
    );
  }

  void _save(People supplier) async {
    if (_isNew) {
      await DBHelper.insert(People.table, supplier);
    } else {
      await DBHelper.update(People.table, supplier);
    }
  }
}
