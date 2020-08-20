import './store_model.dart';

class People extends StoreModel {
  int id;
  int peopleid;
  bool iscustomer = true;
  String name;
  String address;
  String contact;
  String where = 'peopleid = ?';

  static String table = 'people';

  People({
    this.peopleid,
    this.iscustomer,
    this.name,
    this.address,
    this.contact,
  }) {
    id = peopleid;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': name,
      'address': address,
      'contact': contact,
      'iscustomer': iscustomer ? 1 : 0,
    };
    if (peopleid != null || id != null) {
      map['peopleid'] = id;
    }
    return map;
  }

  static People fromMap(Map<String, dynamic> map) {
    return People(
        peopleid: map['peopleid'],
        iscustomer: map['iscustomer'] == 1,
        name: map['name'],
        address: map['address'],
        contact: map['contact'].toString());
  }

  String toString() {
    return 'peopleid: $peopleid, iscustomer: $iscustomer, name: $name, address: $address, contact: $contact, ';
  }
}
