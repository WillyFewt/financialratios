class FinanceEntryType {
  final String id;
  final String name;
  final String rootName;
  final String subRootName;
  final String groupName;
  final bool isCredit;
  final String description;

  FinanceEntryType(this.id, this.name, this.rootName, this.subRootName, this.groupName,
      this.isCredit, this.description);

  factory FinanceEntryType.fromDBMap(Map<String, dynamic> dataMap) {
    return FinanceEntryType(
        dataMap["id"],
        dataMap["name"],
        dataMap["rootName"],
        dataMap["subRootName"],
        dataMap["groupName"],
        dataMap["isCredit"] == 0 ? false : true,
        dataMap["description"]);
  }
}


