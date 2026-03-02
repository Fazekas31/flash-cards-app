import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_card/flip_card.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../../domain/models/flashcard.dart';
import 'package:go_router/go_router.dart';

class StudySessionPage extends StatefulWidget {
  final int deckId;
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
                              child: Text(
                                currentCard.question,
                                style: Theme.of(context)
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
                                    child: Text(
                                      currentCard.answer,
                                      style: Theme.of(context)
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
                                      () => _reviewCard(currentCard, 0),
                                    ),
                                    const SizedBox(width: 8),
                                    _reviewButton(
                                      AppLocalizations.of(
                                        context,
                                      )!.studyQualityHard,
                                      const Color(0xFFFFB470),
                                      () => _reviewCard(currentCard, 1),
                                    ),
                                    const SizedBox(width: 8),
                                    _reviewButton(
                                      AppLocalizations.of(
                                        context,
                                      )!.studyQualityGood,
                                      const Color(0xFF76E0A3),
                                      () => _reviewCard(currentCard, 2),
                                    ),
                                    const SizedBox(width: 8),
                                    _reviewButton(
                                      AppLocalizations.of(
                                        context,
                                      )!.studyQualityEasy,
                                      const Color(0xFF0B194C),
                                      () => _reviewCard(currentCard, 3),
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
