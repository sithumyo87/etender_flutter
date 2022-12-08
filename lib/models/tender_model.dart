class TenderModel {
  String id;
  String type;
  String serial;
  String title;
  String description;
  String department;
  String price;
  String currency;
  String publishedAt;
  String closedAt;
  String downloadAt;
  String state;

  TenderModel({
    required this.id,
    required this.type,
    required this.serial,
    required this.title,
    required this.description,
    required this.department,
    required this.price,
    required this.currency,
    required this.publishedAt,
    required this.closedAt,
    required this.downloadAt,
    required this.state,
  });
}
