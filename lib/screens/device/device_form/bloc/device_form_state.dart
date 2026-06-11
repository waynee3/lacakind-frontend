part of 'device_form_bloc.dart';

@freezed
sealed class DeviceFormState with _$DeviceFormState {
  const factory DeviceFormState.initial({
    String? editingId,
    String? editingSerial,
    @Default('') String serialNumber,
    @Default('') String modelType,
    DeviceStatus? status,
    @Default('') String location,
    @Default('') String supplier,
    @Default('') String batchNumber,
    @Default('') String cost,
    DateTime? purchaseDate,
    DateTime? activationDate,
    DateTime? warrantyExpiry,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
    DeviceModel? savedDevice,
  }) = _Initial;
}
 