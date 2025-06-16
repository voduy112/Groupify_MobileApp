class ResultQuiz {
  String? id;
  String? quizId;
  String? userId;
  String? testAt;
  String? score;

  ResultQuiz({
    this.id,
    this.quizId,
    this.userId,
    this.score,
    this.testAt,
  });

  ResultQuiz.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    quizId = json['quizId'];
    userId = json['userId'];
    score = json['score'];
    testAt = json['testAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'score': score,
      'testAt': testAt,
    };
  }
}
