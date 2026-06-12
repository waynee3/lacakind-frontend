import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/bulk_operation_model.dart';
import 'package:lacakind_frontend/data/repositories/lifecycle_log_repository.dart';

part 'lifecycle_log_event.dart';
part 'lifecycle_log_state.dart';
part 'lifecycle_log_bloc.freezed.dart';

class LifecycleLogBloc extends Bloc<LifecycleLogEvent, LifecycleLogState> {
  String? _serialNumber;
  String? _clientName;
  String? _action;
  DateTime? _startDate;
  DateTime? _endDate;

  LifecycleLogBloc() : super(const LifecycleLogState.initial()) {
    on<LifecycleLogEvent>((event, emit) async {
      switch (event) {
        case _Started():
          await _onStarted(event, emit);
        case _LoadMore():
          await _onLoadMore(emit);
      }
    });
  }

  String? _fmt(DateTime? d) => d?.toIso8601String();

  Future<(List<BulkOperationModel>?, String?)> _fetch(int page) =>
      lifecycleLogRepo.getLogs(
        serialNumber: _serialNumber,
        clientName:   _clientName,
        action:       _action,
        startDate:    _fmt(_startDate),
        endDate:      _fmt(_endDate),
        page:         page,
      );

  bool _reachedEnd(List<BulkOperationModel> page) =>
      page.length < LifecycleLogRepository.pageSize;

  Future<void> _onStarted(_Started event, Emitter<LifecycleLogState> emit) async {
    _serialNumber = event.serialNumber;
    _clientName   = event.clientName;
    _action       = event.action;
    _startDate    = event.startDate;
    _endDate      = event.endDate;

    emit(state.copyWith(
      isLoading: true, errorMessage: '',
      currentPage: 1, hasMore: true, logs: [],
    ));

    final (data, error) = await _fetch(1);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      logs: data!,
      currentPage: 1,
      hasMore: !_reachedEnd(data),
    ));
  }

  Future<void> _onLoadMore(Emitter<LifecycleLogState> emit) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    final (data, error) = await _fetch(nextPage);
    if (error != null) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(
      isLoadingMore: false,
      logs: [...state.logs, ...data!],
      currentPage: nextPage,
      hasMore: !_reachedEnd(data),
    ));
  }
}