import 'package:flutter/material.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/enums/device_event_type.dart';
import 'package:lacakind_frontend/data/models/client_model.dart';
import 'package:lacakind_frontend/data/models/contract_model.dart';
import 'package:lacakind_frontend/data/models/device_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/widgets/label_dropdown.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

const _allowedEvents = <String, List<DeviceEventType>>{
  'InStock': [
    DeviceEventType.procurementArrival,
    DeviceEventType.warehouseStorage,
    DeviceEventType.deployment,
    DeviceEventType.maintenanceStart,
    DeviceEventType.retirement,
  ],
  'In Warehouse': [
    DeviceEventType.deployment,
    DeviceEventType.maintenanceStart,
    DeviceEventType.swapDeployment,
    DeviceEventType.retirement,
  ],
  'Deployed': [
    DeviceEventType.maintenanceStart,
    DeviceEventType.swapDeployment,
    DeviceEventType.returnFromClient,
    DeviceEventType.retirement,
  ],
  'Under Repair': [
    DeviceEventType.maintenanceComplete,
    DeviceEventType.retirement,
  ],
  'Repaired': [
    DeviceEventType.deployment,
    DeviceEventType.warehouseStorage,
    DeviceEventType.swapDeployment,
    DeviceEventType.returnFromClient,
    DeviceEventType.retirement,
  ],
  'Spare Deployed': [
    DeviceEventType.maintenanceStart,
    DeviceEventType.returnFromClient,
    DeviceEventType.retirement,
  ],
  'Returned': [
    DeviceEventType.deployment,
    DeviceEventType.warehouseStorage,
    DeviceEventType.maintenanceStart,
    DeviceEventType.retirement,
  ],
  'Retired': [],
};

const _clientRequired = {
  DeviceEventType.deployment,
  DeviceEventType.swapDeployment,
};

const _locationRequired = {
  DeviceEventType.deployment,
  DeviceEventType.swapDeployment,
  DeviceEventType.maintenanceComplete,
};

List<DeviceEventType> _allowedForDevices(List<DeviceModel> devices) {
  if (devices.isEmpty) return DeviceEventType.values.toList();

  Set<DeviceEventType>? result;
  for (final d in devices) {
    final statusStr = d.status?.value ?? '';
    final allowed   = _allowedEvents[statusStr] ?? [];
    final set       = Set<DeviceEventType>.from(allowed);
    result          = result == null ? set : result.intersection(set);
  }
  return (result ?? {}).toList();
}

class BulkLifecycleDialog extends StatefulWidget {
  final List<DeviceModel> selectedDevices;

  const BulkLifecycleDialog({super.key, required this.selectedDevices});

  @override
  State<BulkLifecycleDialog> createState() => _BulkLifecycleDialogState();
}

class _BulkLifecycleDialogState extends State<BulkLifecycleDialog> {
  DeviceEventType? _eventType;

  List<ClientModel>   _clients   = [];
  List<ContractModel> _contracts = [];
  ClientModel?   _selectedClient;
  ContractModel? _selectedContract;
  bool _loadingDropdowns = false;

  List<DeviceModel> _warehouseDevices = [];
  DeviceModel?      _selectedSpare;
  bool _loadingSpares = false;

  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _partyCtrl       = TextEditingController();
  final _referenceCtrl   = TextEditingController();

  bool    _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _partyCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  List<DeviceEventType> get _allowed =>
      _allowedForDevices(widget.selectedDevices);

  bool get _needsClient   => _clientRequired.contains(_eventType);
  bool get _needsLocation => _locationRequired.contains(_eventType);
  bool get _isSwap        => _eventType == DeviceEventType.swapDeployment;

  List<ContractModel> get _filteredContracts => _selectedClient == null
      ? _contracts
      : _contracts.where((c) => c.clientId == _selectedClient!.id).toList();

  Future<void> _loadClientDropdowns() async {
    if (_clients.isNotEmpty) return;
    setState(() => _loadingDropdowns = true);
    final (clients, _)   = await clientRepo.getAllClients();
    final (contracts, __) = await contractRepo.getAllContracts();
    if (!mounted) return;
    setState(() {
      _clients          = clients ?? [];
      _contracts        = contracts ?? [];
      _loadingDropdowns = false;
    });
  }

