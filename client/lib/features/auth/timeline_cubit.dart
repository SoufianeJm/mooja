import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/domain/domain_objects.dart';

// Timeline States
class TimelineState extends Equatable {
  final String status;
  final bool isLoading;
  final String? error;
  final String? applicationId;

  const TimelineState({
    this.status = 'pending',
    this.isLoading = false,
    this.error,
    this.applicationId,
  });

  TimelineState copyWith({
    String? status,
    bool? isLoading,
    String? error,
    String? applicationId,
  }) {
    return TimelineState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      applicationId: applicationId ?? this.applicationId,
    );
  }

  @override
  List<Object?> get props => [status, isLoading, error, applicationId];
}

// Timeline Cubit
class TimelineCubit extends Cubit<TimelineState> {
  final ApiService _apiService;
  final StorageService _storageService;

  TimelineCubit({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService,
       super(const TimelineState());

  /// Initialize and load status
  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Get application ID from storage
      final appId = await _storageService.readPendingApplicationId();

      if (appId == null || appId.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'No application found'));
        return;
      }

      // Fetch current status
      final status = await _apiService.getOrgStatusByApplicationId(
        ApplicationId(appId),
      );

      emit(
        state.copyWith(status: status, applicationId: appId, isLoading: false),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load status'));
    }
  }

  /// Refresh status from API
  Future<void> refreshStatus() async {
    final appId = state.applicationId;
    if (appId == null) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final status = await _apiService.getOrgStatusByApplicationId(
        ApplicationId(appId),
      );
      emit(state.copyWith(status: status, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to refresh status'));
    }
  }
}
