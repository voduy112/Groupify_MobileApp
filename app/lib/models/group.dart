class Group {
  String? id;
  String? name;
  String? description;
  String? subject;
  String? ownerId;
  List<String>? membersID;
  String? inviteCode;
  String? createDate;
  String? imgGroup;

  Group({
    this.id,
    this.name,
    this.description,
    this.subject,
    this.ownerId,
    this.membersID,
    this.createDate,
    this.inviteCode,
    this.imgGroup,
  });

  Group.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    description = json['description'];
    subject = json['subject'];
    ownerId = json['ownerId'];
    membersID = List<String>.from(json['membersID'] ?? []);
    createDate = json['createDate'];
    inviteCode = json['inviteCode'];
    imgGroup = json['imgGroup'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'ownerId': ownerId,
      'membersID': membersID,
      'createDate': createDate,
      'inviteCode': inviteCode,
      'imgGroup': imgGroup,
    };
  }
}
