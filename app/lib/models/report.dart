class Report {
  String? id;
  String? reporterId;
  String? reason;
  String? documentId;
  String? action;
  String? createDate;

  Report({
    this.id,
    this.reporterId,
    this.reason,
    this.documentId,
    this.action,
    this.createDate,
  });

  Report.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    reporterId = json['reporterId'];
    reason = json['reason'];
    documentId = json['documentId'];
    action = json['action'];
    createDate = json['createDate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reason': reason,
      'documentId': documentId,
      'action': action,
      'createDate': createDate,
    };
  }
}
