import 'package:flutter/material.dart';

import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/People.dart';

class CustomerForm extends StatefulWidget {
  final People customer;
  final bool isNew;

  CustomerForm(this.isNew, {this.customer});

  @override
  CustomerFormState createState() {
    return CustomerFormState();
  }
}

class CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  People customer;
  bool _isNew = true;

  @override
  void initState() {
    customer = widget.customer;
    _isNew = widget.isNew;
    if (_isNew) customer = new People();
    customer.iscustomer = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_isNew);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New Customer' : "Update Customer"),
      ),
      body: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [productDetails(context), customerRecords()])),
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
            controller: TextEditingController(text: customer.name),
            decoration: InputDecoration(
                labelText: 'Name', hintText: 'Jane, Sidney'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
            onChanged: (value) {
              customer.name = value.toString();
            },
          ),
          TextFormField(
            controller: TextEditingController(text: customer.address),
            decoration: InputDecoration(
                labelText: 'Address', hintText: 'Narra'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
            onChanged: (value) {
              customer.address = value.toString();
            },
          ),
          TextFormField(
            controller: TextEditingController(text: customer.contact),
            decoration: InputDecoration(
                labelText: 'Contact Info', hintText: 'e.g. 09124123412, customer@gmail.com'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter contact';
              }
              return null;
            },
            onChanged: (value) {
              customer.contact = value.toString();
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
                        _save(customer);
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

  Container customerRecords() {
    return Container(
      child: Text('People Records'),
    );
  }

  void _save(People customer) async {
    if (_isNew) {
      await DBHelper.insert(People.table, customer);
    } else {
      await DBHelper.update(People.table, customer);
    }
  }
}
