import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/locale_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/deck_bloc.dart';
import '../bloc/deck_event.dart';
import '../bloc/deck_state.dart';
import '../../../../core/services/sync_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/models/deck.dart';

class DecksPage extends StatefulWidget {
  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  @override
  void initState() {
    super.initState();
    context.read<DeckBloc>().add(LoadDecks());
  }

  void _showCreateDeckDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deckNew),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.deckName,
                ),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.deckDescription,
                ),
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
                if (nameController.text.trim().isNotEmpty) {
                  context.read<DeckBloc>().add(
                    CreateDeck(
                      nameController.text.trim(),
                      descController.text.trim(),
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.deckCreate),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeckDialog(Deck deck) {
    final nameController = TextEditingController(text: deck.name);
    final descController = TextEditingController(text: deck.description ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(
              context,
            )!.deckNew.replaceAll('Novo', 'Editar').replaceAll('New', 'Edit'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.deckName,
                ),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.deckDescription,
                ),
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
                if (nameController.text.trim().isNotEmpty) {
                  deck.name = nameController.text.trim();
                  deck.description = descController.text.trim();
                  context.read<DeckBloc>().add(UpdateDeck(deck));
                }
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.deckCreate
                    .replaceAll('Criar', 'Salvar')
                    .replaceAll('Create', 'Save'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.decksTitle,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              context.read<LocaleCubit>().setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('en', ''),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('pt', ''),
                child: Text('Português'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<SyncService>().sync();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sincronização iniciada...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<DeckBloc, DeckState>(
        builder: (context, state) {
          if (state is DeckLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is DeckError) return Center(child: Text(state.message));
          if (state is DeckLoaded) {
            if (state.decks.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.decksEmpty),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: state.decks.length,
              itemBuilder: (context, index) {
                final deck = state.decks[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      context.push('/study/${deck.id}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  deck.name,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF0B194C),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditDeckDialog(deck);
                                  } else if (value == 'delete') {
                                    context.read<DeckBloc>().add(
                                      DeleteDeck(deck.id),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (deck.description != null)
                            Text(
                              deck.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDeckDialog,
        backgroundColor: const Color(0xFF76E0A3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Color(0xFF0B194C)),
      ),
    );
  }
}
