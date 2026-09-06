class TemplateModel {
  final int id;
  final String name;
  final String type;
  final String? htmlContent;
  final bool isActive;
  final String? filePath;
  final int? companyId;
  bool isFavoriteTemplate;

  TemplateModel({
    required this.id,
    required this.name,
    required this.type,
    this.htmlContent,
    this.isActive = true,
    this.filePath,
    this.companyId,
    this.isFavoriteTemplate = false,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Template',
      type: json['type']?.toString() ?? '',
      htmlContent: json['htmlContent']?.toString(),
      isActive: json['isActive'] == true || json['active'] == true,
      filePath: json['filePath']?.toString(),
      companyId: json['companyId'] is int
          ? json['companyId']
          : int.tryParse(json['companyId']?.toString() ?? ''),
      isFavoriteTemplate: json['isFavoriteTemplate'] == true || json['favoriteTemplate'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'htmlContent': htmlContent,
      'isActive': isActive,
      'filePath': filePath,
      'companyId': companyId,
      'isFavoriteTemplate': isFavoriteTemplate,
    };
  }
}
