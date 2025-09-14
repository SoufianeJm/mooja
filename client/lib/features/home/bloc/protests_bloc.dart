import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/protest_model.dart';
import 'protests_event.dart';
import 'protests_state.dart';

/// BLoC for managing protests data and state
class ProtestsBloc extends Bloc<ProtestsEvent, ProtestsState> {
  ProtestsBloc({required ApiService apiService})
    : _apiService = apiService,
      super(const ProtestsInitial()) {
    on<LoadProtests>(_onLoadProtests);
    on<LoadMoreProtests>(_onLoadMoreProtests);
    on<FilterByCountry>(_onFilterByCountry);
    on<ClearProtests>(_onClearProtests);
  }

  final ApiService _apiService;

  /// Load protests from API
  Future<void> _onLoadProtests(
    LoadProtests event,
    Emitter<ProtestsState> emit,
  ) async {
    try {
      // Check if BLoC is still active before emitting
      if (!isClosed) {
        emit(const ProtestsLoading());
      }

      final result = await _apiService.getProtests(
        country: event.country,
        limit: 20,
      );

      // Group protests by date
      final groupedProtests = _groupProtestsByDate(result.data);

      // Check again after async operation
      if (!isClosed) {
        emit(
          ProtestsLoaded(
            protests: result.data,
            groupedProtests: groupedProtests,
            nextCursor: result.nextCursor,
            hasNextPage: result.hasNextPage,
            selectedCountry: event.country,
          ),
        );
      }
    } catch (e) {
      // Fallback to global feed on invalid country
      if (e is ApiError && event.country != null) {
        final status = e.statusCode ?? 0;
        if (status == 400 || status == 404 || status == 422) {
          // Try loading without country filter
          if (!isClosed) {
            add(const LoadProtests(refresh: true));
          }
          return;
        }
      }

      // Check before emitting error state
      if (!isClosed) {
        emit(ProtestsError(e.toString()));
      }
    }
  }

  /// Load more protests for pagination
  Future<void> _onLoadMoreProtests(
    LoadMoreProtests event,
    Emitter<ProtestsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProtestsLoaded || currentState.isLoadingMore) return;

    try {
      // Check before emitting loading state
      if (!isClosed) {
        emit(currentState.copyWith(isLoadingMore: true));
      }

      final result = await _apiService.getProtests(
        country: currentState.selectedCountry,
        cursor: currentState.nextCursor,
        limit: 20,
      );

      // Combine with existing protests
      final allProtests = [...currentState.protests, ...result.data];
      final groupedProtests = _groupProtestsByDate(allProtests);

      // Check again after async operation
      if (!isClosed) {
        emit(
          currentState.copyWith(
            protests: allProtests,
            groupedProtests: groupedProtests,
            nextCursor: result.nextCursor,
            hasNextPage: result.hasNextPage,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      // Check before emitting error states
      if (!isClosed) {
        emit(currentState.copyWith(isLoadingMore: false));
        emit(ProtestsError(e.toString()));
      }
    }
  }

  /// Filter protests by country
  Future<void> _onFilterByCountry(
    FilterByCountry event,
    Emitter<ProtestsState> emit,
  ) async {
    // Load protests with new country filter
    add(LoadProtests(country: event.country));
  }

  /// Clear all protests
  void _onClearProtests(ClearProtests event, Emitter<ProtestsState> emit) {
    if (!isClosed) {
      emit(const ProtestsInitial());
    }
  }

  /// Group protests by date for display
  Map<DateTime, List<Protest>> _groupProtestsByDate(List<Protest> protests) {
    final Map<DateTime, List<Protest>> grouped = {};

    for (final protest in protests) {
      // Group by date (ignoring time)
      final date = DateTime(
        protest.dateTime.year,
        protest.dateTime.month,
        protest.dateTime.day,
      );

      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(protest);
    }

    // Sort protests within each date group by time
    for (final date in grouped.keys) {
      grouped[date]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }

    return grouped;
  }
}
