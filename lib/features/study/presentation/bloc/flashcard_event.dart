import '../../domain/models/flashcard.dart';

abstract class FlashcardEvent {}

class LoadFlashcards extends FlashcardEvent {
  final int deckId;
  LoadFlashcards(this.deckId);
}

class LoadStudySession extends FlashcardEvent {
  final int deckId;
  LoadStudySession(this.deckId);
}

class CreateFlashcard extends FlashcardEvent {
  final int deckId;
  final String question;
  final String answer;
  CreateFlashcard(this.deckId, this.question, this.answer);
}

class CreateFlashcardsBulk extends FlashcardEvent {
  final int deckId;
  final List<Map<String, String>> cards;
  CreateFlashcardsBulk(this.deckId, this.cards);
}

class DeleteFlashcard extends FlashcardEvent {
  final int flashcardId;
  DeleteFlashcard(this.flashcardId);
}

class ReviewFlashcard extends FlashcardEvent {
  final Flashcard flashcard;
  final int quality;
  ReviewFlashcard(this.flashcard, this.quality);
}
