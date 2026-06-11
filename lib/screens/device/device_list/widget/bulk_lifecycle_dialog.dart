import 'package:flutter/material.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/enums/device_event_type.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/widgets/label_dropdown.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

class BulkLifecycleDialog extends StatefulWidget {
  final List<String> serialNumbers;

  const BulkLifecycleDialog({super.key, required this.serialNumbers});

  @override
  State<BulkLifecycleDialog> createState() => _BulkLifecycleDialogState();
}

class _BulkLifecycleDialogState extends State<BulkLifecycleDialog> {
  DeviceEventType? _eventType;
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _responsiblePartyController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  bool get _needsLocation =>
      _eventType == DeviceEventType.deployment ||
      _eventType == DeviceEventType.swapDeployment ||
      _eventType == DeviceEventType.maintenanceComplete;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _responsiblePartyController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_eventType == null) {
      setState(() => _error = 'Please select an event type.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final createdBy = await authRepo.currentEmail() ?? 'unknown';

    final error = await deviceRepo.bulkLifecycleEvent(
      serialNumbers: widget.serialNumbers,
      action: _eventType!.label,
      createdBy: createdBy,
      description: _descriptionController.text.trim(),
      associatedLocation: _locationController.text.trim(),
      relatedReference: _referenceController.text.trim(),
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(textTheme),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Configuration',
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LabelDropdown<DeviceEventType>(
                      label: 'Event Type',
                      hintText: 'Select event type',
                      value: _eventType,
                      items: DeviceEventType.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.label),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _eventType = v),
                    ),
                    if (_needsLocation) ...[
                      const SizedBox(height: 12),
                      LabelTextField(
                        label: 'Location',
                        hintText: 'e.g. Client Site, Jakarta',
                        controller: _locationController,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Event Details',
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LabelTextField(
                      label: 'Description',
                      hintText: 'Description',
                      controller: _descriptionController,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    const SizedBox(height: 12),
                    LabelTextField(
                      label: 'Responsible Party',
                      hintText: 'Responsible Party',
                      controller: _responsiblePartyController,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    LabelTextField(
                      label: 'Reference (Optional)',
                      hintText: 'Reference (Optional)',
                      controller: _referenceController,
                      prefixIcon: const Icon(Icons.qr_code),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: textTheme.bodySmall?.copyWith(color: error500),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel',
                            style: textTheme.bodyLarge?.medium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _apply,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Apply changes',
                                      style: textTheme.bodyLarge?.medium,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    final count = widget.serialNumbers.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.settings, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bulk Lifecycle Event',
                    style: textTheme.titleSmall?.bold),
                Text(
                  '$count device${count == 1 ? '' : 's'} selected',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}