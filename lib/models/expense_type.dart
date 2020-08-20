import './store_model.dart';

class ExpenseType extends StoreModel {
  int id;
  int expensetypeid;
  String name;
  String where = 'expensetypeid = ?';
  
  static String table = 'expense_type';

  ExpenseType({this.expensetypeid, this.name}){
    id = expensetypeid;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {'name': name};
    if (expensetypeid !=null || id != null) {
      map['expensetypeid'] = id;
      map['expensetypeid'] = expensetypeid;
    }
    return map;
  }

  static ExpenseType fromMap(Map<String, dynamic> map) {
    return ExpenseType(expensetypeid: map['expensetypeid'], name: map['name']);
  }
}
