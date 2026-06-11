import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/client_model.dart';
import 'package:lacakind_frontend/data/repositories/client_repository.dart';

part 'client_list_event.dart';
part 'client_list_state.dart';
part 'client_list_bloc.freezed.dart';

class ClientListBloc extends Bloc<ClientListEvent, ClientListState> {
  String? _clientName;
  String? _email;
  String? _phone;
  String? _location;
  String? _contactPerson;

  ClientListBloc() : super(const ClientListState.initial()) {
    on<ClientListEvent>((event, emit) async {
      switch (event) {
        case _Started():
          await _onStarted(event, emit);
        case _OnSearch():
          await _onSearched(event, emit);
        case _LoadMore():
          await _onLoadMore(emit);
        case _DeleteClient():
          await _onDeleteClient(event, emit);
      }
    });
  }

  Future<(List<ClientModel>?, String?)> _fetch(int page) =>
      clientRepo.getClients(
        clientName: _clientName,
        email: _email,
        phone: _phone,
        location: _location,
        contactPerson: _contactPerson,
        page: page,
      );

  bool _reachedEnd(List<ClientModel> page) =>
      page.length < ClientRepository.pageSize;

  Future<void> _onStarted(_Started event, Emitter<ClientListState> emit) async {
    _clientName = event.clientName;
    _email = event.email;
    _phone = event.phone;
    _location = event.location;
    _contactPerson = event.contactPerson;

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentPage: 1,
        hasMore: true,
        clients: [],
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
        clients: data!,
        currentPage: 1,
        hasMore: !_reachedEnd(data),
      ),
    );
  }

  Future<void> _onSearched(
    _OnSearch event,
    Emitter<ClientListState> emit,
  ) async {
    _clientName = event.query.isEmpty ? null : event.query;
    _email = null;
    _phone = null;
    _location = null;
    _contactPerson = null;

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentPage: 1,
        hasMore: true,
        clients: [],
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
        clients: data!,
        currentPage: 1,
        hasMore: !_reachedEnd(data),
      ),
    );
  }

  Future<void> _onLoadMore(Emitter<ClientListState> emit) async {
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
        clients: [...state.clients, ...data!],
        currentPage: nextPage,
        hasMore: !_reachedEnd(data),
      ),
    );
  }

  Future<void> _onDeleteClient(
    _DeleteClient event,
    Emitter<ClientListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final error = await clientRepo.deleteClient(event.id);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    add(const ClientListEvent.started());
    emit(state.copyWith(isSuccess: true, successMessage: 'Client deleted'));
  }
}
