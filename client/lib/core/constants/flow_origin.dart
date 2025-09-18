/// Represents the origin/source of navigation to a screen
/// Used to determine appropriate behavior based on where the user came from
enum FlowOrigin {
  /// User came from the intro screen
  intro,

  /// User came from the feed (tab navigation)
  feed,

  /// User came from status lookup page
  statusLookup,

  /// Unknown or default origin
  unknown,
}

/// Extension to provide string representation for debugging
extension FlowOriginExtension on FlowOrigin {
  String get displayName {
    switch (this) {
      case FlowOrigin.intro:
        return 'intro';
      case FlowOrigin.feed:
        return 'feed';
      case FlowOrigin.statusLookup:
        return 'statusLookup';
      case FlowOrigin.unknown:
        return 'unknown';
    }
  }
}
