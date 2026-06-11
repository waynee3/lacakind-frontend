part of 'client_list_bloc.dart';

@freezed
sealed class ClientListEvent with _$ClientListEvent {
  const factory ClientListEvent.started({
    String? clientName,
    String? email,
    String? phone,
    String? location,
    String? contactPerson,
  }) = _Started;
  const factory ClientListEvent.onSearch(String query) = _OnSearch;
  const factory ClientListEvent.loadMore() = _LoadMore;
  const factory ClientListEvent.deleteClient(String id) =
      _DeleteClient;
}
