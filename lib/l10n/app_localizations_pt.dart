// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'ALFA STUDY CARDS';

  @override
  String get onboardingTitle1 => 'Bem-vindo ao Flashcards';

  @override
  String get onboardingBody1 =>
      'Aprenda qualquer coisa de forma rápida e eficiente utilizando repetição espaçada.';

  @override
  String get onboardingTitle2 => 'Offline First';

  @override
  String get onboardingBody2 =>
      'Estude em qualquer lugar, a qualquer momento. Seu progresso será sincronizado assim que reconectar.';

  @override
  String get onboardingTitle3 => 'Automação Inteligente';

  @override
  String get onboardingBody3 =>
      'Você não escolhe as datas! O algoritmo repete os cartões automaticamente baseado no seu feedback (Fácil, Bom, Difícil).';

  @override
  String get onboardingTitle4 => 'Vamos Começar!';

  @override
  String get onboardingBody4 =>
      'Crie seus decks, adicione cartões e domine seus estudos.';

  @override
  String get onboardingSkip => 'PULAR';

  @override
  String get onboardingDone => 'PRONTO';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginNoAccount => 'Não tem uma conta? Cadastre-se';

  @override
  String get registerTitle => 'Registrar';

  @override
  String get registerEmail => 'E-mail';

  @override
  String get registerPassword => 'Senha';

  @override
  String get registerButton => 'Cadastrar';

  @override
  String get registerHasAccount => 'Já tem uma conta? Login';

  @override
  String get decksTitle => 'Meus Decks';

  @override
  String get decksEmpty => 'Nenhum deck ainda. Crie um!';

  @override
  String get deckNew => 'Novo Deck';

  @override
  String get deckName => 'Nome';

  @override
  String get deckDescription => 'Descrição';

  @override
  String get deckCancel => 'Cancelar';

  @override
  String get deckCreate => 'Criar';

  @override
  String get flashcardsTitle => 'Flashcards do Deck';

  @override
  String get flashcardsStart => 'Começar Sessão de Estudos';

  @override
  String get flashcardsEmpty => 'Nenhum cartão ainda.';

  @override
  String get flashcardsNextReview => 'Próxima revisão:';

  @override
  String get flashcardNew => 'Novo Flashcard';

  @override
  String get flashcardQuestion => 'Pergunta';

  @override
  String get flashcardAnswer => 'Resposta';

  @override
  String get flashcardAdd => 'Adicionar';

  @override
  String get studySessionTitle => 'Sessão de Estudos';

  @override
  String get studySessionEmpty => 'Não há mais cartões para estudar hoje! 🎉';

  @override
  String get studySessionBack => 'Voltar aos Decks';

  @override
  String get studySessionRemaining => 'Cartões restantes:';

  @override
  String get studyQualityAgain => 'Repetir';

  @override
  String get studyQualityHard => 'Difícil';

  @override
  String get studyQualityGood => 'Bom';

  @override
  String get studyQualityEasy => 'Fácil';

  @override
  String get aiTeacher => 'Professor IA 🤖';

  @override
  String get aiAnalyzing => 'Analisando o cartão...';

  @override
  String get aiExplainError => 'Erro:';

  @override
  String get aiExplainButton => 'Explique-me Melhor (IA)';
}