  Future<void> _loadWarehouseDevices() async {
    if (_warehouseDevices.isNotEmpty) return;
    setState(() => _loadingSpares = true);
    final selectedSerials = widget.selectedDevices.map((d) => d.serialNumber).toSet();
    final (all, _) = await deviceRepo.getDevices(
      status: 'In Warehouse',
      limit: 999,
    );
    if (!mounted) return;
    setState(() {
      _warehouseDevices = (all ?? [])
          .where((d) => !selectedSerials.contains(d.serialNumber))
          .toList();
      _loadingSpares = false;
    });
  }

  void _onEventTypeChanged(DeviceEventType? v) {
    setState(() {
      _eventType        = v;
      _selectedClient   = null;
      _selectedContract = null;
      _selectedSpare    = null;
      _locationCtrl.clear();
      _error = null;
    });
    if (v != null && _clientRequired.contains(v)) {
      _loadClientDropdowns().then((_) {
        if (v == DeviceEventType.swapDeployment && mounted) {
          _prefillFromOriginal();
        }
      });
    }
    if (v == DeviceEventType.swapDeployment) _loadWarehouseDevices();
  }

  void _prefillFromOriginal() {
    if (widget.selectedDevices.isEmpty) return;
    final original = widget.selectedDevices.first;

    if (original.currentLocation?.isNotEmpty == true) {
      _locationCtrl.text = original.currentLocation!;
    }

    ClientModel? match;

    if (original.clientId?.isNotEmpty == true) {
      match = _clients.where((c) => c.id == original.clientId).firstOrNull;
    }

    if (match == null && original.clientName?.isNotEmpty == true) {
      match = _clients.where((c) => c.name == original.clientName).firstOrNull;
    }

    if (match == null && original.currentLocation?.isNotEmpty == true) {
      match = _clients
          .where((c) => c.name == original.currentLocation ||
                        c.location == original.currentLocation)
          .firstOrNull;
    }

    if (match != null) {
      setState(() => _selectedClient = match);

      if (original.linkedContractIds.isNotEmpty) {
        final matchingContract = _contracts
            .where((c) =>
                c.clientId == match!.id &&
                (original.linkedContractIds.contains(c.id) ||
                 original.linkedContractIds.contains(c.contractId)))
            .firstOrNull;
        if (matchingContract != null) {
          setState(() => _selectedContract = matchingContract);
        }
      }
    }
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
    if (_isSwap && _selectedSpare == null) {
      setState(() => _error = 'Please select a spare device.');
      return;
    }
    if (_needsLocation && _locationCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Location is required for this event.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    final createdBy = await authRepo.currentEmail() ?? 'unknown';
    final serials = widget.selectedDevices.map((d) => d.serialNumber).toList();

    String? error;

    if (_isSwap) {
      error = await deviceRepo.bulkLifecycleEvent(
        serialNumbers:      serials,
        action:             _eventType!.label,
        createdBy:          createdBy,
        description:        _descriptionCtrl.text.trim(),
        associatedLocation: _locationCtrl.text.trim(),
        relatedReference:   _selectedSpare!.serialNumber,
        clientId:           _selectedClient?.id,
        contractId:         _selectedContract?.id,
        spareSerial:        _selectedSpare!.serialNumber,
      );
    } else {
      error = await deviceRepo.bulkLifecycleEvent(
        serialNumbers:      serials,
        action:             _eventType!.label,
        createdBy:          createdBy,
        description:        _descriptionCtrl.text.trim(),
        associatedLocation: _locationCtrl.text.trim(),
        relatedReference:   _referenceCtrl.text.trim(),
        clientId:           _selectedClient?.id,
        contractId:         _selectedContract?.id,
      );
    }

    if (!mounted) return;
    if (error != null) {
      setState(() { _isLoading = false; _error = error; });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allowed   = _allowed;
    final count     = widget.selectedDevices.length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              count: count,
              devices: widget.selectedDevices,
              textTheme: textTheme,
              onClose: () => Navigator.of(context).pop(false),
            ),
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

                    _Label('Event Configuration', textTheme),
                    const SizedBox(height: 8),
                    if (allowed.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          'No valid events for the current device status'
                          '${count > 1 ? ' combination' : ''}.',
                          style: textTheme.bodySmall
                              ?.withColor(Colors.orange.shade800),
                        ),
                      )
                    else
                      LabelDropdown<DeviceEventType>(
                        label: 'Event Type *',
                        hintText: 'Select event type',
                        value: _eventType,
                        items: allowed
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.label),
                                ))
                            .toList(),
                        onChanged: _onEventTypeChanged,
                      ),

                    if (_isSwap) ...[
                      const SizedBox(height: 16),
                      _Label('Swap Configuration', textTheme),
                      const SizedBox(height: 8),
                      _ReadOnlyField(
                        label: 'Original Device${count > 1 ? 's' : ''} (being replaced)',
                        value: widget.selectedDevices
                            .map((d) => '${d.serialNumber} · ${d.status?.value ?? ''}')
                            .join('\n'),
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 12),
                      if (_loadingSpares)
                        const Center(child: CircularProgressIndicator())
                      else if (_warehouseDevices.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            'No spare devices available in warehouse.',
                            style: textTheme.bodySmall
                                ?.withColor(Colors.orange.shade800),
                          ),
                        )
                      else
                        LabelDropdown<DeviceModel>(
                          label: 'Spare Device (In Warehouse) *',
                          hintText: 'Select spare device',
                          value: _selectedSpare,
                          items: _warehouseDevices
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                        '${d.serialNumber} · ${d.modelType ?? ''}'),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedSpare = v),
                        ),
                    ],
                    if (_needsClient) ...[
                      const SizedBox(height: 16),
                      _Label('Client & Contract', textTheme),
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
                                    child: Text(
                                        '${c.name} (${c.location})'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedClient  = v;
                            _selectedContract = null;
                            if (v != null) _locationCtrl.text = v.location;
                          }),
                        ),

                      if (_selectedClient != null) ...[
                        const SizedBox(height: 12),
                        LabelDropdown<ContractModel>(
                          label: 'Contract *',
                          hintText: _filteredContracts.isEmpty
                              ? 'No contracts for this client'
                              : 'Select contract',
                          value: _selectedContract,
                          items: _filteredContracts
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                        '${c.contractRef} · ${c.contractId}'),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedContract = v),
                        ),
                        if (_filteredContracts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'No contracts found. Create one first.',
                              style: textTheme.bodySmall
                                  ?.withColor(Colors.orange.shade700),
                            ),
                          ),
                      ],
                    ],
                    if (_needsLocation) ...[
                      const SizedBox(height: 12),
                      LabelTextField(
                        label: 'Location *',
                        hintText: 'e.g. Client site, Jakarta',
                        controller: _locationCtrl,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _Label('Event Details', textTheme),
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
                      hintText: 'Optional notes',
                      controller: _descriptionCtrl,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    if (!_isSwap) ...[
                      const SizedBox(height: 12),
                      LabelTextField(
                        label: 'Reference (Optional)',
                        hintText: 'Ticket #, order ID, etc.',
                        controller: _referenceCtrl,
                        prefixIcon: const Icon(Icons.numbers_outlined),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _Footer(
              isLoading: _isLoading,
              onCancel: () => Navigator.of(context).pop(false),
              onApply: allowed.isEmpty ? null : _apply,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final List<DeviceModel> devices;
  final TextTheme textTheme;
  final VoidCallback onClose;
  const _Header({
    required this.count,
    required this.devices,
    required this.textTheme,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = count == 1
        ? '${devices.first.serialNumber} · ${devices.first.status?.value ?? ''}'
        : '$count devices selected';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.settings_outlined, size: 20, ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bulk Lifecycle Event',
                    style: textTheme.titleSmall?.bold),
                Text(subtitle,
                    style: textTheme.bodySmall?.withColor(neutral500)),
              ],
            ),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback? onApply;
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
              child: FilledButton.icon(
                onPressed: (isLoading || onApply == null) ? null : onApply,
                icon: isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text('Apply Changes',
                    style: textTheme.bodyLarge?.medium
                        ?.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final TextTheme textTheme;
  const _Label(this.text, this.textTheme);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style:
            textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
        child: Text(message,
            style: textTheme.bodySmall?.withColor(Colors.red.shade700)),
      );
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall?.withColor(neutral500)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: neutral100,
            border: Border.all(color: neutral300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: neutral700,
            ),
          ),
        ),
      ],
    );
  }
}