class Data {
  final String id;
  final int count;

  Data(this.id, this.count);

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(json['_id'].toString(), int.parse(json['count'].toString()));
  }

  String getId() {
    return this.id;
  }

  int getCount() {
    return this.count;
  }
}
