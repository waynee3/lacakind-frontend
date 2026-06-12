import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lacakind_frontend/data/enums/bulk_operation_action.dart';
import 'package:lacakind_frontend/data/models/bulk_operation_model.dart';
import 'package:lacakind_frontend/extensions/text_ext.dart';
import 'package:lacakind_frontend/screens/lifecycle/bloc/lifecycle_log_bloc.dart';
import 'package:lacakind_frontend/styles/color.styles.dart';

final _dateFmt = DateFormat('dd MMM yyyy');
final _timeFmt = DateFormat('HH:mm');

class LifecycleLogScreen extends StatefulWidget {
  const LifecycleLogScreen({super.key});

  @override
  State<LifecycleLogScreen> createState() => _LifecycleLogScreenState();
}

class _LifecycleLogScreenState extends State<LifecycleLogScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _searchQuery = '';
  BulkOperationAction? _actionFilter;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _endDate   = DateTime.now();
    _startDate = _endDate.subtract(const Duration(hours: 24));
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fire());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<LifecycleLogBloc>().add(const LifecycleLogEvent.loadMore());
    }
  }

  void _fire() {
    final isSerial = _searchQuery.isNotEmpty &&
        RegExp(r'^[A-Z0-9\-]{4,}$', caseSensitive: false)
            .hasMatch(_searchQuery);

    context.read<LifecycleLogBloc>().add(LifecycleLogEvent.started(
          serialNumber: isSerial ? _searchQuery : null,
          clientName:
              (!isSerial && _searchQuery.isNotEmpty) ? _searchQuery : null,
          action: _actionFilter?.name,
          startDate: _startDate,
          endDate: _endDate,
        ));
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      helpText: 'Select date range',
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate   = DateTime(
          picked.end.year, picked.end.month, picked.end.day, 23, 59, 59,
        );
      });
      _fire();
    }
  }

  void _toggleAction(BulkOperationAction action) {
    setState(() {
      _actionFilter = _actionFilter == action ? null : action;
    });
    _fire();
  }

  void _clearDate() {
    setState(() {
      _endDate   = DateTime.now();
      _startDate = _endDate.subtract(const Duration(hours: 24));
    });
    _fire();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lifecycle Log', style: textTheme.titleLarge?.semibold),
            const SizedBox(height: 20),
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search by serial number or client name',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (v) {
                setState(() => _searchQuery = v.trim());
                _fire();
              },
              onChanged: (v) {
                if (v.isEmpty) {
                  setState(() => _searchQuery = '');
                  _fire();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildFilterChips(textTheme),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<LifecycleLogBloc, LifecycleLogState>(
                builder: (context, state) {
                  if (state.isLoading && state.logs.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage.isNotEmpty && state.logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage,
                            style: textTheme.bodyMedium
                                ?.withColor(Colors.red.shade600),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _fire,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 48, color: neutral400),
                          const SizedBox(height: 8),
                          Text(
                            'No lifecycle events found',
                            style:
                                textTheme.bodyMedium?.withColor(neutral500),
                          ),
                        ],
                      ),
                    );
                  }

                  final itemCount =
                      state.logs.length + (state.hasMore ? 1 : 0);

                  return ListView.separated(
                    controller: _scrollCtrl,
                    itemCount: itemCount,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i == state.logs.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: state.isLoadingMore
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }
                      return _LogTile(
                        log: state.logs[i],
                        textTheme: textTheme,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(TextTheme textTheme) {
    final isDefaultRange =
        _endDate.day == DateTime.now().day &&
        _endDate.difference(_startDate).inHours.abs() <= 25;

    final dateLabel =
        '${_dateFmt.format(_startDate)} – ${_dateFmt.format(_endDate)}';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          avatar: const Icon(Icons.calendar_today_outlined, size: 14),
          label: Text(
            isDefaultRange ? 'Last 24 hours' : dateLabel,
            style: textTheme.bodySmall,
          ),
          selected: !isDefaultRange,
          showCheckmark: false,
          onSelected: (_) => _pickDateRange(),
          onDeleted: isDefaultRange ? null : _clearDate,
        ),

        ...BulkOperationAction.values.map((action) {
          final isSelected = _actionFilter == action;
          return FilterChip(
            label: Text(action.label, style: textTheme.bodySmall),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => _toggleAction(action),
          );
        }),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  final BulkOperationModel log;
  final TextTheme textTheme;
  const _LogTile({required this.log, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final actionLabel = log.action?.label ?? log.actionRaw;
    final deviceCount = log.affectedDevices.length;
    final color       = _actionColor(log.action);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        actionLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$deviceCount device${deviceCount == 1 ? '' : 's'}',
                      style: textTheme.bodySmall?.withColor(neutral500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _DeviceChips(
                    serials: log.affectedDevices,
                    textTheme: textTheme),
                if (log.associatedLocation.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: neutral500),
                      const SizedBox(width: 4),
                      Text(log.associatedLocation,
                          style:
                              textTheme.bodySmall?.withColor(neutral500)),
                    ],
                  ),
                ],

                if (log.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(log.description,
                      style: textTheme.bodySmall?.withColor(neutral600)),
                ],
                const SizedBox(height: 4),

                // Timestamp + by
                Row(
                  children: [
                    Text(
                      _dateFmt.format(log.timestamp),
                      style: textTheme.bodySmall?.withColor(neutral500),
                    ),
                    Text(
                      ' · ${_timeFmt.format(log.timestamp)}',
                      style: textTheme.bodySmall?.withColor(neutral400),
                    ),
                    const Spacer(),
                    Text(
                      'by ${log.createdBy}',
                      style: textTheme.bodySmall?.withColor(neutral500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _actionColor(BulkOperationAction? action) {
    switch (action) {
      case BulkOperationAction.deployment:
      case BulkOperationAction.swapdeployment:
        return const Color(0xFF16A34A); // green
      case BulkOperationAction.maintenancestart:
        return const Color(0xFFEA580C); // orange
      case BulkOperationAction.retirement:
      case BulkOperationAction.bulkDelete:
        return const Color(0xFFDC2626); // red
      case BulkOperationAction.returnFromClient:
        return const Color(0xFF7C3AED); // purple
      case BulkOperationAction.procurementarrival:
        return const Color(0xFF0369A1); // blue
      case BulkOperationAction.warehousestorage:
        return const Color(0xFF0891B2); // cyan
      case BulkOperationAction.maintenancecomplete:
        return const Color(0xFF059669); // teal
      case BulkOperationAction.bulkImport:
        return const Color(0xFF6366F1); // indigo
      default:
        return neutral400;
    }
  }
}

class _DeviceChips extends StatelessWidget {
  final List<String> serials;
  final TextTheme textTheme;
  const _DeviceChips({required this.serials, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    const max   = 3;
    final shown = serials.take(max).toList();
    final extra = serials.length - max;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...shown.map((s) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: neutral100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(s,
                  style: textTheme.bodySmall
                      ?.copyWith(fontFamily: 'monospace')),
            )),
        if (extra > 0)
          Text('+$extra more',
              style: textTheme.bodySmall?.withColor(neutral500)),
      ],
    );
  }
}