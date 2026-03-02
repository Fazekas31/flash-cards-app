import 'package:isar/isar.dart';

part 'deck.g.dart';

@collection
class Deck {
  Id id = Isar.autoIncrement;

  @Index()
  String? remoteId;

  late String name;
  String? description;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  bool isDeleted = false;
  bool needsSync = true;
}
