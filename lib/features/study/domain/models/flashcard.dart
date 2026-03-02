import 'package:isar/isar.dart';

part 'flashcard.g.dart';

@collection
class Flashcard {
  Id id = Isar.autoIncrement;

  @Index()
  String? remoteId;

  @Index()
  late int deckId;

  late String question;
  late String answer;
  String? imagePath;

  double easeFactor = 2.5;
  int intervalDays = 0;
  int repetitions = 0;
  DateTime dueDate = DateTime.now();

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  bool isDeleted = false;
  bool needsSync = true;
}
