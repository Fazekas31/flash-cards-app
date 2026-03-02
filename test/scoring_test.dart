import 'package:flash_cards/features/study/presentation/bloc/flashcard_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash_cards/features/study/domain/models/flashcard.dart';
import 'package:flash_cards/features/study/presentation/bloc/flashcard_bloc.dart';
import 'package:flash_cards/features/study/domain/repositories/flashcard_repository.dart';

class FakeFlashcardRepository implements FlashcardRepository {
  Flashcard? lastSaved;

  @override
  Future<int> saveFlashcard(Flashcard flashcard) async {
    lastSaved = flashcard;
    return 1;
  }

  @override
  Future<void> deleteFlashcard(int id) async {}

  @override
  Future<Flashcard?> getFlashcardById(int id) async => null;

  @override
  Future<List<Flashcard>> getFlashcardsByDeck(int deckId) async => [];

  @override
  Future<List<Flashcard>> getStudySession(int deckId, {int limit = 20}) async =>
      [];

  @override
  Future<List<Flashcard>> getUnsyncedFlashcards() async => [];
}

void main() {
  group('SM-2 Scoring Algorithm Tests (FlashcardBloc)', () {
    late FlashcardBloc bloc;
    late FakeFlashcardRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeFlashcardRepository();
      bloc = FlashcardBloc(fakeRepo);
    });

    tearDown(() {
      bloc.close();
    });

    test(
      'Quality 0 (Again) resets interval to 1 day and decreases easeFactor',
      () async {
        final card = Flashcard()
          ..easeFactor = 2.5
          ..repetitions = 3
          ..intervalDays = 6;

        // Note: testing internal logic without emitting stream can be done slightly easier if abstracted,
        // but Since event processing is asynchronous, we can dispatch and delay.
        bloc.add(ReviewFlashcard(card, 0));
        await Future.delayed(Duration(milliseconds: 100));

        final saved = fakeRepo.lastSaved!;
        expect(saved.intervalDays, 1);
        expect(saved.repetitions, 0);
        expect(saved.easeFactor, lessThan(2.5));
      },
    );

    test('Quality 3 (Easy) increases interval and easeFactor', () async {
      final card = Flashcard()
        ..easeFactor = 2.5
        ..repetitions = 0
        ..intervalDays = 0;

      bloc.add(ReviewFlashcard(card, 3));
      await Future.delayed(Duration(milliseconds: 100));

      final saved = fakeRepo.lastSaved!;
      expect(saved.repetitions, 1);
      expect(saved.intervalDays, 1);
      expect(saved.easeFactor, greaterThan(2.5));

      bloc.add(ReviewFlashcard(saved, 3));
      await Future.delayed(Duration(milliseconds: 100));

      final saved2 = fakeRepo.lastSaved!;
      expect(saved2.repetitions, 2);
      expect(saved2.intervalDays, 6);
    });
  });
}
