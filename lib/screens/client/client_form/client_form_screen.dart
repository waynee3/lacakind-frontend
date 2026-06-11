import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/routes/routes.dart';
import 'package:lacakind_frontend/screens/client/client_form/bloc/client_form_bloc.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

class ClientFormScreen extends StatefulWidget {
  final String? clientId;

  const ClientFormScreen({super.key, this.clientId});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  late final ClientFormBloc _bloc;
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _filled = false;

  @override
  void initState() {
    super.initState();
    _bloc = ClientFormBloc();
    if (widget.clientId != null) {
      _bloc.add(ClientFormEvent.startedEdit(widget.clientId!));
    } else {
      _bloc.add(const ClientFormEvent.started());
      _filled = true;
    }
  }

  void _fill(ClientFormState s) {
    if (_filled) return;
    if (s.editingId == null) return;
    _filled = true;
    _nameCtrl.text = s.name;
    _locationCtrl.text = s.location;
    _contactCtrl.text = s.contactPerson;
    _emailCtrl.text = s.email;
    _phoneCtrl.text = s.phone;
    _addressCtrl.text = s.address;
    _notesCtrl.text = s.notes;
  }

  @override
  void dispose() {
    _bloc.close();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEdit = widget.clientId != null;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ClientFormBloc, ClientFormState>(
        listener: (context, state) {
          if (state.isSuccess) ClientListRoute().go(context);
        },
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: BlocBuilder<ClientFormBloc, ClientFormState>(
              builder: (context, state) {
                _fill(state);

                if (state.isLoading && isEdit && state.editingId == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEdit ? 'Edit Client' : 'Add Client',
                          style: textTheme.titleLarge?.semibold,
                        ),
                      ],
                    ),
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
                                  border: Border.all(color: Colors.red.shade200),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  state.errorMessage,
                                  style: textTheme.bodyMedium
                                      ?.withColor(Colors.red.shade700),
                                ),
                              ),
                            LabelTextField(
                              label: 'Name *',
                              hintText: 'Client name',
                              controller: _nameCtrl,
                              onChanged: (v) =>
                                  _bloc.add(ClientFormEvent.nameChanged(v)),
                            ),
                            const SizedBox(height: 16),
                            LabelTextField(
                              label: 'Location *',
                              hintText: 'e.g. Jakarta',
                              controller: _locationCtrl,
                              onChanged: (v) =>
                                  _bloc.add(ClientFormEvent.locationChanged(v)),
                            ),
                            const SizedBox(height: 16),
                            LabelTextField(
                              label: 'Contact Person',
                              hintText: 'Optional',
                              controller: _contactCtrl,
                              onChanged: (v) => _bloc
                                  .add(ClientFormEvent.contactPersonChanged(v)),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: LabelTextField(
                                    label: 'Email',
                                    hintText: 'Optional',
                                    controller: _emailCtrl,
                                    onChanged: (v) => _bloc
                                        .add(ClientFormEvent.emailChanged(v)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: LabelTextField(
                                    label: 'Phone',
                                    hintText: 'Optional',
                                    controller: _phoneCtrl,
                                    onChanged: (v) => _bloc
                                        .add(ClientFormEvent.phoneChanged(v)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LabelTextField(
                              label: 'Address',
                              hintText: 'Optional',
                              controller: _addressCtrl,
                              onChanged: (v) =>
                                  _bloc.add(ClientFormEvent.addressChanged(v)),
                            ),
                            const SizedBox(height: 16),
                            LabelTextField(
                              label: 'Notes',
                              hintText: 'Optional',
                              controller: _notesCtrl,
                              onChanged: (v) =>
                                  _bloc.add(ClientFormEvent.notesChanged(v)),
                            ),
                            const SizedBox(height: 32),
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
                                            const ClientFormEvent.submitted(),
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
                                      : Text(isEdit ? 'Save Changes' : 'Add Client'),
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