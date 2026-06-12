import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/client_model.dart';

part 'contract_form_event.dart';
part 'contract_form_state.dart';
part 'contract_form_bloc.freezed.dart';

class ContractFormBloc extends Bloc<ContractFormEvent, ContractFormState> {
  ContractFormBloc() : super(const ContractFormState.initial()) {
    on<ContractFormEvent>((event, emit) async {
      switch (event) {
        case _Started():
          await _loadClients(emit);
        case _StartedEdit():
          await _onStartedEdit(event, emit);
        case _ContractIdChanged():
          emit(state.copyWith(contractId: event.value));
        case _ClientChanged():
          emit(state.copyWith(selectedClient: event.value));
        case _ContractTypeChanged():
          emit(state.copyWith(contractType: event.value));
        case _StartDateChanged():
          emit(state.copyWith(startDate: event.value));
        case _EndDateChanged():
          emit(state.copyWith(endDate: event.value));
        case _StatusChanged():
          emit(state.copyWith(status: event.value));
        case _PaymentStatusChanged():
          emit(state.copyWith(paymentStatus: event.value));
        case _NotesChanged():
          emit(state.copyWith(notes: event.value));
        case _Submitted():
          await _onSubmitted(emit);
      }
    });
  }

  Future<void> _loadClients(Emitter<ContractFormState> emit) async {
    emit(state.copyWith(isLoading: true));
    final (clients, error) = await clientRepo.getAllClients();
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(isLoading: false, clients: clients ?? []));
  }

  Future<void> _onStartedEdit(
    _StartedEdit event,
    Emitter<ContractFormState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final (clients, clientsErr) = await clientRepo.getAllClients();
    if (clientsErr != null) {
      emit(state.copyWith(isLoading: false, errorMessage: clientsErr));
      return;
    }
    final (contract, contractErr) = await contractRepo.getContractById(
      event.id,
    );
    if (contractErr != null) {
      emit(state.copyWith(isLoading: false, errorMessage: contractErr));
      return;
    }
    if (contract == null) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Contract not found'),
      );
      return;
    }
    final allClients = clients ?? [];
    final selectedClient = allClients
        .where((c) => c.id == contract.clientId)
        .firstOrNull;

    emit(
      ContractFormState.initial(
        editingId: contract.id,
        contractId: contract.contractId,
        selectedClient: selectedClient,
        clients: allClients,
        contractType: contract.contractType,
        startDate: contract.startDate,
        endDate: contract.endDate,
        status: contract.status,
        paymentStatus: contract.paymentStatus,
        notes: contract.notes ?? '',
      ),
    );
  }

  Future<void> _onSubmitted(Emitter<ContractFormState> emit) async {
    if (state.contractId.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Contract ID is required'));
      return;
    }
    if (state.selectedClient == null) {
      emit(state.copyWith(errorMessage: 'Please select a client'));
      return;
    }
    if (state.startDate == null) {
      emit(state.copyWith(errorMessage: 'Start date is required'));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final payload = <String, dynamic>{
      'contractId': state.contractId.trim(),
      'clientId': state.selectedClient!.id,
      'contractType': state.contractType,
      'startDate': state.startDate!.toIso8601String(),
      if (state.endDate != null) 'endDate': state.endDate!.toIso8601String(),
      'status': state.status,
      'paymentStatus': state.paymentStatus,
      if (state.notes.trim().isNotEmpty) 'notes': state.notes.trim(),
      'createdBy': await authRepo.currentEmail() ?? 'unknown',
    };

    try {
      if (state.editingId != null) {
        await contractRepo.updateContract(state.editingId!, payload);
      } else {
        await contractRepo.addContract(payload);
      }
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
