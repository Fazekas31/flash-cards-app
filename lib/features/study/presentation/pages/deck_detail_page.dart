import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../../../../core/widgets/linkable_text_widget.dart';
import '../../../../core/services/gemini_ai_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../domain/models/flashcard.dart';

class DeckDetailPage extends StatefulWidget {
  final String deckId;
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

  void _showEditCardDialog(Flashcard card) {
    final qController = TextEditingController(text: card.question);
    final aController = TextEditingController(text: card.answer);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.flashcardNew
                .replaceAll('Novo', 'Editar')
                .replaceAll('New', 'Edit'),
          ),
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
                  card.question = qController.text.trim();
                  card.answer = aController.text.trim();
                  context.read<FlashcardBloc>().add(UpdateFlashcard(card));
                }
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.flashcardAdd
                    .replaceAll('Adicionar', 'Salvar')
                    .replaceAll('Add', 'Save'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGenerateCardsBottomSheet() {
    final textController = TextEditingController();
    bool isLoading = false;
    String? attachedFileName;
    Uint8List? attachedFileBytes;
    String? attachedMimeType;

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
                  Text(
                    AppLocalizations.of(context)!.magicGeneratorTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B194C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.magicGeneratorSubtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.magicGeneratorInputHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (image != null) {
                                  final bytes = await image.readAsBytes();
                                  setState(() {
                                    attachedFileName = image.name;
                                    attachedFileBytes = bytes;
                                    attachedMimeType = 'image/jpeg';
                                  });
                                }
                              },
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          AppLocalizations.of(context)!.magicGeneratorCamera,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F0F0),
                          foregroundColor: const Color(0xFF0B194C),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: [
                                        'pdf',
                                        'png',
                                        'jpg',
                                        'jpeg',
                                      ],
                                      withData: true,
                                    );
                                if (result != null) {
                                  final file = result.files.first;
                                  final bytes =
                                      file.bytes ??
                                      await File(file.path!).readAsBytes();
                                  String mime = 'application/pdf';
                                  if (file.extension?.toLowerCase() == 'png')
                                    mime = 'image/png';
                                  if (file.extension?.toLowerCase() == 'jpg' ||
                                      file.extension?.toLowerCase() == 'jpeg')
                                    mime = 'image/jpeg';

                                  setState(() {
                                    attachedFileName = file.name;
                                    attachedFileBytes = bytes;
                                    attachedMimeType = mime;
                                  });
                                }
                              },
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          )!.magicGeneratorAttachment,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F0F0),
                          foregroundColor: const Color(0xFF0B194C),
                        ),
                      ),
                    ],
                  ),
                  if (attachedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        '${AppLocalizations.of(context)!.magicGeneratorAttachmentReady} $attachedFileName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4DB97F),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (textController.text.trim().isEmpty &&
                            attachedFileBytes == null)
                          return;
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final cards = await GeminiAiService()
                              .generateFlashcards(
                                contextText: textController.text.trim(),
                                fileBytes: attachedFileBytes,
                                mimeType: attachedMimeType,
                                languageCode: Localizations.localeOf(
                                  context,
                                ).languageCode,
                              );

                          if (mounted) {
                            context.read<FlashcardBloc>().add(
                              CreateFlashcardsBulk(widget.deckId, cards),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.magicGeneratorSuccess(cards.length),
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
                      label: Text(
                        AppLocalizations.of(context)!.magicGeneratorButton,
                      ),
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      _showEditCardDialog(card);
                                    },
                                  ),
                                  IconButton(
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
                                ],
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
