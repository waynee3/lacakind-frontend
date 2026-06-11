import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/device/device_detail/bloc/device_detail_bloc.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/widgets/status_widget.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String serialNumber;

  const DeviceDetailScreen({
    super.key,
    required this.serialNumber,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late final DeviceDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DeviceDetailBloc()
      ..add(DeviceDetailEvent.started(widget.serialNumber));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: _bloc,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: BlocBuilder<DeviceDetailBloc, DeviceDetailState>(
            builder: (context, state) {
              // Still fetching (refresh / deep-link)
              if (state.isLoading && state.device == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Fetch failed
                if (state.device == null && state.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: Colors.red.shade600),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () =>
                              DeviceListRoute().go(context),
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
                              Text(
                                device.serialNumber,
                                style: textTheme.titleLarge?.semibold,
                              ),
                              if (device.modelType != null)
                                Text(
                                  device.modelType!,
                                  style: textTheme.bodyMedium?.withColor(
                                    neutral600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (device.status != null)
                          StatusChip(status: device.status!),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () =>
                              DeviceEditRoute(serialNumber: device.serialNumber)
                                  .go(context),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
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
                                  value: device.currentLocation,
                                ),
                                _DetailItem(
                                  label: 'Supplier',
                                  value: device.supplier,
                                ),
                                _DetailItem(
                                  label: 'Batch Number',
                                  value: device.batchNumber,
                                ),
                                _DetailItem(
                                  label: 'Cost',
                                  value: device.cost != null
                                      ? '\$${device.cost!.toStringAsFixed(2)}'
                                      : null,
                                ),
                                _DetailItem(
                                  label: 'Purchase Date',
                                  value: _fmtDate(device.purchaseDate),
                                ),
                                _DetailItem(
                                  label: 'Activation Date',
                                  value: _fmtDate(device.activationDate),
                                ),
                                _DetailItem(
                                  label: 'Warranty Expiry',
                                  value: _fmtDate(device.warrantyExpiry),
                                ),
                                _DetailItem(
                                  label: 'Client ID',
                                  value: device.clientId,
                                ),
                                _DetailItem(
                                  label: 'Created By',
                                  value: device.createdBy,
                                ),
                                _DetailItem(
                                  label: 'Updated By',
                                  value: device.updatedBy,
                                ),
                                _DetailItem(
                                  label: 'Created At',
                                  value: _fmtDateTime(device.createdAt),
                                ),
                                _DetailItem(
                                  label: 'Updated At',
                                  value: _fmtDateTime(device.updatedAt),
                                ),
                              ],
                            ),

                            // ── Lifecycle events ──────────────────
                            if (device.lifecycleEvents.isNotEmpty) ...[
                              const SizedBox(height: 32),
                              Text(
                                'Lifecycle Events',
                                style: textTheme.titleSmall?.semibold,
                              ),
                              const SizedBox(height: 12),
                              ...device.lifecycleEvents.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: neutral400,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.eventType,
                                              style:
                                                  textTheme.bodySmall?.semibold,
                                            ),
                                            if (e.description != null)
                                              Text(
                                                e.description!,
                                                style: textTheme.bodySmall
                                                    ?.withColor(neutral600),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _fmtDateTime(e.timestamp) ?? '',
                                        style: textTheme.bodySmall?.withColor(
                                          neutral500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            if (state.errorMessage.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                state.errorMessage,
                                style: textTheme.bodySmall?.withColor(
                                  Colors.red.shade600,
                                ),
                              ),
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

  String? _fmtDate(DateTime? d) => d == null
      ? null
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String? _fmtDateTime(DateTime? d) => d == null
      ? null
      : '${_fmtDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

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