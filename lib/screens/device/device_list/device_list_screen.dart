import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/device/device_list/bloc/device_list_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_list/widget/bulk_import_review_dialog.dart';
import 'package:lacakind_frontend/screens/device/device_list/widget/bulk_lifecycle_dialog.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/widgets/status_widget.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<DeviceListBloc>().add(const DeviceListEvent.started());
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
      context.read<DeviceListBloc>().add(const DeviceListEvent.loadMore());
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    if (!context.mounted) return;

    final confirmed = await BulkImportReviewDialog.show(
      context,
      csvBytes: file.bytes!,
    );

    if (confirmed == true && context.mounted) {
      context.read<DeviceListBloc>().add(
        DeviceListEvent.importDevices(
          filePath: file.path,
          fileBytes: file.bytes,
          fileName: file.name,
        ),
      );
    }
  }

  void _showImportErrorsDialog(BuildContext ctx, List<String> errors) {
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Import Row Errors'),
        content: SizedBox(
          width: 480,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errors[i])),
                ],
              ),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<DeviceListBloc, DeviceListState>(
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
        if (state.importErrors.isNotEmpty) {
          _showImportErrorsDialog(context, state.importErrors);
        }
      },
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Devices', style: textTheme.titleLarge?.semibold),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by Serial Number',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) => context
                          .read<DeviceListBloc>()
                          .add(DeviceListEvent.onSearch(value.trim())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleImport(context),
                      icon: const Icon(Icons.upload_file_outlined, size: 18),
                      label: Text(
                        'Import CSV',
                        style: textTheme.bodyLarge?.medium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: () => DeviceNewRoute().go(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Device'),
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
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final serials = state.devices
                                          .where(
                                            (d) => state.selectedIds.contains(
                                              d.id,
                                            ),
                                          )
                                          .map((d) => d.serialNumber)
                                          .toList();
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => BulkLifecycleDialog(
                                          serialNumbers: serials,
                                        ),
                                      );
                                      if (result == true && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Lifecycle event applied to ${serials.length} device${serials.length == 1 ? '' : 's'}',
                                            ),
                                            backgroundColor:
                                                Colors.green.shade700,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        context.read<DeviceListBloc>().add(
                                          const DeviceListEvent.started(),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.settings, size: 16),
                                    label: Text(
                                      'Bulk Lifecycle Event',
                                      style: textTheme.bodyLarge?.medium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade600,
                                      side: BorderSide(
                                        color: Colors.red.shade300,
                                      ),
                                    ),

                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text('Delete Devices'),
                                          content: Text(
                                            'Are you sure you want to delete ${state.selectedIds.length} device${state.selectedIds.length == 1 ? '' : 's'}? '
                                            'This cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                dialogContext,
                                              ).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () => Navigator.of(
                                                dialogContext,
                                              ).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true &&
                                          context.mounted) {
                                        context.read<DeviceListBloc>().add(
                                          const DeviceListEvent.bulkDelete(),
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                    ),
                                    label: Text(
                                      'Delete Selected',
                                      style: textTheme.bodyLarge?.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isAllSelected,
                                        onChanged: (_) =>
                                            context.read<DeviceListBloc>().add(
                                              const DeviceListEvent.selectAll(),
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('Select all'),
                                    ],
                                  ),
                                ),
                                _HeaderCell('Serial Number'),
                                _HeaderCell('Model'),
                                _HeaderCell('Status'),
                                _HeaderCell('Location'),
                                const SizedBox(width: 48),
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

  Widget _buildList(BuildContext context, DeviceListState state) {
    if (state.isLoading && state.devices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.devices.isEmpty) {
      return const Center(child: Text('No devices found.'));
    }

    final itemCount = state.devices.length + (state.hasMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      itemCount: itemCount,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == state.devices.length) {
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

        final device = state.devices[index];
        final isSelected = state.selectedIds.contains(device.id);

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              DeviceDetailRoute(serialNumber: device.serialNumber).go(context),
          child: Container(
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
                Expanded(flex: 2, child: Text(device.modelType ?? '—')),
                Expanded(
                  flex: 2,
                  child: device.status != null
                      ? StatusChip(status: device.status!)
                      : const Text('—'),
                ),
                Expanded(flex: 2, child: Text(device.currentLocation ?? '—')),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Edit',
                    onPressed: () => DeviceEditRoute(
                      serialNumber: device.serialNumber,
                    ).go(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) => Expanded(
    flex: 2,
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}
