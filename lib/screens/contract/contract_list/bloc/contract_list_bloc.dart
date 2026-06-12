import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/contract_model.dart';
import 'package:lacakind_frontend/data/repositories/contract_repository.dart';

part 'contract_list_event.dart';
part 'contract_list_state.dart';
part 'contract_list_bloc.freezed.dart';

class ContractListBloc extends Bloc<ContractListEvent, ContractListState> {
  String? _contractId;
  String? _clientName;
  String? _contractType;
  String? _startDate;
  String? _endDate;
  String? _status;
  String? _paymentStatus;

  ContractListBloc() : super(const ContractListState.initial()) {
    on<ContractListEvent>((event, emit) async {
      switch (event) {
        case _Started():
          await _onStarted(event, emit);
        case _OnSearch():
          await _onSearched(event, emit);
        case _LoadMore():
          await _onLoadMore(emit);
        case _DeleteContract():
          await _onDeleteContract(event, emit);
      }
    });
  }

  Future<(List<ContractModel>?, String?)> _fetch(int page) =>
      contractRepo.getContracts(
        contractId: _contractId,
        clientName: _clientName,
        contractType: _contractType,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        paymentStatus: _paymentStatus,
        page: page,
      );

  bool _reachedEnd(List<ContractModel> page) =>
      page.length < ContractRepository.pageSize;

  Future<void> _onStarted(
    _Started event,
    Emitter<ContractListState> emit,
  ) async {
    _contractId = event.contractId;
    _clientName = event.clientName;
    _contractType = event.contractType;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _status = event.status;
    _paymentStatus = event.paymentStatus;

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentPage: 1,
        hasMore: true,
        contracts: [],
      ),
    );

    final (data, error) = await _fetch(1);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        contracts: data!,
        currentPage: 1,
        hasMore: !_reachedEnd(data),
      ),
    );
  }

  Future<void> _onSearched(
    _OnSearch event,
    Emitter<ContractListState> emit,
  ) async {
    _contractId = null;
    _clientName = event.query.isEmpty ? null : event.query;
    _contractType = null;
    _startDate = null;
    _endDate = null;
    _status = null;
    _paymentStatus = null;

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentPage: 1,
        hasMore: true,
        contracts: [],
      ),
    );

    final (data, error) = await _fetch(1);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        contracts: data!,
        currentPage: 1,
        hasMore: !_reachedEnd(data),
      ),
    );
  }

  Future<void> _onLoadMore(Emitter<ContractListState> emit) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));

    final (data, error) = await _fetch(nextPage);
    if (error != null) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: error));
      return;
    }
    emit(
      state.copyWith(
        isLoadingMore: false,
        contracts: [...state.contracts, ...data!],
        currentPage: nextPage,
        hasMore: !_reachedEnd(data),
      ),
    );
  }

  Future<void> _onDeleteContract(
    _DeleteContract event,
    Emitter<ContractListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final error = await contractRepo.deleteContract(event.id);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    add(const ContractListEvent.started());
    emit(state.copyWith(isSuccess: true, successMessage: 'Contract deleted'));
  }
}
