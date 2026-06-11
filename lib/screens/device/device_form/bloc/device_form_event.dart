part of 'device_form_bloc.dart';

@freezed
sealed class DeviceFormEvent with _$DeviceFormEvent {
  const factory DeviceFormEvent.started() = _Started;
  const factory DeviceFormEvent.startedEdit(String serialNumber) = _StartedEdit;
  const factory DeviceFormEvent.serialNumberChanged(String value) = _SerialNumberChanged;
  const factory DeviceFormEvent.modelTypeChanged(String value) = _ModelTypeChanged;
  const factory DeviceFormEvent.statusChanged(DeviceStatus? value) = _StatusChanged;
  const factory DeviceFormEvent.locationChanged(String value) = _LocationChanged;
  const factory DeviceFormEvent.supplierChanged(String value) = _SupplierChanged;
  const factory DeviceFormEvent.batchNumberChanged(String value) = _BatchNumberChanged;
  const factory DeviceFormEvent.costChanged(String value) = _CostChanged;
  const factory DeviceFormEvent.purchaseDateChanged(DateTime? value) = _PurchaseDateChanged;
  const factory DeviceFormEvent.activationDateChanged(DateTime? value) = _ActivationDateChanged;
  const factory DeviceFormEvent.warrantyExpiryChanged(DateTime? value) = _WarrantyExpiryChanged;
  const factory DeviceFormEvent.submitted() = _Submitted;
}
 