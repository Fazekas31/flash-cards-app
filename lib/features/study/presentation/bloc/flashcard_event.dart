import '../../domain/models/flashcard.dart';

abstract class FlashcardEvent {}

class LoadFlashcards extends FlashcardEvent {
  final String deckId;
  LoadFlashcards(this.deckId);
}

class LoadStudySession extends FlashcardEvent {
  final String deckId;
  LoadStudySession(this.deckId);
}

class CreateFlashcard extends FlashcardEvent {
  final String deckId;
  final String question;
  final String answer;
  CreateFlashcard(this.deckId, this.question, this.answer);
}

class CreateFlashcardsBulk extends FlashcardEvent {
  final String deckId;
  final List<Map<String, String>> cards;
  CreateFlashcardsBulk(this.deckId, this.cards);
}

class DeleteFlashcard extends FlashcardEvent {
  final String flashcardId;
  DeleteFlashcard(this.flashcardId);
}

class ReviewFlashcard extends FlashcardEvent {
  final Flashcard flashcard;
  final int quality;
  ReviewFlashcard(this.flashcard, this.quality);
}

class UpdateFlashcard extends FlashcardEvent {
  final Flashcard flashcard;
  UpdateFlashcard(this.flashcard);
}
