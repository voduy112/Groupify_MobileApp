class Answer {
  final String text;
  final bool isCorrect;

  Answer({
    required this.text,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class Question {
  final String text;
  final List<Answer> answers;

  Question({
    required this.text,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'] ?? '',
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => Answer.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String groupId;
  final List<Question> questions;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.groupId,
    required this.questions,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      groupId: json['groupId'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'groupId': groupId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
