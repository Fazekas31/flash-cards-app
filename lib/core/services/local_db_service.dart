import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/decks/domain/models/deck.dart';
import '../../features/study/domain/models/flashcard.dart';

class LocalDbService {
  late Isar _isar;

  Isar get isar => _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([DeckSchema, FlashcardSchema], directory: dir.path);
  }
}
