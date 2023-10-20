// ignore_for_file: file_names

class WidgetsEntity {
  String id;
  String title;
  String icon;
  String widgetType;
  String documentIdData;

  WidgetsEntity({
    this.id = '',
    this.title = '',
    this.icon = '',
    this.widgetType = '',
    this.documentIdData = '',
  });

  WidgetsEntity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        icon = json['icon'],
        widgetType = json['widgetType'],
        documentIdData = json['documentIdData'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'widgetType': widgetType,
      'documentIdData': documentIdData
    };
  }
}
