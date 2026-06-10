import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_list/bloc/bulk_import_cubit.dart';

class BulkImportReviewDialog extends StatelessWidget {
  const BulkImportReviewDialog._();

  static Future<bool?> show(BuildContext context, {required Uint8List csvBytes}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider(
        create: (_) => BulkImportCubit(csvBytes),
        child: const BulkImportReviewDialog._(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkImportCubit, BulkImportState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Review Import'),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 860,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: _buildBody(context, state),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            if (!state.isLoading && state.parseError == null)
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Import ${state.rows.length} row${state.rows.length == 1 ? '' : 's'}'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BulkImportState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.parseError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            Text(state.parseError!),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${state.rows.length} row${state.rows.length == 1 ? '' : 's'} found',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 32,
                columnSpacing: 16,
                columns: state.headers
                    .map(
                      (h) => DataColumn(
                        label: Text(
                          h,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                    .toList(),
                rows: state.rows
                    .map(
                      (row) => DataRow(
                        cells: row.map((cell) => DataCell(Text(cell))).toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
