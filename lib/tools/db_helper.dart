import 'dart:async';
import 'package:len_store/models/store_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class DBHelper {
  static Database _db;

  static int get _version => 1;

  static Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      String _path = await getDatabasesPath() + '/lenstoredb.sqlite';

      _db = await openDatabase(_path,
          version: _version,
          onCreate: onCreate,
          onConfigure: onConfigure);
      print('db open');

    } catch (ex) {
      print(ex);
    }
  }

  static void onCreate(Database db, int version) async {
    print('onCreate');  

    //category
    await db.execute(
        ' CREATE TABLE category (categoryid INTEGER PRIMARY KEY NOT NULL, name TEXT); ');
    await db.execute(" INSERT INTO category (name) values ('Softdrinks'); ");
    await db.execute(" INSERT INTO category (name) values ('Liqour'); ");
    //units
    await db.execute(
        ' CREATE TABLE product_units (productunitid INTEGER PRIMARY KEY NOT NULL, name TEXT); ');
    await db.execute(" INSERT INTO product_units (name) values ('Bottle'); ");
    await db.execute(" INSERT INTO product_units (name) values ('Case'); ");
    await db.execute(" INSERT INTO product_units (name) values ('Piece'); ");
    //product
    await db.execute(
        ' CREATE TABLE products (productid INTEGER PRIMARY KEY NOT NULL, code TEXT, name TEXT, categoryid INTEGER NOT NULL, productunitid INTEGER NOT NULL); ');
    await db.execute(
        " INSERT INTO products (code, name, categoryid, productunitid) values ('code', 'product', 1, 1); ");
    await db.execute(
        ' CREATE TABLE prod_unit_conversion (produnitconvid INTEGER PRIMARY KEY NOT NULL, productid INTEGER NOT NULL, frproductunitid INTEGER NOT NULL, framount INTEGER NOT NULL, toproductunitid INTEGER NOT NULL, toamount INTEGER NOT NULL); ');
    await db.execute(
        ' CREATE TABLE product_price (priceid INTEGER PRIMARY KEY NOT NULL, date TEXT, amount REAL, iscost INTEGER NOT NULL, productid INTEGER NOT NULL, productunitid INTEGER NOT NULL); ');
    await db.execute(
        " INSERT INTO product_price (date, amount, productid, productunitid, iscost) values (datetime('now'), 20.0, 1, 1, 1); ");
    await db.execute(
        " INSERT INTO product_price (date, amount, productid, productunitid, iscost) values (datetime('now'), 27.0, 1, 1, 0); ");
    //people
    await db.execute(
        ' CREATE TABLE people (peopleid INTEGER PRIMARY KEY NOT NULL, name TEXT, address TEXT, contact TEXT, iscustomer INTEGER NOT NULL); ');
    await db.execute(
        " INSERT INTO people (name, address, contact, iscustomer) values ('customer', 'address', 'contact', 1); ");
    await db.execute(
        " INSERT INTO people (name, address, contact, iscustomer) values ('supplier', 'address', 'contact', 0); ");
    //accounts
    await db.execute(
        ' CREATE TABLE accounts (accountid INTEGER PRIMARY KEY NOT NULL, name TEXT, balance REAL); ');
    await db.execute(
        " INSERT INTO accounts (name, balance) values ('Cash in Hand', 2000.00); ");
    await db.execute(
        " INSERT INTO accounts (name, balance) values ('Bank', 1000.00); ");
    await db.execute(
        ' CREATE TABLE account_transfer (acctransferid INTEGER PRIMARY KEY NOT NULL, fraccountid INTEGER NOT NULL, toaccountid INTEGER NOT NULL, amount REAL); ');
    await db.execute(
        ' CREATE TABLE account_transactions (acctransactionid INTEGER PRIMARY KEY NOT NULL, accountid INTEGER NOT NULL, date TEXT, amount REAL, transactiontype TEXT, transactionid INTEGER); ');
    await db.execute(
        " INSERT INTO account_transactions (accountid, date, amount, transactiontype) values (1, datetime('now'), 2000.0, 'Capital'); ");
    //transactions
    await db.execute(
        ' CREATE TABLE orders (orderid INTEGER PRIMARY KEY NOT NULL, date TEXT, isorder INTEGER NOT NULL, peopleid INTEGER NOT NULL, totalamount REAL, ispaid INTEGER, iscomplete INTEGER, accountid INTEGER NOT NULL); ');
    await db.execute(
        ' CREATE TABLE orderitems (orderitemid INTEGER PRIMARY KEY NOT NULL, isorder INTEGER NOT NULL, orderid INTEGER NOT NULL, date TEXT, categoryid INTEGER NOT NULL, productid INTEGER NOT NULL, price REAL, productunitid INTEGER NOT NULL, count INTEGER NOT NULL, priceid INTEGER); ');
    await db.execute(
        ' CREATE TABLE loss (lossid INTEGER PRIMARY KEY NOT NULL, date TEXT, productid INTEGER NOT NULL, price REAL, productunitid INTEGER NOT NULL, count INTEGER NOT NULL, priceid INTEGER, price REAL, categoryid INTEGER); ');
    await db.execute(
        ' CREATE TABLE product_storage (storageid INTEGER PRIMARY KEY NOT NULL, date TEXT, categoryid INTEGER NOT NULL, productid INTEGER NOT NULL, priceid INTEGER NOT NULL, price REAL, productunitid INTEGER NOT NULL, count INTEGER NOT NULL, UNIQUE(productid, productunitid, priceid));  ');
    await db.execute(
        ' CREATE TABLE openingbalance (openingid INTEGER PRIMARY KEY NOT NULL, date TEXT, categoryid INTEGER NOT NULL, productid INTEGER NOT NULL, priceid INTEGER NOT NULL, price REAL, productunitid INTEGER NOT NULL, count INTEGER NOT NULL, UNIQUE(productid, productunitid, priceid));  ');

    //expense
    await db.execute(
        ' CREATE TABLE expense_type (expensetypeid INTEGER PRIMARY KEY NOT NULL, name TEXT); ');
    await db
        .execute(" INSERT INTO expense_type (name) values ('Electric Bill'); ");
    await db.execute(" INSERT INTO expense_type (name) values ('Tax'); ");
    await db.execute(
        " INSERT INTO expense_type (name) values ('Transportation'); ");
    await db.execute(
        ' CREATE TABLE expenses (expenseid INTEGER PRIMARY KEY NOT NULL, expensetypeid INTEGER NOT NULL, description TEXT, date TEXT, amount REAL); ');
    //credit payment
    await db.execute(
        ' CREATE TABLE payments (paymentid INTEGER PRIMARY KEY NOT NULL, date TEXT, peopleid INTEGER NOT NULL, amount REAL, accountid INTEGER NOT NULL, iscomplete INTEGER); ');
    await db.execute(
        ' CREATE TABLE payment_items (paymentitemid INTEGER PRIMARY KEY NOT NULL, paymentid INTEGER NOT NULL, salesid INTEGER NOT NULL, amount REAL, customerid INTEGER NOT NULL, date TEXT); ');
   
    await db.execute('''CREATE VIEW item_transactions (
        product,
        date,
        count,
        totalamount,
        transactiontype
      ) AS 
        SELECT date, products.name, product_units.name, category.name, amount, count, transactiontype
        FROM
          ( SELECT  date, productid, categoryid, count, productunitid, (price * count) AS amount, "Order" AS transactiontype 
          FROM orders WHERE iscomplete = 1 AND isorder = 1
          UNION ALL
          SELECT  date, productid, categoryid, count, productunitid, (price * count) AS amount, "Sales" AS transactiontype  
          FROM orders WHERE iscomplete = 1 AND isorder = 0
          UNION ALL
          SELECT  date, productid, categoryid, count, productunitid, (price * count) AS amount, "Opening" AS transactiontype 
          FROM openingbalance
          UNION ALL
          SELECT  date, productid, categoryid, count, productunitid, (price * count) AS amount, "Loss" AS transactiontype  
          FROM loss ) transactions 
            INNER JOIN products ON products.productid = transactions.productid
            INNER JOIN product_units ON product_units.productunitid = transactions.productunitid
            INNER JOIN category ON category.categoryid = transactions.categoryid
        ORDER BY transactions.date DESC;
    ''');
  
  }
  
  static Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<List<Map<String, dynamic>>> query(String table) async =>
      _db.query(table);

  static Future<int> insert(String table, StoreModel model) async =>
      await _db.insert(table, model.toMap());

  static Future<int> update(String table, StoreModel model) async => await _db
      .update(table, model.toMap(), where: model.where, whereArgs: [model.id]);

  static Future<int> delete(String table, StoreModel model) async =>
      await _db.delete(table, where: model.where, whereArgs: [model.id]);

  static Future<List<Map<String, dynamic>>> getRecord(
          String table, StoreModel model) async =>
      _db.query(table, where: model.where, whereArgs: model.whereArgs);

  static Future<List<Map<String, dynamic>>> getRecords(
          String table, String where, List<dynamic> whereArgs) async =>
      _db.query(table, where: where, whereArgs: whereArgs);
}
