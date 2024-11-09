
class FinanceEntry {
  String id;
  final String typeID;
  final String rootName;
  final String subRootName;
  final String groupName;
  //final String typePath;
  final String _name;
  String customName;
  num amount;
  String description;
  final int isSpouse;

  FinanceEntry(this.id, this.typeID, this.rootName, this.subRootName,
      this.groupName, this._name, this.customName, this.amount, this.description, this.isSpouse);

  String get name => customName == null ? _name : "(Others) $customName";
  String get groupPath => "$rootName##$subRootName##$groupName";

  factory FinanceEntry.fromDBMap(Map<String, dynamic> map) {
    var fe = FinanceEntry(
        map["id"],
        map["typeID"],
        map["rootName"],
        map["subRootName"],
        map["groupName"],
        map["name"],
        map["customName"],
        map["amount"],
        map["description"],
        map["isSpouse"]);
    return fe;
  }

  Map<String, dynamic> toDBMap(String userID) {
    Map<String, dynamic> map = {
      "id": id,
      "userID": userID,
      "typeID": typeID,
      "customName": customName,
      "amount": amount,
      "isSpouse": isSpouse
    };
    return map;
  }

  @override
  String toString() {
    return "$id -- $typeID -- $customName -- $amount -- $isSpouse";
  } 
}


class EntryFilter {
  final _value;
  final _name;
  const EntryFilter._internal(this._value, this._name);
  get value => _value;
  get name => _name;
  toString() => 'Enum.$_value';

  static const PERSONAL = const EntryFilter._internal(0, 'Personal');
  static const SPOUSE = const EntryFilter._internal(1, 'Spouse');
  static const COMBINED = const EntryFilter._internal(null, 'Combined');
}
  






