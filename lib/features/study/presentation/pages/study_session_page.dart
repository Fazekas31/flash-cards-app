import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_card/flip_card.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../../domain/models/flashcard.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/linkable_text_widget.dart';
import '../../../../core/services/gemini_ai_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class StudySessionPage extends StatefulWidget {
  final String deckId;
  const StudySessionPage({super.key, required this.deckId});

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(LoadStudySession(widget.deckId));
  }

  void _reviewCard(Flashcard card, int quality) {
    context.read<FlashcardBloc>().add(ReviewFlashcard(card, quality));
    if (cardKey.currentState != null && !cardKey.currentState!.isFront) {
      cardKey.currentState!.toggleCardWithoutAnimation();
    }
  }

  void _handleReview(Flashcard card, int quality) async {
    if (quality == 0) {
      // Opção 2: Se errou (qualidade 0), explica antes de pular
      await _showGeminiExplanation(context, card, isError: true);
    }
    _reviewCard(card, quality);
  }

  Future<void> _showGeminiExplanation(
    BuildContext context,
    Flashcard card, {
    bool isError = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.aiTeacher,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B194C),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: GeminiAiService().explainFlashcardTheme(
                        card.question,
                        card.answer,
                        isError: isError,
                        languageCode: Localizations.localeOf(
                          context,
                        ).languageCode,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF76E0A3),
                                ),
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context)!.aiAnalyzing),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              '${AppLocalizations.of(context)!.aiExplainError} ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else {
                          return Markdown(
                            controller: scrollController,
                            data: snapshot.data ?? '',
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Color(0xFF0B194C),
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B194C),
                              ),
                              a: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onTapLink: (text, href, title) async {
                              if (href != null) {
                                final uri = Uri.parse(href);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              }
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.studySessionTitle,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: BlocBuilder<FlashcardBloc, FlashcardState>(
        builder: (context, state) {
          if (state is FlashcardLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is StudySessionLoaded) {
            if (state.studyCards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/confetti.png', // Assuming we will add an asset later, fallback to Icon
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.celebration,
                          size: 100,
                          color: Color(0xFF76E0A3),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No more cards to study today! 🎉',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFF0B194C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF76E0A3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              );
            }

            final currentCard = state.studyCards.first;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${AppLocalizations.of(context)!.studySessionRemaining} ${state.studyCards.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF76E0A3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: FlipCard(
                        key: cardKey,
                        flipOnTouch: true,
                        front: Card(
                          elevation: 0,
                          color: const Color(0xFFE5F9ED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: LinkableTextWidget(
                                text: currentCard.question,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: const Color(0xFF0B194C)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        back: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: LinkableTextWidget(
                                      text: currentCard.answer,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: const Color(0xFF0B194C),
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                child: OutlinedButton.icon(
                                  onPressed: () => _showGeminiExplanation(
                                    context,
                                    currentCard,
                                  ),
                                  icon: const Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFF0B194C),
                                  ),
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.aiExplainButton,
                                    style: const TextStyle(
                                      color: Color(0xFF0B194C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF76E0A3),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _reviewButton(
                                      AppLocalizations.of(
                                        context,
                                      )!.studyQualityAgain,
                                      const Color(0xFFFA7673),
                                      () => _handleReview(currentCard, 0),
                                    ),
                                    const SizedBox(width: 8),
                                    _reviewButton(
                                      AppLocalizations.of(
                                        context,
                                      )!.studyQualityHard,
                                      const Color(0xFFFFB470),
                                      () => _handleReview(currentCard, 1),
                                    ),
                                    const SizedBox(width: 8),
                                    _reviewButton(
                                      AppLocalizations.of(
                                        context,
                                      )!.studyQualityGood,
                                      const Color(0xFF76E0A3),
                                      () => _handleReview(currentCard, 2),
                                    ),
                                    const SizedBox(width: 8),
                                    _reviewButton(
                                      AppLocalizations.of(
                                        context,
                                      )!.studyQualityEasy,
                                      const Color(0xFF0B194C),
                                      () => _handleReview(currentCard, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _reviewButton(String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
