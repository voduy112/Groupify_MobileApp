class Document {
  String? id;
  String? groupId;
  String? title;
  String? description;
  String? uploaderId;
  String? imgDocument;
  String? createAt;
  String? mainFile;

  Document(
      {this.id,
      this.groupId,
      this.title,
      this.description,
      this.uploaderId,
      this.createAt,
      this.imgDocument,
      this.mainFile});

  Document.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    groupId = json['groupId'];
    title = json['title'];
    description = json['description'];
    uploaderId = json['uploaderId'];
    createAt = json['createAt'];
    imgDocument = json['imgDocument'];
    mainFile = json['mainFile'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'uploaderId': uploaderId,
      'createAt': createAt,
      'imgDocument': imgDocument,
      'mainFile': mainFile,
    };
  }
}
