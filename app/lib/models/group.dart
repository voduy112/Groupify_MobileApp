class Group {
  String? id;
  String? name;
  String? description;
  String? subject;
  dynamic ownerId;
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
    name = json['name'] is Map
        ? json['name']['vi'] ?? json['name'].values.first
        : json['name'];
    description = json['description'];
    subject = json['subject'];
    ownerId = json['ownerId'];
    membersID = (json['membersID'] as List<dynamic>?)
        ?.map((member) {
          if (member is String) return member;
          if (member is Map && member['_id'] != null)
            return member['_id'].toString();
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
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
