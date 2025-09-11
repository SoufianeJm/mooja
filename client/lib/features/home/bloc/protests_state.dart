import 'package:equatable/equatable.dart';
import '../../../core/models/protest_model.dart';

/// States for the ProtestsBloc
abstract class ProtestsState extends Equatable {
  const ProtestsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProtestsInitial extends ProtestsState {
  const ProtestsInitial();
}

/// Loading state
class ProtestsLoading extends ProtestsState {
  const ProtestsLoading();
}

/// Loaded state with protests data
class ProtestsLoaded extends ProtestsState {
  const ProtestsLoaded({
    required this.protests,
    required this.groupedProtests,
    this.nextCursor,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.selectedCountry,
  });

  final List<Protest> protests;
  final Map<DateTime, List<Protest>> groupedProtests;
  final String? nextCursor;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String? selectedCountry;

  @override
  List<Object?> get props => [
    protests,
    groupedProtests,
    nextCursor,
    hasNextPage,
    isLoadingMore,
    selectedCountry,
  ];

  /// Create a copy with updated values
  ProtestsLoaded copyWith({
    List<Protest>? protests,
    Map<DateTime, List<Protest>>? groupedProtests,
    String? nextCursor,
    bool? hasNextPage,
    bool? isLoadingMore,
    String? selectedCountry,
  }) {
    return ProtestsLoaded(
      protests: protests ?? this.protests,
      groupedProtests: groupedProtests ?? this.groupedProtests,
      nextCursor: nextCursor ?? this.nextCursor,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

/// Error state
class ProtestsError extends ProtestsState {
  const ProtestsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
