import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/client/client_list/bloc/client_list_bloc.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ClientListBloc>().add(const ClientListEvent.started());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ClientListBloc>().add(const ClientListEvent.loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ClientListBloc, ClientListState>(
      listener: (context, state) {
        if (state.isSuccess && state.successMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by client name',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) => context
                          .read<ClientListBloc>()
                          .add(ClientListEvent.onSearch(value.trim())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: () => ClientNewRoute().go(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Client'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: neutral300),
                  ),
                  child: BlocBuilder<ClientListBloc, ClientListState>(
                    buildWhen: (previous, current) =>
                        previous.clients != current.clients,
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Client name",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Email",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Phone",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Location",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Contact person",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                const SizedBox(width: 112),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(child: _buildList(context, state)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ClientListState state) {
    if (state.isLoading && state.clients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.clients.isEmpty) {
      return const Center(child: Text('No clients found.'));
    }

    final itemCount = state.clients.length + (state.hasMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      itemCount: itemCount,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == state.clients.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: state.isLoadingMore
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }

        final client = state.clients[index];

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => ClientEditRoute(id: client.id).go(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: neutral300),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(client.name)),
                Expanded(flex: 1, child: Text(client.email)),
                Expanded(flex: 1, child: Text(client.phone)),
                Expanded(flex: 2, child: Text(client.location)),
                Expanded(flex: 1, child: Text(client.contactPerson)),
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit',
                        onPressed: () =>
                            ClientEditRoute(id: client.id).go(context),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 18,
                        ),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Client'),
                              content: Text(
                                'Are you sure you want to delete ${client.name}? '
                                'This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            context.read<ClientListBloc>().add(
                              ClientListEvent.deleteClient(client.id),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
