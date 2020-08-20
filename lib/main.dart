import 'package:flutter/material.dart';
import 'package:len_store/tools/db_helper.dart';
import 'package:len_store/main_manager.dart';

void main() async {

    WidgetsFlutterBinding.ensureInitialized();

    await DBHelper.init();
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Len Store',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainManager('Len Store'),
    );
  }
}

