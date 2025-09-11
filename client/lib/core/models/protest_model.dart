/// Data models matching the backend structure
/// These models are designed to be easily serializable and match the backend DTOs

class Organization {
  final String id;
  final String username;
  final String? name;
  final String? pictureUrl;
  final String? country;
  final String? verificationStatus;
  final String? socialMediaPlatform;
  final String? socialMediaHandle;

  const Organization({
    required this.id,
    required this.username,
    this.name,
    this.pictureUrl,
    this.country,
    this.verificationStatus,
    this.socialMediaPlatform,
    this.socialMediaHandle,
  });

  /// Factory constructor for creating from JSON
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String?,
      pictureUrl: json['pictureUrl'] as String?,
      country: json['country'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      socialMediaPlatform: json['socialMediaPlatform'] as String?,
      socialMediaHandle: json['socialMediaHandle'] as String?,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (name != null) 'name': name,
      if (pictureUrl != null) 'pictureUrl': pictureUrl,
      if (country != null) 'country': country,
      if (verificationStatus != null) 'verificationStatus': verificationStatus,
      if (socialMediaPlatform != null) 'socialMediaPlatform': socialMediaPlatform,
      if (socialMediaHandle != null) 'socialMediaHandle': socialMediaHandle,
    };
  }

  /// Get display name (fallback to username if name is null)
  String get displayName => name ?? username;
  
  /// Get organization type for display
  String get organizationType {
    // This could be enhanced based on actual business logic
    if (username.toLowerCase().contains('union')) return 'Worker union';
    if (username.toLowerCase().contains('student')) return 'Student organization';
    return 'Non profit organization';
  }
}

class Protest {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? country;
  final String? city;
  final String location;
  final String? pictureUrl;
  final String? description;
  final String organizerId;
  final Organization? organizer;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Protest({
    required this.id,
    required this.title,
    required this.dateTime,
    this.country,
    this.city,
    required this.location,
    this.pictureUrl,
    this.description,
    required this.organizerId,
    this.organizer,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for creating from JSON
  factory Protest.fromJson(Map<String, dynamic> json) {
    return Protest(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      country: json['country'] as String?,
      city: json['city'] as String?,
      location: json['location'] as String,
      pictureUrl: json['pictureUrl'] as String?,
      description: json['description'] as String?,
      organizerId: json['organizerId'] as String,
      organizer: json['organizer'] != null
          ? Organization.fromJson(json['organizer'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      'location': location,
      if (pictureUrl != null) 'pictureUrl': pictureUrl,
      if (description != null) 'description': description,
      'organizerId': organizerId,
      if (organizer != null) 'organizer': organizer!.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get formatted time (e.g., "23:00")
  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted date (e.g., "August 29")
  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  /// Get short formatted date (e.g., "29 Aug")
  String get shortFormattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }

  /// Check if protest is today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// Check if protest is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
           dateTime.month == tomorrow.month &&
           dateTime.day == tomorrow.day;
  }

  /// Get relative day text
  String get relativeDayText {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    return formattedDate;
  }
}

/// Paginated response wrapper
class PaginatedProtests {
  final List<Protest> data;
  final String? nextCursor;
  final bool hasNextPage;

  const PaginatedProtests({
    required this.data,
    this.nextCursor,
    required this.hasNextPage,
  });

  factory PaginatedProtests.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List)
        .map((item) => Protest.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return PaginatedProtests(
      data: data,
      nextCursor: json['nextCursor'] as String?,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}
