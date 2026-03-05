class Flashcard {
  String id;
  String deckId;
  String question;
  String answer;
  String? imagePath;

  double easeFactor;
  int intervalDays;
  int repetitions;
  DateTime dueDate;

  DateTime createdAt;
  DateTime updatedAt;
  String? userId;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.imagePath,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      imagePath: json['image_path'] as String?,
      easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'question': question,
      'answer': answer,
      'image_path': imagePath,
      'ease_factor': easeFactor,
      'interval_days': intervalDays,
      'repetitions': repetitions,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
