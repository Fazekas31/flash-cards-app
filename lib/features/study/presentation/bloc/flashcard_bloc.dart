import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../domain/models/flashcard.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final FlashcardRepository _repository;

  FlashcardBloc(this._repository) : super(FlashcardInitial()) {
    on<LoadFlashcards>(_onLoadFlashcards);
    on<CreateFlashcard>(_onCreateFlashcard);
    on<CreateFlashcardsBulk>(_onCreateFlashcardsBulk);
    on<DeleteFlashcard>(_onDeleteFlashcard);
    on<LoadStudySession>(_onLoadStudySession);
    on<ReviewFlashcard>(_onReviewFlashcard);
  }

  Future<void> _onLoadFlashcards(
    LoadFlashcards event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final cards = await _repository.getFlashcardsByDeck(event.deckId);
      emit(FlashcardLoaded(cards));
    } catch (e) {
      emit(FlashcardError(e.toString()));
    }
  }

  Future<void> _onCreateFlashcard(
    CreateFlashcard event,
    Emitter<FlashcardState> emit,
  ) async {
    final card = Flashcard()
      ..deckId = event.deckId
      ..question = event.question
      ..answer = event.answer;

    await _repository.saveFlashcard(card);
    add(LoadFlashcards(event.deckId));
  }

  Future<void> _onCreateFlashcardsBulk(
    CreateFlashcardsBulk event,
    Emitter<FlashcardState> emit,
  ) async {
    for (var item in event.cards) {
      final card = Flashcard()
        ..deckId = event.deckId
        ..question = item['question']!
        ..answer = item['answer']!;
      await _repository.saveFlashcard(card);
    }
    add(LoadFlashcards(event.deckId));
  }

  Future<void> _onDeleteFlashcard(
    DeleteFlashcard event,
    Emitter<FlashcardState> emit,
  ) async {
    final card = await _repository.getFlashcardById(event.flashcardId);
    if (card != null) {
      final deckId = card.deckId;
      await _repository.deleteFlashcard(event.flashcardId);
      add(LoadFlashcards(deckId));
    }
  }

  Future<void> _onLoadStudySession(
    LoadStudySession event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final cards = await _repository.getStudySession(event.deckId);
      emit(StudySessionLoaded(cards));
    } catch (e) {
      emit(FlashcardError(e.toString()));
    }
  }

  Future<void> _onReviewFlashcard(
    ReviewFlashcard event,
    Emitter<FlashcardState> emit,
  ) async {
    final card = event.flashcard;
    final int q = event.quality;

    if (q == 0) {
      card.repetitions = 0;
      card.intervalDays = 1;
    } else {
      if (card.repetitions == 0) {
        if (q == 1) {
          card.intervalDays = 1;
        } else if (q == 2) {
          card.intervalDays = 2;
        } else if (q == 3) {
          card.intervalDays = 4;
        }
        card.repetitions = 1;
      } else if (card.repetitions == 1) {
        if (q == 1) {
          card.intervalDays = 2;
        } else if (q == 2) {
          card.intervalDays = 4;
        } else if (q == 3) {
          card.intervalDays = 6;
        }
        card.repetitions = 2;
      } else {
        card.intervalDays = (card.intervalDays * card.easeFactor).round();
        card.repetitions += 1;
      }
    }

    card.easeFactor =
        card.easeFactor + (0.1 - (3 - q) * (0.08 + (3 - q) * 0.02));
    if (card.easeFactor < 1.3) card.easeFactor = 1.3;

    card.dueDate = DateTime.now().add(Duration(days: card.intervalDays));

    await _repository.saveFlashcard(card);

    final currentState = state;
    if (currentState is StudySessionLoaded) {
      final remaining = List<Flashcard>.from(currentState.studyCards)
        ..removeWhere((c) => c.id == card.id);
      if (q == 0) {
        remaining.add(card);
      }
      emit(StudySessionLoaded(remaining));
    }
  }
}
