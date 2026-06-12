import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/data/models/client_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/contract/contract_form/bloc/contract_form_bloc.dart';
import 'package:lacakind_frontend/widgets/label_dropdown.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

const _contractTypes   = ['Rental', 'Lease', 'Sale'];
const _contractStatuses = ['Active', 'Expired', 'Terminated'];
const _paymentStatuses  = ['Not Paid', 'Paid', 'Overdue', 'Partial'];

class ContractFormScreen extends StatefulWidget {
  final String? contractId;
  const ContractFormScreen({super.key, this.contractId});

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  late final ContractFormBloc _bloc;
  final _contractIdCtrl = TextEditingController();
  final _notesCtrl      = TextEditingController();
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    _bloc = ContractFormBloc();
    if (widget.contractId != null) {
      _bloc.add(ContractFormEvent.startedEdit(widget.contractId!));
    } else {
      _bloc.add(const ContractFormEvent.started());
      _filled = true;
    }
  }

  void _fill(ContractFormState s) {
    if (_filled) return;
    if (s.editingId == null) return;
    _filled = true;
    _contractIdCtrl.text = s.contractId;
    _notesCtrl.text      = s.notes;
  }

  @override
  void dispose() {
    _bloc.close();
    _contractIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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
    final isEdit    = widget.contractId != null;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ContractFormBloc, ContractFormState>(
        listener: (context, state) {
          if (state.isSuccess) ContractsRoute().go(context);
        },
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: BlocBuilder<ContractFormBloc, ContractFormState>(
              builder: (context, state) {
                _fill(state);

                if (state.isLoading && isEdit && state.editingId == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'Edit Contract' : 'New Contract',
                        style: textTheme.titleLarge?.semibold,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                child: Text(state.errorMessage,
                                    style: textTheme.bodyMedium
                                        ?.withColor(Colors.red.shade700)),
                              ),
                            if (isEdit && state.contractRef.isNotEmpty) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Contract Ref',
                                      style: textTheme.bodyMedium),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(state.contractRef,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                    fontFamily: 'monospace',
                                                    fontWeight:
                                                        FontWeight.w600)),
                                        const SizedBox(width: 8),
                                        Text('(auto-generated)',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                    color: Colors
                                                        .grey.shade500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            LabelTextField(
                              label: 'Contract ID *',
                              hintText: 'e.g. CTR-2025-001',
                              controller: _contractIdCtrl,
                              enabled: !isEdit,
                              onChanged: (v) => _bloc.add(
                                  ContractFormEvent.contractIdChanged(v)),
                            ),
                            const SizedBox(height: 16),
                            LabelDropdown<ClientModel>(
                              label: 'Client *',
                              hintText: state.clients.isEmpty
                                  ? 'Loading clients…'
                                  : 'Select client',
                              value: state.selectedClient,
                              items: state.clients
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                            '${c.name} (${c.location})'),
                                      ))
                                  .toList(),
                              onChanged: (v) => _bloc.add(
                                  ContractFormEvent.clientChanged(v)),
                            ),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                child: LabelDropdown<String>(
                                  label: 'Contract Type *',
                                  hintText: 'Select type',
                                  value: state.contractType,
                                  items: _contractTypes
                                      .map((t) => DropdownMenuItem(
                                          value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (v) => _bloc.add(
                                      ContractFormEvent.contractTypeChanged(
                                          v ?? 'Rental')),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: LabelDropdown<String>(
                                  label: 'Status',
                                  hintText: 'Select status',
                                  value: state.status,
                                  items: _contractStatuses
                                      .map((s) => DropdownMenuItem(
                                          value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) => _bloc.add(
                                      ContractFormEvent.statusChanged(
                                          v ?? 'Active')),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
                        
                            // ── Payment status ────────────────────────
                            LabelDropdown<String>(
                              label: 'Payment Status',
                              hintText: 'Select payment status',
                              value: state.paymentStatus,
                              items: _paymentStatuses
                                  .map((p) => DropdownMenuItem(
                                      value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (v) => _bloc.add(
                                  ContractFormEvent.paymentStatusChanged(
                                      v ?? 'Not Paid')),
                            ),
                            const SizedBox(height: 16),
                        
                            // ── Start / End date ──────────────────────
                            Row(children: [
                              Expanded(
                                child: _DateField(
                                  label: 'Start Date *',
                                  value: state.startDate,
                                  onTap: () => _pickDate(
                                    context,
                                    state.startDate,
                                    (d) {
                                      if (d != null) {
                                        _bloc.add(
                                            ContractFormEvent
                                                .startDateChanged(d));
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _DateField(
                                  label: 'End Date',
                                  value: state.endDate,
                                  onTap: () => _pickDate(
                                    context,
                                    state.endDate,
                                    (d) => _bloc.add(
                                        ContractFormEvent.endDateChanged(d)),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
                        
                            // ── Notes ────────────────────────────────
                            LabelTextField(
                              label: 'Notes',
                              hintText: 'Optional',
                              controller: _notesCtrl,
                              onChanged: (v) =>
                                  _bloc.add(ContractFormEvent.notesChanged(v)),
                            ),
                            const SizedBox(height: 32),
                        
                            // ── Actions ───────────────────────────────
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
                                          const ContractFormEvent.submitted()),
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
                                          isEdit ? 'Save Changes' : 'Create Contract'),
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DateField({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fmt = value != null
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
                  child: Text(fmt,
                      style: textTheme.bodyMedium?.copyWith(
                        color: value == null ? Colors.grey : null,
                      )),
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