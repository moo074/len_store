import 'package:flutter/material.dart';

class ResourceDrawer extends StatelessWidget {
  final Function _selectResource;

  ResourceDrawer(this._selectResource);

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerItems = new List<Widget>();
    drawerItems.add(DrawerHeader(
      child: Column(
        children: <Widget>[
          SizedBox(height: 50),
          Text(
            'Resources',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40.0),
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    ));
    drawerItems.addAll(_resources
        .map((e) => ListTile(
              title: Text(e),
              onTap: () {
                _selectResource(e);
                Navigator.pop(context);
              },
            ))
        .toList());

    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: drawerItems,
    ));
  }

  final List<String> _resources = [
    'Products',
    'Units',
    'Category',
    'Expense Types',
    'Customers',
    'Suppliers',
    'Accounts',
    'Opening Balance',
    'Product Storage',
    'Expenses',
    'Losses',
    'Credit Payment',
    'Transaction History',
  ];
}
