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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.decksTitle),
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
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      context.push('/study/${deck.id}');
                    },
                    onLongPress: () {
                      context.read<DeckBloc>().add(DeleteDeck(deck.id));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deck.name,
                            style: Theme.of(context).textTheme.titleLarge,
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
