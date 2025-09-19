/// Domain value objects with validation
/// These replace primitive string types to provide type safety and validation

import 'validation_utils.dart';

/// Application ID for organization verification
class ApplicationId {
  final String value;

  ApplicationId(this.value) {
    ValidationUtils.validateApplicationId(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApplicationId && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Invite code for organization verification
class InviteCode {
  final String value;

  InviteCode(this.value) {
    ValidationUtils.validateInviteCode(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is InviteCode && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Username for authentication
class Username {
  final String value;

  Username(this.value) {
    ValidationUtils.validateUsername(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Username && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Password for authentication
class Password {
  final String value;

  Password(this.value) {
    ValidationUtils.validatePassword(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Password && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Country code (ISO 3166-1 alpha-2)
class Country {
  final String value;

  Country(this.value) {
    ValidationUtils.validateCountryCode(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Country && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Organization name
class OrganizationName {
  final String value;

  OrganizationName(this.value) {
    ValidationUtils.validateOrganizationName(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrganizationName && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Social media platform
class SocialMediaPlatform {
  final String value;

  SocialMediaPlatform(this.value) {
    ValidationUtils.validateSocialMediaPlatform(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialMediaPlatform && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Social media handle
class SocialMediaHandle {
  final String value;

  SocialMediaHandle(this.value) {
    ValidationUtils.validateSocialMediaHandle(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialMediaHandle && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Picture URL
class PictureUrl {
  final String value;

  PictureUrl(this.value) {
    ValidationUtils.validatePictureUrl(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PictureUrl && other.value == value);

  @override
  int get hashCode => value.hashCode;
}
