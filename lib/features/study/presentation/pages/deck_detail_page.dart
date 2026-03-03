import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../../../../core/widgets/linkable_text_widget.dart';
import '../../../../core/services/gemini_ai_service.dart';

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
          title: Text(AppLocalizations.of(context)!.flashcardNew),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.flashcardQuestion,
                ),
                minLines: 2,
                maxLines: 4,
              ),
              TextField(
                controller: aController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.flashcardAnswer,
                ),
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.deckCancel),
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
              child: Text(AppLocalizations.of(context)!.flashcardAdd),
            ),
          ],
        );
      },
    );
  }

  void _showGenerateCardsBottomSheet() {
    final textController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Gerador Mágico (IA) ✨',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B194C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cole um resumo de anotações ou parte do texto de um PDF. O Gemini irá dissecar o conhecimento e gerar cartões de repetição!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          'Ex: "A fotossíntese é o processo biológico onde a planta..."\\nCole o trecho completo aqui.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (textController.text.trim().isEmpty) return;
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final cards = await GeminiAiService()
                              .generateFlashcards(textController.text.trim());

                          if (mounted) {
                            context.read<FlashcardBloc>().add(
                              CreateFlashcardsBulk(widget.deckId, cards),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '⚡ \${cards.length} cartões gerados com sucesso!',
                                ),
                                backgroundColor: const Color(0xFF76E0A3),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Gerar Cartões Imediatamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B194C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  const SizedBox(height: 24),
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
        title: Text(AppLocalizations.of(context)!.flashcardsTitle),
      ),
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
                label: Text(
                  AppLocalizations.of(context)!.flashcardsStart,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
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
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.flashcardsEmpty,
                      ),
                    );
                  return ListView.builder(
                    itemCount: state.flashcards.length,
                    itemBuilder: (context, index) {
                      final card = state.flashcards[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              leading: const Icon(
                                Icons.label_outline,
                                color: Color(0xFF0B194C),
                              ),
                              title: LinkableTextWidget(
                                text: card.question,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinkableTextWidget(
                                    text: card.answer,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${AppLocalizations.of(context)!.flashcardsNextReview} ${card.dueDate.day.toString().padLeft(2, '0')}/${card.dueDate.month.toString().padLeft(2, '0')}/${card.dueDate.year}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0B194C),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color(0xFF76E0A3),
                                ),
                                onPressed: () {
                                  context.read<FlashcardBloc>().add(
                                    DeleteFlashcard(card.id),
                                  );
                                },
                              ),
                            ),
                          ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "ai_deck_btn",
            onPressed: _showGenerateCardsBottomSheet,
            backgroundColor: const Color(0xFF0B194C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add_card_btn",
            onPressed: _showAddCardDialog,
            backgroundColor: const Color(0xFF76E0A3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.add, color: Color(0xFF0B194C)),
          ),
        ],
      ),
    );
  }
}
