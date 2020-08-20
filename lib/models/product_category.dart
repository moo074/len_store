import './store_model.dart';

class ProductCategory extends StoreModel {
  int id;
  int categoryid;
  String name;
  String where = 'categoryid = ?';
  
  static String table = 'category';

  ProductCategory({this.categoryid, this.name}){
    id = categoryid;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {'name': name};
    if (categoryid !=null || id != null) {
      map['categoryid'] = id;
      map['categoryid'] = categoryid;
    }
    return map;
  }

  static ProductCategory fromMap(Map<String, dynamic> map) {
    return ProductCategory(categoryid: map['categoryid'], name: map['name']);
  }
}
