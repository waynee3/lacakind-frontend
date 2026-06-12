import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/dashboard_model.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';
part 'dashboard_bloc.freezed.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState.initial()) {
    on<DashboardEvent>((event, emit) async {
      switch (event) {
        case _Started():
        case _Refresh():
          await _onLoad(emit);
      }
    });
  }
 
  Future<void> _onLoad(Emitter<DashboardState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final (data, error) = await dashboardRepo.getStats();
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(isLoading: false, data: data));
  }
}
 