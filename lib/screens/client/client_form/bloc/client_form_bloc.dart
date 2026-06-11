import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';

part 'client_form_event.dart';
part 'client_form_state.dart';
part 'client_form_bloc.freezed.dart';

class ClientFormBloc extends Bloc<ClientFormEvent, ClientFormState> {
  ClientFormBloc() : super(const ClientFormState.initial()) {
    on<ClientFormEvent>((event, emit) async {
      switch (event) {
        case _Started():
          emit(const ClientFormState.initial());
        case _StartedEdit():
          await _onStartedEdit(event, emit);
        case _NameChanged():
          emit(state.copyWith(name: event.value));
        case _LocationChanged():
          emit(state.copyWith(location: event.value));
        case _ContactPersonChanged():
          emit(state.copyWith(contactPerson: event.value));
        case _EmailChanged():
          emit(state.copyWith(email: event.value));
        case _PhoneChanged():
          emit(state.copyWith(phone: event.value));
        case _AddressChanged():
          emit(state.copyWith(address: event.value));
        case _NotesChanged():
          emit(state.copyWith(notes: event.value));
        case _Submitted():
          await _onSubmitted(emit);
      }
    });
  }
 
  Future<void> _onStartedEdit(
    _StartedEdit event,
    Emitter<ClientFormState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final (clients, error) = await clientRepo.getClientById(event.id);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    final c = clients!;
    emit(ClientFormState.initial(
      editingId: c.id,
      name: c.name,
      location: c.location,
      contactPerson: c.contactPerson,
      email: c.email,
      phone: c.phone,
      address: c.address,
      notes: c.notes ?? '',
    ));
  }
 
  Future<void> _onSubmitted(Emitter<ClientFormState> emit) async {
    if (state.name.trim().isEmpty || state.location.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Name and location are required'));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: ''));
 
    final payload = <String, dynamic>{
      'name': state.name.trim(),
      'location': state.location.trim(),
      'contactPerson': state.contactPerson.trim(),
      'email': state.email.trim(),
      'phone': state.phone.trim(),
      'address': state.address.trim(),
      if (state.notes.trim().isNotEmpty) 'notes': state.notes.trim(),
    };
 
    try {
      if (state.editingId != null) {
        await clientRepo.updateClient(state.editingId!, payload);
      } else {
        await clientRepo.addClient(payload);
      }
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
