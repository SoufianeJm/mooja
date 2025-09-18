import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

class VerificationState {
  final String? countryCode;
  final String? orgName;
  final String? socialPlatform;
  final String? socialHandle;
  final bool isSubmitting;
  final String? errorMessage;

  const VerificationState({
    this.countryCode,
    this.orgName,
    this.socialPlatform,
    this.socialHandle,
    this.isSubmitting = false,
    this.errorMessage,
  });

  VerificationState copyWith({
    String? countryCode,
    String? orgName,
    String? socialPlatform,
    String? socialHandle,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return VerificationState(
      countryCode: countryCode ?? this.countryCode,
      orgName: orgName ?? this.orgName,
      socialPlatform: socialPlatform ?? this.socialPlatform,
      socialHandle: socialHandle ?? this.socialHandle,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class VerificationCubit extends Cubit<VerificationState> {
  final ApiService api;
  final StorageService storage;

  VerificationCubit(this.api, this.storage) : super(const VerificationState());

  void reset() {
    emit(const VerificationState());
  }

  Future<void> setCountry(String code) async {
    await storage.saveSelectedCountryCode(code);
    emit(state.copyWith(countryCode: code, errorMessage: null));
  }

  Future<void> setOrgName(String name) async {
    await storage.savePendingOrgName(name);
    emit(state.copyWith(orgName: name, errorMessage: null));
  }

  Future<void> setPlatform(String platform) async {
    await storage.savePendingSocialPlatform(platform);
    emit(state.copyWith(socialPlatform: platform, errorMessage: null));
  }

  Future<void> setHandle(String handle) async {
    final normalized = handle.startsWith('@') ? handle : '@$handle';
    await storage.savePendingSocialHandle(normalized);
    emit(state.copyWith(socialHandle: normalized, errorMessage: null));
  }

  Future<void> submit() async {
    final country =
        state.countryCode ?? await storage.readSelectedCountryCode();
    final name = state.orgName ?? await storage.readPendingOrgName();
    final platform =
        state.socialPlatform ?? await storage.readPendingSocialPlatform();
    final handle = state.socialHandle;

    if (country == null || country.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please choose your country first.'));
      return;
    }
    if (name == null || name.trim().length < 2) {
      emit(
        state.copyWith(errorMessage: 'Please enter a valid organization name.'),
      );
      return;
    }
    if (platform == null || platform.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please choose a social platform.'));
      return;
    }
    // Do not enforce format validation for social handle; allow any input

    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final normalizedHandle = (handle ?? '').startsWith('@')
          ? (handle ?? '')
          : '@${handle ?? ''}';
      final result = await api.requestOrgVerification(
        name: name,
        country: country,
        socialMediaPlatform: platform,
        socialMediaHandle: normalizedHandle,
      );
      // Persist backend-generated identifiers for consistent status lookups
      final backendUsername = result['org']?['username'] as String?;
      final applicationId = result['org']?['id'] as String?;
      if (backendUsername != null && backendUsername.isNotEmpty) {
        await storage.savePendingOrgUsername(backendUsername);
      }
      if (applicationId != null && applicationId.isNotEmpty) {
        await storage.savePendingApplicationId(applicationId);
      }
      emit(state.copyWith(isSubmitting: false, errorMessage: null));
    } catch (e) {
      final message = e is ApiError
          ? e.message
          : 'Failed to submit application';
      emit(state.copyWith(isSubmitting: false, errorMessage: message));
    }
  }
}
