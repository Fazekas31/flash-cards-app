import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_card/flip_card.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../../domain/models/flashcard.dart';

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
      appBar: AppBar(title: const Text('Study Session')),
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
                    const Text(
                      'No more cards to study today! 🎉',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Deck'),
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
                    'Cards remaining: ${state.studyCards.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: FlipCard(
                      key: cardKey,
                      flipOnTouch: true,
                      front: Card(
                        elevation: 8,
                        color: Theme.of(context).cardColor,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              currentCard.question,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      back: Card(
                        elevation: 8,
                        color: Colors.blue.shade50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    currentCard.answer,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _reviewButton(
                                    'Novamente',
                                    Colors.red,
                                    () => _reviewCard(currentCard, 0),
                                  ),
                                  _reviewButton(
                                    'Difícil',
                                    Colors.orange,
                                    () => _reviewCard(currentCard, 1),
                                  ),
                                  _reviewButton(
                                    'Bom',
                                    Colors.green,
                                    () => _reviewCard(currentCard, 2),
                                  ),
                                  _reviewButton(
                                    'Fácil',
                                    Colors.blue,
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
