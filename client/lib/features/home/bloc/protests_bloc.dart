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
      // If not refreshing, show loading state
      if (!event.refresh) {
        emit(const ProtestsLoading());
      }

      final result = await _apiService.getProtests(
        country: event.country,
        limit: 20, // Load 20 protests at a time
      );

      // Group protests by date
      final groupedProtests = _groupProtestsByDate(result.data);

      emit(
        ProtestsLoaded(
          protests: result.data,
          groupedProtests: groupedProtests,
          nextCursor: result.nextCursor,
          hasNextPage: result.hasNextPage,
          selectedCountry: event.country,
        ),
      );
    } catch (e) {
      emit(ProtestsError(e.toString()));
    }
  }

  /// Load more protests for pagination
  Future<void> _onLoadMoreProtests(
    LoadMoreProtests event,
    Emitter<ProtestsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProtestsLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasNextPage) {
      return;
    }

    try {
      // Set loading more state
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await _apiService.getProtests(
        cursor: currentState.nextCursor,
        country: currentState.selectedCountry,
        limit: 20,
      );

      // Combine with existing protests
      final allProtests = [...currentState.protests, ...result.data];
      final groupedProtests = _groupProtestsByDate(allProtests);

      emit(
        ProtestsLoaded(
          protests: allProtests,
          groupedProtests: groupedProtests,
          nextCursor: result.nextCursor,
          hasNextPage: result.hasNextPage,
          selectedCountry: currentState.selectedCountry,
        ),
      );
    } catch (e) {
      // Revert loading state on error
      emit(currentState.copyWith(isLoadingMore: false));
      emit(ProtestsError(e.toString()));
    }
  }

  /// Filter protests by country
  Future<void> _onFilterByCountry(
    FilterByCountry event,
    Emitter<ProtestsState> emit,
  ) async {
    // If country is the same, do nothing
    final currentState = state;
    if (currentState is ProtestsLoaded &&
        currentState.selectedCountry == event.country) {
      return;
    }

    // Load protests with new country filter
    add(LoadProtests(country: event.country));
  }

  /// Clear all protests
  void _onClearProtests(ClearProtests event, Emitter<ProtestsState> emit) {
    emit(const ProtestsInitial());
  }

  /// Group protests by date for UI display
  Map<DateTime, List<Protest>> _groupProtestsByDate(List<Protest> protests) {
    final Map<DateTime, List<Protest>> grouped = {};

    for (final protest in protests) {
      // Create a date key (without time)
      final dateKey = DateTime(
        protest.dateTime.year,
        protest.dateTime.month,
        protest.dateTime.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(protest);
    }

    // Sort each day's protests by time
    grouped.forEach((date, protests) {
      protests.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });

    // Return as sorted map (by date)
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <DateTime, List<Protest>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }
}
