import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BulkImportState {
  final bool isLoading;
  final List<String> headers;
  final List<List<String>> rows;
  final String? parseError;

  const BulkImportState({
    this.isLoading = true,
    this.headers = const [],
    this.rows = const [],
    this.parseError,
  });

  BulkImportState copyWith({
    bool? isLoading,
    List<String>? headers,
    List<List<String>>? rows,
    String? parseError,
  }) =>
      BulkImportState(
        isLoading: isLoading ?? this.isLoading,
        headers: headers ?? this.headers,
        rows: rows ?? this.rows,
        parseError: parseError,
      );
}

class BulkImportCubit extends Cubit<BulkImportState> {
  BulkImportCubit(Uint8List bytes) : super(const BulkImportState()) {
    _parse(bytes);
  }

  void _parse(Uint8List bytes) {
    try {
      final csvString = utf8.decode(bytes, allowMalformed: true);
      final cleaned = csvString
          .replaceAll(RegExp(r'[\r\n]+'), '\n')
          .split('\n')
          .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
          .join('\n');

      final parsed = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(cleaned);

      if (parsed.length < 2) {
        emit(state.copyWith(
          isLoading: false,
          parseError: 'CSV must have at least one data row',
        ));
        return;
      }

      final headers = parsed[0].map((e) => e.toString().trim()).toList();
      final rows = parsed
          .skip(1)
          .map(
            (r) => List<String>.generate(
              headers.length,
              (i) => i < r.length ? (r[i]?.toString().trim() ?? '') : '',
            ),
          )
          .toList();

      emit(state.copyWith(isLoading: false, headers: headers, rows: rows));
    } catch (e) {
      emit(state.copyWith(isLoading: false, parseError: 'Failed to parse CSV: $e'));
    }
  }
}
