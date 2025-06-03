class Grouprequest {
  String? id;
  String? groupId;
  dynamic userId; 

  String? requestAt;
  

  Grouprequest(
      {this.id,
      this.groupId,
      this.userId,
      this.requestAt,
  });

  Grouprequest.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    groupId = json['groupId'];
    userId = json['userId'];
    requestAt = json['requestAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'requestAt': requestAt,
    };
  }
}
