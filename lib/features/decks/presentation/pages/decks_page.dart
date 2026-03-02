import 'package:flutter/material.dart';
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
          title: const Text('Novo Deck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do Deck'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
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
              child: const Text('Criar'),
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
        title: const Text('Meus Decks'),
        actions: [
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
              return const Center(child: Text('Nenhum deck ainda. Crie um!'));
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
