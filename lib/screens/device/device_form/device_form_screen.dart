import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/data/enums/device_status.dart';
import 'package:lacakind_frontend/data/models/device_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/device/device_form/bloc/device_form_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_form/widget/device_form_date_picker_row.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

class DeviceFormScreen extends StatefulWidget {
  /// Null = add mode. Non-null = edit mode, pre-filled from this object.
  final DeviceModel? device;

  const DeviceFormScreen({super.key, this.device});

  @override
  State<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends State<DeviceFormScreen> {
  late final DeviceFormBloc _bloc;
  late final TextEditingController _serialCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _supplierCtrl;
  late final TextEditingController _batchCtrl;
  late final TextEditingController _costCtrl;

  @override
  void initState() {
    super.initState();
    _bloc = DeviceFormBloc();

    final d = widget.device;
    // Pre-fill controllers immediately from the passed device — no waiting
    _serialCtrl   = TextEditingController(text: d?.serialNumber ?? '');
    _modelCtrl    = TextEditingController(text: d?.modelType ?? '');
    _locationCtrl = TextEditingController(text: d?.currentLocation ?? '');
    _supplierCtrl = TextEditingController(text: d?.supplier ?? '');
    _batchCtrl    = TextEditingController(text: d?.batchNumber ?? '');
    _costCtrl     = TextEditingController(text: d?.cost?.toString() ?? '');

    if (d != null) {
      _bloc.add(DeviceFormEvent.startedEdit(d));
    } else {
      _bloc.add(const DeviceFormEvent.started());
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _serialCtrl.dispose();
    _modelCtrl.dispose();
    _locationCtrl.dispose();
    _supplierCtrl.dispose();
    _batchCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEdit = widget.device != null;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<DeviceFormBloc, DeviceFormState>(
        listener: (context, state) {
          if (state.isSuccess) {
            if (isEdit && state.savedDevice != null) {
              DeviceDetailRoute(
                id: state.savedDevice!.id,
                $extra: state.savedDevice,
              ).go(context);
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title bar ──────────────────────────────────
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

                    // ── Form body ──────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
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
                                    color: Colors.red.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  state.errorMessage,
                                  style: textTheme.bodyMedium?.withColor(
                                    Colors.red.shade700,
                                  ),
                                ),
                              ),

                            LabelTextField(
                              label: 'Serial Number *',
                              hintText: 'e.g. SN-0001',
                              controller: _serialCtrl,
                              enabled: !isEdit,
                              onChanged: (v) => _bloc.add(
                                DeviceFormEvent.serialNumberChanged(v),
                              ),
                            ),
                            const SizedBox(height: 16),

                            LabelTextField(
                              label: 'Model Type',
                              hintText: 'e.g. GPS-Tracker-v2',
                              controller: _modelCtrl,
                              onChanged: (v) => _bloc.add(
                                DeviceFormEvent.modelTypeChanged(v),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Status dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status', style: textTheme.bodyMedium),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<DeviceStatus>(
                                  value: state.status,
                                  hint: const Text('Select status'),
                                  decoration: const InputDecoration(),
                                  items: DeviceStatus.values
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s.label),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => _bloc.add(
                                    DeviceFormEvent.statusChanged(v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            LabelTextField(
                              label: 'Current Location',
                              hintText: 'e.g. Main Warehouse',
                              controller: _locationCtrl,
                              onChanged: (v) => _bloc.add(
                                DeviceFormEvent.locationChanged(v),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: LabelTextField(
                                    label: 'Supplier',
                                    hintText: 'Supplier name',
                                    controller: _supplierCtrl,
                                    onChanged: (v) => _bloc.add(
                                      DeviceFormEvent.supplierChanged(v),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: LabelTextField(
                                    label: 'Batch Number',
                                    hintText: 'Batch ID',
                                    controller: _batchCtrl,
                                    onChanged: (v) => _bloc.add(
                                      DeviceFormEvent.batchNumberChanged(v),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            LabelTextField(
                              label: 'Cost (USD)',
                              hintText: '0.00',
                              controller: _costCtrl,
                              onChanged: (v) => _bloc.add(
                                DeviceFormEvent.costChanged(v),
                              ),
                            ),
                            const SizedBox(height: 16),

                            DeviceFormDatePickerRow(),
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
                                      : () => _bloc.add(
                                            const DeviceFormEvent.submitted(),
                                          ),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          isEdit ? 'Save Changes' : 'Add Device',
                                        ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}