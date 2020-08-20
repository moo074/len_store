
abstract class StoreModel {
  
  int id;

  String name;
  
  toMap() {}
  
  static fromMap() {} 

  String where;

  List<dynamic> whereArgs;

}