// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ALFA STUDY CARDS';

  @override
  String get onboardingTitle1 => 'Welcome to Flashcards';

  @override
  String get onboardingBody1 =>
      'Learn anything quickly and efficiently using spaced repetition.';

  @override
  String get onboardingTitle2 => 'Offline First';

  @override
  String get onboardingBody2 =>
      'Study anywhere, anytime. Your progress syncs as soon as you reconnect.';

  @override
  String get onboardingTitle3 => 'Smart Automation';

  @override
  String get onboardingBody3 =>
      'You don\'t pick the dates! The algorithm schedules cards automatically based on your feedback (Easy, Good, Hard).';

  @override
  String get onboardingTitle4 => 'Let\'s Get Started!';

  @override
  String get onboardingBody4 =>
      'Create your decks, add cards, and master your studies.';

  @override
  String get onboardingSkip => 'SKIP';

  @override
  String get onboardingDone => 'DONE';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNoAccount => 'Don\'t have an account? Sign up';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerButton => 'Register';

  @override
  String get registerHasAccount => 'Already have an account? Login';

  @override
  String get decksTitle => 'My Decks';

  @override
  String get decksEmpty => 'No decks yet. Create one!';

  @override
  String get deckNew => 'New Deck';

  @override
  String get deckName => 'Name';

  @override
  String get deckDescription => 'Description';

  @override
  String get deckCancel => 'Cancel';

  @override
  String get deckCreate => 'Create';

  @override
  String get flashcardsTitle => 'Deck Flashcards';

  @override
  String get flashcardsStart => 'Start Study Session';

  @override
  String get flashcardsEmpty => 'No cards yet.';

  @override
  String get flashcardsNextReview => 'Next review:';

  @override
  String get flashcardNew => 'New Flashcard';

  @override
  String get flashcardQuestion => 'Question';

  @override
  String get flashcardAnswer => 'Answer';

  @override
  String get flashcardAdd => 'Add';

  @override
  String get studySessionTitle => 'Study Session';

  @override
  String get studySessionEmpty => 'No more cards to study today! 🎉';

  @override
  String get studySessionBack => 'Back to Home';

  @override
  String get studySessionRemaining => 'Cards remaining:';

  @override
  String get studyQualityAgain => 'Again';

  @override
  String get studyQualityHard => 'Hard';

  @override
  String get studyQualityGood => 'Good';

  @override
  String get studyQualityEasy => 'Easy';

  @override
  String get aiTeacher => 'AI Teacher 🤖';

  @override
  String get aiAnalyzing => 'Analyzing card...';

  @override
  String get aiExplainError => 'Error:';

  @override
  String get aiExplainButton => 'Explain Better (AI)';
}
