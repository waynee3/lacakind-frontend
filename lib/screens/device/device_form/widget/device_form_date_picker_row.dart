import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/screens/device/device_form/bloc/device_form_bloc.dart';
import 'package:lacakind_frontend/widgets/date_picker_field.dart';

class DeviceFormDatePickerRow extends StatelessWidget {
  const DeviceFormDatePickerRow({super.key});

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initial,
    void Function(DateTime?) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceFormBloc, DeviceFormState>(
      buildWhen: (previous, current) =>
          previous.purchaseDate != current.purchaseDate ||
          previous.activationDate != current.activationDate ||
          previous.warrantyExpiry != current.warrantyExpiry,
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: 'Purchase Date',
                value: state.purchaseDate,
                onTap: () => _pickDate(
                  context,
                  state.purchaseDate,
                  (d) => context.read<DeviceFormBloc>().add(DeviceFormEvent.purchaseDateChanged(d)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DatePickerField(
                label: 'Activation Date',
                value: state.activationDate,
                onTap: () => _pickDate(
                  context,
                  state.activationDate,
                  (d) => context.read<DeviceFormBloc>().add(DeviceFormEvent.activationDateChanged(d)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DatePickerField(
                label: 'Warranty Expiry',
                value: state.warrantyExpiry,
                onTap: () => _pickDate(
                  context,
                  state.warrantyExpiry,
                  (d) => context.read<DeviceFormBloc>().add(DeviceFormEvent.warrantyExpiryChanged(d)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
