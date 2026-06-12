import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/contract/contract_list/bloc/contract_list_bloc.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({super.key});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ContractListBloc>().add(const ContractListEvent.started());
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
      context.read<ContractListBloc>().add(const ContractListEvent.loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ContractListBloc, ContractListState>(
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
                        hintText: 'Search by contract name',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) => context
                          .read<ContractListBloc>()
                          .add(ContractListEvent.onSearch(value.trim())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: () {
                        // ContractNewRoute().go(context);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add contract'),
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
                  child: BlocBuilder<ContractListBloc, ContractListState>(
                    buildWhen: (previous, current) =>
                        previous.contracts != current.contracts,
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Contract id",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
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
                                    "Type",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Period",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Status",
                                    style: textTheme.bodyMedium.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Payment Status",
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

  Widget _buildList(BuildContext context, ContractListState state) {
    if (state.isLoading && state.contracts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.contracts.isEmpty) {
      return const Center(child: Text('No contracts found.'));
    }

    final itemCount = state.contracts.length + (state.hasMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      itemCount: itemCount,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == state.contracts.length) {
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

        final contract = state.contracts[index];

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => ContractEditRoute(id: contract.id).go(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: neutral300),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(contract.contractId)),
                Expanded(flex: 1, child: Text(contract.contractType)),
                Expanded(
                  flex: 1,
                  child: Text("${contract.startDate} - ${contract.endDate}"),
                ),
                Expanded(flex: 2, child: Text(contract.status)),
                Expanded(flex: 1, child: Text(contract.paymentStatus)),
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit',
                        onPressed: () =>
                            ContractEditRoute(id: contract.id).go(context),
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
                              title: const Text('Delete contract'),
                              content: Text(
                                'Are you sure you want to delete ${contract.contractId}? '
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
                            context.read<ContractListBloc>().add(
                              ContractListEvent.deleteContract(contract.id),
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
