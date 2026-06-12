import 'package:flutter/material.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/enums/device_event_type.dart';
import 'package:lacakind_frontend/data/models/client_model.dart';
import 'package:lacakind_frontend/data/models/contract_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/widgets/label_dropdown.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

const _clientRequiredEvents = {
  DeviceEventType.deployment,
  DeviceEventType.swapDeployment,
};

const _locationFromClient = {
  DeviceEventType.deployment,
  DeviceEventType.swapDeployment,
  DeviceEventType.maintenanceComplete,
};

class BulkLifecycleDialog extends StatefulWidget {
  final List<String> serialNumbers;

  const BulkLifecycleDialog({super.key, required this.serialNumbers});

  @override
  State<BulkLifecycleDialog> createState() => _BulkLifecycleDialogState();
}

class _BulkLifecycleDialogState extends State<BulkLifecycleDialog> {
  DeviceEventType? _eventType;

  List<ClientModel> _clients = [];
  List<ContractModel> _contracts = [];
  ClientModel? _selectedClient;
  ContractModel? _selectedContract;
  bool _loadingDropdowns = false;

  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _partyCtrl       = TextEditingController();
  final _referenceCtrl   = TextEditingController();

  bool    _isLoading = false;
  String? _error;


  bool get _needsClient   => _clientRequiredEvents.contains(_eventType);
  bool get _needsContract => _eventType == DeviceEventType.deployment;
  bool get _needsLocation => _locationFromClient.contains(_eventType);

  List<ContractModel> get _filteredContracts => _selectedClient == null
      ? _contracts
      : _contracts.where((c) => c.clientId == _selectedClient!.id).toList();


  @override
  void dispose() {
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _partyCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }


  Future<void> _loadDropdowns() async {
    if (_clients.isNotEmpty) return; 
    setState(() => _loadingDropdowns = true);
    final (clients, _) = await clientRepo.getAllClients();
    final (contracts, _) = await contractRepo.getContracts();
    
    if (!mounted) return;
    setState(() {
      _clients = clients ?? [];
      _contracts = contracts ?? [];
      _loadingDropdowns = false;
    });
  }

  void _onEventTypeChanged(DeviceEventType? v) {
    setState(() {
      _eventType       = v;
      _selectedClient  = null;
      _selectedContract = null;
      _locationCtrl.clear();
      _error = null;
    });
    if (v != null && _clientRequiredEvents.contains(v)) {
      _loadDropdowns();
    }
  }

  void _onClientChanged(ClientModel? client) {
    setState(() {
      _selectedClient  = client;
      _selectedContract = null;
      if (client != null) {
        _locationCtrl.text = client.location;
      } else {
        _locationCtrl.clear();
      }
    });
  }

  Future<void> _apply() async {
    if (_eventType == null) {
      setState(() => _error = 'Please select an event type.');
      return;
    }
    if (_needsClient && _selectedClient == null) {
      setState(() => _error = 'Please select a client.');
      return;
    }
    if (_needsContract && _selectedContract == null) {
      setState(() => _error = 'Please select a contract.');
      return;
    }
    if (_partyCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Responsible party is required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final createdBy = await authRepo.currentEmail() ?? _partyCtrl.text.trim();

    final error = await deviceRepo.bulkLifecycleEvent(
      serialNumbers:      widget.serialNumbers,
      action:             _eventType!.label,
      createdBy:          createdBy,
      description:        _descriptionCtrl.text.trim(),
      associatedLocation: _locationCtrl.text.trim(),
      relatedReference:   _referenceCtrl.text.trim(),
      clientId:           _selectedClient?.id,
      contractId:         _selectedContract?.id,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = widget.serialNumbers.length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(count: count, onClose: () => Navigator.of(context).pop(false)),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) ...[
                      _ErrorBanner(message: _error!, textTheme: textTheme),
                      const SizedBox(height: 12),
                    ],

                    _SectionLabel(label: 'Event Configuration', textTheme: textTheme),
                    const SizedBox(height: 8),
                    LabelDropdown<DeviceEventType>(
                      label: 'Event Type *',
                      hintText: 'Select event type',
                      value: _eventType,
                      items: DeviceEventType.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.label),
                              ))
                          .toList(),
                      onChanged: _onEventTypeChanged,
                    ),

                    if (_needsClient) ...[
                      const SizedBox(height: 16),
                      _SectionLabel(label: 'Client & Contract', textTheme: textTheme),
                      const SizedBox(height: 8),
                      if (_loadingDropdowns)
                        const Center(child: CircularProgressIndicator())
                      else
                        LabelDropdown<ClientModel>(
                          label: 'Client *',
                          hintText: 'Select client',
                          value: _selectedClient,
                          items: _clients
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text('${c.name} (${c.location})'),
                                  ))
                              .toList(),
                          onChanged: _onClientChanged,
                        ),
                    ],

                    if (_needsContract && _selectedClient != null) ...[
                      const SizedBox(height: 12),
                      LabelDropdown<ContractModel>(
                        label: 'Contract *',
                        hintText: 'Select contract',
                        value: _selectedContract,
                        items: _filteredContracts
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    '${c.contractId} (${c.clientName ?? 'No client'})',
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedContract = v),
                      ),
                      if (_filteredContracts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'No active contracts for this client.',
                            style: textTheme.bodySmall
                                ?.withColor(Colors.orange.shade700),
                          ),
                        ),
                    ],

                    if (_needsLocation) ...[
                      const SizedBox(height: 12),
                      LabelTextField(
                        label: 'Location *',
                        hintText: 'e.g. Client Site, Jakarta',
                        controller: _locationCtrl,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _SectionLabel(label: 'Event Details', textTheme: textTheme),
                    const SizedBox(height: 8),
                    LabelTextField(
                      label: 'Responsible Party *',
                      hintText: 'Name or email',
                      controller: _partyCtrl,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    LabelTextField(
                      label: 'Description',
                      hintText: 'Optional notes about this event',
                      controller: _descriptionCtrl,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    const SizedBox(height: 12),
                    LabelTextField(
                      label: 'Reference (Optional)',
                      hintText: 'Ticket #, order ID, etc.',
                      controller: _referenceCtrl,
                      prefixIcon: const Icon(Icons.numbers_outlined),
                    ),
                  ],
                ),
              ),
            ),

            _Footer(
              isLoading: _isLoading,
              onCancel: () => Navigator.of(context).pop(false),
              onApply: _apply,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onClose;
  const _Header({required this.count, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.settings_outlined, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bulk Lifecycle Event', style: textTheme.titleSmall?.bold),
                Text(
                  '$count device${count == 1 ? '' : 's'} selected',
                  style: textTheme.bodySmall?.withColor(neutral500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onApply;
  const _Footer({
    required this.isLoading,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextButton(
                onPressed: isLoading ? null : onCancel,
                child: Text('Cancel', style: textTheme.bodyLarge?.medium),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onApply,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(
                  'Apply Changes',
                  style: textTheme.bodyLarge?.medium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final TextTheme textTheme;
  const _SectionLabel({required this.label, required this.textTheme});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final TextTheme textTheme;
  const _ErrorBanner({required this.message, required this.textTheme});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          message,
          style: textTheme.bodySmall?.withColor(Colors.red.shade700),
        ),
      );
}