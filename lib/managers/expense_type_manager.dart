import 'package:flutter/material.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/models/expense_type.dart';

class ExpenseTypeManager extends StatefulWidget {
  final String title;
  ExpenseTypeManager(this.title);

  @override
  State<StatefulWidget> createState() {
    return ExpenseTypeManagerState();
  }
}

class ExpenseTypeManagerState extends State<ExpenseTypeManager> {
  List<ExpenseType> _types = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Expense Type'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _types.length,
                  itemBuilder: (BuildContext context, int position) {
                    var name = _types[position].name;
                    return Card(
                        margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: ListTile(
                            title: Text(name),
                            onTap: () {
                              _detailDialog(context, isNew: false, type:_types[position]);
                            }));
                  })
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            ExpenseType type = new ExpenseType();
            _detailDialog(context, isNew: true, type: type);
          });
        },
      ),
    );
  }

  void refresh() async {
    List<Map<String, dynamic>> _results =
        await DBHelper.query(ExpenseType.table);
    _types = _results.map((item) => ExpenseType.fromMap(item)).toList();
    setState(() {});
  }

  _detailDialog(BuildContext context, {bool isNew, ExpenseType type}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isNew ? 'Add New Expense Type' : 'Update Expense Type Name'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop()),
              FlatButton(
                  child: Text('Save'), onPressed: () => _save(isNew: isNew, type: type))
            ],
            content: TextField(
              autofocus: true,
              controller:
                  TextEditingController(text: !isNew ? type.name : null),
              decoration: InputDecoration(
                  labelText: 'Name', hintText: 'e.g. Electric Bill, Maintenance'),
              onChanged: (value) {
                type.name = value;
              },
            ),
          );
        });
  }

  void _save({bool isNew, ExpenseType type}) async {
    if (isNew) {
      await DBHelper.insert(ExpenseType.table, type);
    } else {
      await DBHelper.update(ExpenseType.table, type);
    }

    setState(() {
      Navigator.of(context).pop();
    });
    refresh();
  }
}
