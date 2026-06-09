import 'package:flutter/material.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';
import 'package:lacakind_frontend/widgets/label_dropdown.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

const _kEventTypes = [
  'Deployment to Client',
  'Return from Client',
  'Sent for Repair',
  'Returned from Repair',
  'Decommissioned',
  'Archived',
];

class BulkLifecycleDialog extends StatefulWidget {
  final List<String> selectedIds;

  const BulkLifecycleDialog({super.key, required this.selectedIds});

  @override
  State<BulkLifecycleDialog> createState() => _BulkLifecycleDialogState();
}

class _BulkLifecycleDialogState extends State<BulkLifecycleDialog> {
  String? _eventType;
  final _descriptionController = TextEditingController();
  final _responsiblePartyController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
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

    final data = {
      'eventType': _eventType,
      if (_descriptionController.text.isNotEmpty)
        'description': _descriptionController.text.trim(),
      if (_responsiblePartyController.text.isNotEmpty)
        'responsibleParty': _responsiblePartyController.text.trim(),
      if (_referenceController.text.isNotEmpty)
        'relatedReference': _referenceController.text.trim(),
    };

    final error = await deviceRepo.bulkLifecycleEvent(widget.selectedIds, data);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(textTheme),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: Icons.calendar_today_outlined,
                    label: 'Event Configuration',
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  LabelDropdown<String>(
                    label: 'Event Type',
                    hintText: 'Select event type',
                    value: _eventType,
                    items: _kEventTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _eventType = v),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    icon: Icons.info_outline,
                    label: 'Event Details',
                    textTheme: textTheme,
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
                    suffixIcon: const Icon(Icons.info_outline),
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
                          "Cancel",
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
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Apply changes",
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
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
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
                Text('Bulk Lifecycle Event', style: textTheme.titleSmall?.bold),
                Text(
                  '${widget.selectedIds.length} device selected',
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
    required TextTheme textTheme,
  }) {
    return Text(
      label,
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
