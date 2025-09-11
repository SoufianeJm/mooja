import 'package:equatable/equatable.dart';

/// Events for the ProtestsBloc
abstract class ProtestsEvent extends Equatable {
  const ProtestsEvent();

  @override
  List<Object?> get props => [];
}

/// Load protests from API
class LoadProtests extends ProtestsEvent {
  const LoadProtests({this.refresh = false, this.country});

  final bool refresh;
  final String? country;

  @override
  List<Object?> get props => [refresh, country];
}

/// Load more protests for pagination
class LoadMoreProtests extends ProtestsEvent {
  const LoadMoreProtests();
}

/// Filter protests by country
class FilterByCountry extends ProtestsEvent {
  const FilterByCountry(this.country);

  final String? country;

  @override
  List<Object?> get props => [country];
}

/// Clear all protests (for logout, etc.)
class ClearProtests extends ProtestsEvent {
  const ClearProtests();
}
