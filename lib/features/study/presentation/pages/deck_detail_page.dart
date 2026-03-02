import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';

class DeckDetailPage extends StatefulWidget {
  final int deckId;
  const DeckDetailPage({super.key, required this.deckId});

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(LoadFlashcards(widget.deckId));
  }

  void _showAddCardDialog() {
    final qController = TextEditingController();
    final aController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qController,
                decoration: const InputDecoration(labelText: 'Question'),
                minLines: 2,
                maxLines: 4,
              ),
              TextField(
                controller: aController,
                decoration: const InputDecoration(labelText: 'Answer'),
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (qController.text.trim().isNotEmpty &&
                    aController.text.trim().isNotEmpty) {
                  context.read<FlashcardBloc>().add(
                    CreateFlashcard(
                      widget.deckId,
                      qController.text.trim(),
                      aController.text.trim(),
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deck Flashcards')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/study/${widget.deckId}/session');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Start Study Session',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state is FlashcardLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is FlashcardError)
                  return Center(child: Text(state.message));
                if (state is FlashcardLoaded) {
                  if (state.flashcards.isEmpty)
                    return const Center(child: Text('No cards yet.'));
                  return ListView.builder(
                    itemCount: state.flashcards.length,
                    itemBuilder: (context, index) {
                      final card = state.flashcards[index];
                      return ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: Text(
                          card.question,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          card.answer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<FlashcardBloc>().add(
                              DeleteFlashcard(card.id),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
