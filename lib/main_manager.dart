import 'package:flutter/material.dart';
import 'package:len_store/managers/loss_manager.dart';
import 'package:len_store/managers/openingbalance_manager.dart';
import 'package:len_store/managers/order_manager.dart';
import 'package:len_store/managers/storage_manager.dart';

import 'package:len_store/tools/resource_drawer.dart';
import 'package:len_store/managers/category_manager.dart';
import 'package:len_store/managers/expense_type_manager.dart';
import 'package:len_store/managers/product_unit_manager.dart';
import 'package:len_store/managers/products_manager.dart';
import 'package:len_store/managers/customer_manager.dart';
import 'package:len_store/managers/supplier_manager.dart';
import 'package:len_store/managers/accounts_manager.dart';

import 'managers/sales_manager.dart';

class MainManager extends StatefulWidget {
  /// Main scaffold manager? hahaha

  final String title;
  MainManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return MainManagerState();
  }
}

class MainManagerState extends State<MainManager> {
  String _currentView;
  Widget _bodyWidget;

  @override
  void initState() {
    _currentView = 'Opening Balance';
    setBodyContent(_currentView);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: ResourceDrawer(setBodyContent),
      body: _bodyWidget,
      bottomNavigationBar: _bottomAppBar(),
    );
  }

  BottomAppBar _bottomAppBar() {
    return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
      MaterialButton(
        child: Text('Orders'),
        onPressed: () {
          setBodyContent('Orders');
        },
      ),
      MaterialButton(
        child: Text('Sales'),
        onPressed: () {
          setBodyContent('Sales');
        },
      )
    ]));
  }

  setBodyContent(String content) {
    setState(() {
      _currentView = content;
      switch (content) {
        case 'Units':
          _bodyWidget = ProductUnitManager(_currentView);
          break;
        case 'Category':
          _bodyWidget = ProductCategoryManager(_currentView);
          break;
        case 'Accounts':
          _bodyWidget = AccountsManager(_currentView);
          break;
        case 'Expense Types':
          _bodyWidget = ExpenseTypeManager(_currentView);
          break;
        case 'Products':
          _bodyWidget = ProductsManager(_currentView);
          break;
        case 'Customers':
          _bodyWidget = CustomersManager(_currentView);
          break;
        case 'Suppliers':
          _bodyWidget = SuppliersManager(_currentView);
          break;
        case 'Orders':
          _bodyWidget = new OrderManager();
          break;
        case 'Sales':
          _bodyWidget = new SalesManager();
          break;
         case 'Opening Balance':
          _bodyWidget = OpeningBalanceManager();
          break;
        case 'Product Storage':
          _bodyWidget = StorageManager();
          break;        
        case 'Losses':
          _bodyWidget = LossManager();
          break;
        default:
          _bodyWidget = Text('data');
      }
    });
  }
}
