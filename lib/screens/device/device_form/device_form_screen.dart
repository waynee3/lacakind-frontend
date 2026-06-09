import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/data/enums/device_status.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/device/device_form/bloc/device_form_bloc.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

class DeviceFormScreen extends StatefulWidget {
  final String? deviceId;

  const DeviceFormScreen({super.key, this.deviceId});

  @override
  State<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends State<DeviceFormScreen> {
  late final TextEditingController _serialCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _supplierCtrl;
  late final TextEditingController _batchCtrl;
  late final TextEditingController _costCtrl;

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _serialCtrl   = TextEditingController();
    _modelCtrl    = TextEditingController();
    _locationCtrl = TextEditingController();
    _supplierCtrl = TextEditingController();
    _batchCtrl    = TextEditingController();
    _costCtrl     = TextEditingController();

    // Kick off the bloc. If edit mode, the bloc fetches the device then
    // populates state; we sync controllers in the builder the first time.
    final bloc = context.read<DeviceFormBloc>();
    if (widget.deviceId != null) {
      bloc.add(DeviceFormEvent.startedEdit(widget.deviceId!));
    } else {
      bloc.add(const DeviceFormEvent.started());
    }
  }

  @override
  void dispose() {
    _serialCtrl.dispose();
    _modelCtrl.dispose();
    _locationCtrl.dispose();
    _supplierCtrl.dispose();
    _batchCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _syncControllers(DeviceFormState state) {
    if (_controllersInitialized) return;
    if (widget.deviceId != null && state.serialNumber.isEmpty) return;
    _controllersInitialized = true;
    _serialCtrl.text   = state.serialNumber;
    _modelCtrl.text    = state.modelType;
    _locationCtrl.text = state.location;
    _supplierCtrl.text = state.supplier;
    _batchCtrl.text    = state.batchNumber;
    _costCtrl.text     = state.cost;
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initial,
    void Function(DateTime?) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEdit = widget.deviceId != null;

    return BlocListener<DeviceFormBloc, DeviceFormState>(
      listener: (context, state) {
        if (state.isSuccess) {
          // Go back to detail if editing, or list if adding
          if (isEdit && state.editingId != null) {
            DeviceDetailRoute(id: state.editingId!).go(context);
          } else {
            DeviceListRoute().go(context);
          }
        }
      },
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: BlocBuilder<DeviceFormBloc, DeviceFormState>(
            builder: (context, state) {
              // Sync controllers once data is ready (edit mode)
              _syncControllers(state);

              if (state.isLoading && state.serialNumber.isEmpty && isEdit) {
                return const Center(child: CircularProgressIndicator());
              }

              final bloc = context.read<DeviceFormBloc>();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title bar ──────────────────────────────────────
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'Edit Device' : 'Add Device',
                        style: textTheme.titleLarge?.semibold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Form ───────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Error banner
                            if (state.errorMessage.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(
                                      color: Colors.red.shade200),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  state.errorMessage,
                                  style: textTheme.bodyMedium
                                      ?.withColor(Colors.red.shade700),
                                ),
                              ),

                            LabelTextField(
                              label: 'Serial Number *',
                              hintText: 'e.g. SN-0001',
                              controller: _serialCtrl,
                              enabled: !isEdit,
                              onChanged: (v) => bloc.add(
                                  DeviceFormEvent.serialNumberChanged(v)),
                            ),
                            const SizedBox(height: 16),

                            LabelTextField(
                              label: 'Model Type',
                              hintText: 'e.g. GPS-Tracker-v2',
                              controller: _modelCtrl,
                              onChanged: (v) => bloc
                                  .add(DeviceFormEvent.modelTypeChanged(v)),
                            ),
                            const SizedBox(height: 16),

                            // Status dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status',
                                    style: textTheme.bodyMedium),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<DeviceStatus>(
                                  initialValue: state.status,
                                  hint: const Text('Select status'),
                                  decoration: const InputDecoration(),
                                  items: DeviceStatus.values
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s.label),
                                          ))
                                      .toList(),
                                  onChanged: (v) => bloc.add(
                                      DeviceFormEvent.statusChanged(v)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            LabelTextField(
                              label: 'Current Location',
                              hintText: 'e.g. Main Warehouse',
                              controller: _locationCtrl,
                              onChanged: (v) => bloc
                                  .add(DeviceFormEvent.locationChanged(v)),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: LabelTextField(
                                    label: 'Supplier',
                                    hintText: 'Supplier name',
                                    controller: _supplierCtrl,
                                    onChanged: (v) => bloc.add(
                                        DeviceFormEvent.supplierChanged(v)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: LabelTextField(
                                    label: 'Batch Number',
                                    hintText: 'Batch ID',
                                    controller: _batchCtrl,
                                    onChanged: (v) => bloc.add(
                                        DeviceFormEvent.batchNumberChanged(v)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            LabelTextField(
                              label: 'Cost (USD)',
                              hintText: '0.00',
                              controller: _costCtrl,
                              onChanged: (v) =>
                                  bloc.add(DeviceFormEvent.costChanged(v)),
                            ),
                            const SizedBox(height: 16),

                            // Date pickers row
                            Row(
                              children: [
                                Expanded(
                                  child: _DatePickerField(
                                    label: 'Purchase Date',
                                    value: state.purchaseDate,
                                    onTap: () => _pickDate(
                                      context,
                                      state.purchaseDate,
                                      (d) => bloc.add(
                                          DeviceFormEvent.purchaseDateChanged(
                                              d)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _DatePickerField(
                                    label: 'Activation Date',
                                    value: state.activationDate,
                                    onTap: () => _pickDate(
                                      context,
                                      state.activationDate,
                                      (d) => bloc.add(
                                          DeviceFormEvent.activationDateChanged(
                                              d)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _DatePickerField(
                                    label: 'Warranty Expiry',
                                    value: state.warrantyExpiry,
                                    onTap: () => _pickDate(
                                      context,
                                      state.warrantyExpiry,
                                      (d) => bloc.add(
                                          DeviceFormEvent.warrantyExpiryChanged(
                                              d)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () => context.pop(),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () => bloc.add(
                                          const DeviceFormEvent.submitted()),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(isEdit
                                          ? 'Save Changes'
                                          : 'Add Device'),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final display = value != null
        ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
        : 'Not set';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    style: textTheme.bodyMedium?.copyWith(
                        color: value == null ? Colors.grey : null),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}