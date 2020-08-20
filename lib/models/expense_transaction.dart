import './store_model.dart';

class ExpenseTransaction extends StoreModel {
  int id;
  int accountid;
  int expensetypeid;
  DateTime date;
  String description;
  double amount;
  String where = 'expenseid = ?';

  static String table = 'expenses';

  ExpenseTransaction({
    this.id,
    this.accountid,
    this.date,
    this.amount,
    this.description,
    this.expensetypeid,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'accountid': accountid,
      'amount': amount,
      'date': date.toString(),
      'description': description,
      'expensetypeid': expensetypeid
    };
    if (id != null) {
      map['expenseid'] = id;
    }

    return map;
  }

  static ExpenseTransaction fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['expenseid'],
      accountid: map['accountid'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      expensetypeid: map['expensetypeid'],
    );
  }

  String toString() {
    return 'id: $id, accountid: $accountid, amount: $amount, date: $date, description: $description, expensetypeid: $expensetypeid,';
  } 
}
