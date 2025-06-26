class DocumentUploader {
  String? id;
  String? username;
  String? profilePicture;

  DocumentUploader({this.id, this.username, this.profilePicture});

  factory DocumentUploader.fromJson(Map<String, dynamic> json) {
    return DocumentUploader(
      id: json['_id'],
      username: json['username'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'profilePicture': profilePicture,
      };
}

class Document {
  String? id;
  String? groupId;
  String? title;
  String? description;
  dynamic uploaderId; // Có thể là String hoặc DocumentUploader
  String? imgDocument;
  String? createAt;
  String? mainFile;

  Document({
    this.id,
    this.groupId,
    this.title,
    this.description,
    this.uploaderId,
    this.createAt,
    this.imgDocument,
    this.mainFile,
  });

  Document.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    groupId = json['groupId'];
    title = json['title'];
    description = json['description'];
    if (json['uploaderId'] is Map) {
      uploaderId = DocumentUploader.fromJson(json['uploaderId']);
    } else {
      uploaderId = json['uploaderId'];
    }
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
      'uploaderId': uploaderId is DocumentUploader
          ? (uploaderId as DocumentUploader).toJson()
          : uploaderId,
      'createAt': createAt,
      'imgDocument': imgDocument,
      'mainFile': mainFile,
    };
  }
}
