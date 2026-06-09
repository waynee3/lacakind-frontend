import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/device/device_detail/bloc/device_detail_bloc.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/widgets/status_widget.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;
  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<DeviceDetailBloc, DeviceDetailState>(
      listener: (context, state) {
        if (state.isDeleted) DeviceListRoute().go(context);
      },
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: BlocBuilder<DeviceDetailBloc, DeviceDetailState>(
            builder: (context, state) {
              // Loading — no device yet
              if (state.isLoading && state.device == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Fatal fetch error
              if (state.errorMessage.isNotEmpty && state.device == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage,
                          style: textTheme.bodyMedium
                              ?.withColor(Colors.red.shade600)),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => DeviceListRoute().go(context),
                        child: const Text('Back to list'),
                      ),
                    ],
                  ),
                );
              }

              final device = state.device!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => DeviceListRoute().go(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(device.serialNumber,
                                style: textTheme.titleLarge?.semibold),
                            if (device.modelType != null)
                              Text(device.modelType!,
                                  style: textTheme.bodyMedium
                                      ?.withColor(neutral600)),
                          ],
                        ),
                      ),
                      if (device.status != null)
                        StatusChip(status: device.status!),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () =>
                            DeviceEditRoute(id: device.id).go(context),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade300),
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Details grid ──────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            runSpacing: 20,
                            spacing: 32,
                            children: [
                              _DetailItem(
                                  label: 'Location',
                                  value: device.currentLocation),
                              _DetailItem(
                                  label: 'Supplier', value: device.supplier),
                              _DetailItem(
                                  label: 'Batch Number',
                                  value: device.batchNumber),
                              _DetailItem(
                                label: 'Cost',
                                value: device.cost != null
                                    ? '\$${device.cost!.toStringAsFixed(2)}'
                                    : null,
                              ),
                              _DetailItem(
                                  label: 'Purchase Date',
                                  value: _fmtDate(device.purchaseDate)),
                              _DetailItem(
                                  label: 'Activation Date',
                                  value: _fmtDate(device.activationDate)),
                              _DetailItem(
                                  label: 'Warranty Expiry',
                                  value: _fmtDate(device.warrantyExpiry)),
                              _DetailItem(
                                  label: 'Client ID', value: device.clientId),
                              _DetailItem(
                                  label: 'Created By',
                                  value: device.createdBy),
                              _DetailItem(
                                  label: 'Updated By',
                                  value: device.updatedBy),
                              _DetailItem(
                                  label: 'Created At',
                                  value: _fmtDateTime(device.createdAt)),
                              _DetailItem(
                                  label: 'Updated At',
                                  value: _fmtDateTime(device.updatedAt)),
                            ],
                          ),

                          // ── Lifecycle events ──────────────────
                          if (device.lifecycleEvents.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            Text('Lifecycle Events',
                                style: textTheme.titleSmall?.semibold),
                            const SizedBox(height: 12),
                            ...device.lifecycleEvents.map((e) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 8, color: neutral400),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(e.eventType,
                                                style: textTheme.bodySmall
                                                    ?.semibold),
                                            if (e.description != null)
                                              Text(e.description!,
                                                  style: textTheme.bodySmall
                                                      ?.withColor(neutral600)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _fmtDateTime(e.timestamp) ?? '',
                                        style: textTheme.bodySmall
                                            ?.withColor(neutral500),
                                      ),
                                    ],
                                  ),
                                )),
                          ],

                          if (state.errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(state.errorMessage,
                                style: textTheme.bodySmall
                                    ?.withColor(Colors.red.shade600)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Device'),
        content: const Text(
            'Are you sure you want to delete this device? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<DeviceDetailBloc>()
          .add(const DeviceDetailEvent.deleteRequested());
    }
  }

  String? _fmtDate(DateTime? d) => d == null
      ? null
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String? _fmtDateTime(DateTime? d) =>
      d == null ? null : '${_fmtDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _DetailItem extends StatelessWidget {
  final String label;
  final String? value;
  const _DetailItem({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall?.withColor(neutral500)),
          const SizedBox(height: 2),
          Text(value ?? '—', style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

