import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ALFA STUDY CARDS'**
  String get appTitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Flashcards'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Learn anything quickly and efficiently using spaced repetition.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Offline First'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Study anywhere, anytime. Your progress syncs as soon as you reconnect.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Smart Automation'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'You don\'t pick the dates! The algorithm schedules cards automatically based on your feedback (Easy, Good, Hard).'**
  String get onboardingBody3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started!'**
  String get onboardingTitle4;

  /// No description provided for @onboardingBody4.
  ///
  /// In en, this message translates to:
  /// **'Create your decks, add cards, and master your studies.'**
  String get onboardingBody4;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get onboardingSkip;

  /// No description provided for @onboardingDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get onboardingDone;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get loginNoAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get registerHasAccount;

  /// No description provided for @decksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Decks'**
  String get decksTitle;

  /// No description provided for @decksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No decks yet. Create one!'**
  String get decksEmpty;

  /// No description provided for @deckNew.
  ///
  /// In en, this message translates to:
  /// **'New Deck'**
  String get deckNew;

  /// No description provided for @deckName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get deckName;

  /// No description provided for @deckDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get deckDescription;

  /// No description provided for @deckCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deckCancel;

  /// No description provided for @deckCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get deckCreate;

  /// No description provided for @flashcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck Flashcards'**
  String get flashcardsTitle;

  /// No description provided for @flashcardsStart.
  ///
  /// In en, this message translates to:
  /// **'Start Study Session'**
  String get flashcardsStart;

  /// No description provided for @flashcardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards yet.'**
  String get flashcardsEmpty;

  /// No description provided for @flashcardsNextReview.
  ///
  /// In en, this message translates to:
  /// **'Next review:'**
  String get flashcardsNextReview;

  /// No description provided for @flashcardNew.
  ///
  /// In en, this message translates to:
  /// **'New Flashcard'**
  String get flashcardNew;

  /// No description provided for @flashcardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get flashcardQuestion;

  /// No description provided for @flashcardAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get flashcardAnswer;

  /// No description provided for @flashcardAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get flashcardAdd;

  /// No description provided for @studySessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Session'**
  String get studySessionTitle;

  /// No description provided for @studySessionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No more cards to study today! 🎉'**
  String get studySessionEmpty;

  /// No description provided for @studySessionBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get studySessionBack;

  /// No description provided for @studySessionRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cards remaining:'**
  String get studySessionRemaining;

  /// No description provided for @studyQualityAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get studyQualityAgain;

  /// No description provided for @studyQualityHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get studyQualityHard;

  /// No description provided for @studyQualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get studyQualityGood;

  /// No description provided for @studyQualityEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get studyQualityEasy;

  /// No description provided for @aiTeacher.
  ///
  /// In en, this message translates to:
  /// **'AI Teacher 🤖'**
  String get aiTeacher;

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing card...'**
  String get aiAnalyzing;

  /// No description provided for @aiExplainError.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get aiExplainError;

  /// No description provided for @aiExplainButton.
  ///
  /// In en, this message translates to:
  /// **'Explain Better (AI)'**
  String get aiExplainButton;

  /// No description provided for @magicGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Magic Generator (AI) ✨'**
  String get magicGeneratorTitle;

  /// No description provided for @magicGeneratorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste notes or part of a PDF text. Gemini will dissect the knowledge and generate spaced repetition cards!'**
  String get magicGeneratorSubtitle;

  /// No description provided for @magicGeneratorInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: \"Photosynthesis is the biological process where the plant...\"\nPaste text or attach a file.'**
  String get magicGeneratorInputHint;

  /// No description provided for @magicGeneratorCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get magicGeneratorCamera;

  /// No description provided for @magicGeneratorAttachment.
  ///
  /// In en, this message translates to:
  /// **'PDF / Image'**
  String get magicGeneratorAttachment;

  /// No description provided for @magicGeneratorAttachmentReady.
  ///
  /// In en, this message translates to:
  /// **'📎 Attachment ready:'**
  String get magicGeneratorAttachmentReady;

  /// No description provided for @magicGeneratorSuccess.
  ///
  /// In en, this message translates to:
  /// **'⚡ {count} cards generated successfully!'**
  String magicGeneratorSuccess(int count);

  /// No description provided for @magicGeneratorButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Cards Immediately'**
  String get magicGeneratorButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
