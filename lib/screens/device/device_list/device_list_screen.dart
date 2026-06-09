import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/screens/device/device_list/bloc/device_list_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_list/widget/bulk_lifecycle_dialog.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DeviceListBloc>().add(const DeviceListEvent.started());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search by Serial Number",
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                context.read<DeviceListBloc>().add(
                  DeviceListEvent.onSearch(value.trim()),
                );
              },
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
                child: BlocBuilder<DeviceListBloc, DeviceListState>(
                  builder: (context, state) {
                    final isAllSelected =
                        state.devices.isNotEmpty &&
                        state.devices.every(
                          (d) => state.selectedIds.contains(d.id),
                        );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.selectedIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Text(
                                  '(${state.selectedIds.length}/${state.devices.length}) selected',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => BulkLifecycleDialog(
                                        selectedIds: state.selectedIds,
                                      ),
                                    );
                                    if (result == true && context.mounted) {
                                      context.read<DeviceListBloc>().add(
                                        const DeviceListEvent.started(),
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.settings, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "Bulk Lifecycle Event",
                                        style: textTheme.bodyLarge?.medium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Header row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isAllSelected,
                                        onChanged: (_) => context
                                            .read<DeviceListBloc>()
                                            .add(const DeviceListEvent.selectAll()),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('Select all'),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Serial Number',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Model',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Location',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
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
    );
  }

  Widget _buildList(BuildContext context, DeviceListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          state.errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (state.devices.isEmpty) {
      return const Center(child: Text("No devices found."));
    }
    return ListView.separated(
      itemCount: state.devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final device = state.devices[index];
        final isSelected = state.selectedIds.contains(device.id);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: neutral300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => context.read<DeviceListBloc>().add(
                      DeviceListEvent.selectDevice(device.id),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 2, child: Text(device.serialNumber)),
              Expanded(flex: 2, child: Text(device.modelType ?? '-')),
              Expanded(flex: 2, child: Text(device.status ?? '-')),
              Expanded(flex: 2, child: Text(device.currentLocation ?? '-')),
            ],
          ),
        );
      },
    );
  }
}
