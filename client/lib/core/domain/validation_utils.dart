/// Shared validation utilities and patterns for domain objects
/// Centralizes common validation logic to avoid duplication

class ValidationUtils {
  // Private constructor to prevent instantiation
  ValidationUtils._();

  /// Common regex patterns
  static const String alphanumericPattern = r'^[a-zA-Z0-9]+$';
  static const String alphanumericWithUnderscorePattern = r'^[a-zA-Z0-9_]+$';
  static const String alphanumericWithHyphenUnderscorePattern =
      r'^[a-zA-Z0-9_-]+$';
  static const String socialMediaHandlePattern = r'^@?[a-zA-Z0-9_-]+$';
  static const String uppercaseAlphanumericPattern = r'^[A-Z0-9]+$';
  static const String isoCountryCodePattern = r'^[A-Z]{2}$';
  static const String httpUrlPattern = r'^https?://';
  static const String organizationNamePattern = r'^[a-zA-Z0-9\s\.,\-&()]+$';

  /// Password strength pattern (must contain lowercase, uppercase, and number)
  static const String passwordStrengthPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)';

  /// Allowed social media platforms
  static const List<String> allowedSocialMediaPlatforms = [
    'twitter',
    'facebook',
    'instagram',
    'linkedin',
    'youtube',
    'tiktok',
  ];

  /// Common validation methods
  static void validateNotEmpty(String value, String fieldName) {
    if (value.isEmpty) {
      throw ArgumentError('$fieldName cannot be empty');
    }
  }

  static void validateLength(
    String value,
    String fieldName,
    int minLength,
    int maxLength,
  ) {
    if (value.length < minLength) {
      throw ArgumentError('$fieldName must be at least $minLength characters');
    }
    if (value.length > maxLength) {
      throw ArgumentError('$fieldName must be at most $maxLength characters');
    }
  }

  static void validateExactLength(
    String value,
    String fieldName,
    int exactLength,
  ) {
    if (value.length != exactLength) {
      throw ArgumentError('$fieldName must be exactly $exactLength characters');
    }
  }

  static void validatePattern(
    String value,
    String fieldName,
    String pattern,
    String errorMessage,
  ) {
    if (!RegExp(pattern).hasMatch(value)) {
      throw ArgumentError(errorMessage);
    }
  }

  static void validateOneOf(
    String value,
    String fieldName,
    List<String> allowedValues,
  ) {
    if (!allowedValues.contains(value.toLowerCase())) {
      throw ArgumentError(
        'Invalid $fieldName. Allowed: ${allowedValues.join(', ')}',
      );
    }
  }

  /// Specific validation methods for common use cases
  static void validateApplicationId(String value) {
    validateNotEmpty(value, 'ApplicationId');
    validateLength(value, 'ApplicationId', 3, 50);
    validatePattern(
      value,
      'ApplicationId',
      alphanumericWithHyphenUnderscorePattern,
      'ApplicationId can only contain letters, numbers, hyphens, and underscores',
    );
  }

  static void validateInviteCode(String value) {
    validateNotEmpty(value, 'InviteCode');
    validateExactLength(value, 'InviteCode', 8);
    validatePattern(
      value,
      'InviteCode',
      uppercaseAlphanumericPattern,
      'InviteCode must contain only uppercase letters and numbers',
    );
  }

  static void validateUsername(String value) {
    validateNotEmpty(value, 'Username');
    validateLength(value, 'Username', 3, 30);
    validatePattern(
      value,
      'Username',
      alphanumericWithUnderscorePattern,
      'Username can only contain letters, numbers, and underscores',
    );
  }

  static void validatePassword(String value) {
    validateNotEmpty(value, 'Password');
    validateLength(value, 'Password', 8, 128);
    // Temporarily relaxed - only length requirement for now
    // validatePattern(
    //   value,
    //   'Password',
    //   passwordStrengthPattern,
    //   'Password must contain at least one lowercase letter, one uppercase letter, and one number',
    // );
  }

  static void validateCountryCode(String value) {
    validateNotEmpty(value, 'Country');
    validateExactLength(value, 'Country', 2);
    validatePattern(
      value,
      'Country',
      isoCountryCodePattern,
      'Country must be a valid 2-letter ISO code (e.g., US, CA, GB)',
    );
  }

  static void validateOrganizationName(String value) {
    validateNotEmpty(value, 'Organization name');
    validateLength(value, 'Organization name', 2, 100);
    validatePattern(
      value,
      'Organization name',
      organizationNamePattern,
      'Organization name contains invalid characters',
    );
  }

  static void validateSocialMediaPlatform(String value) {
    validateNotEmpty(value, 'Social media platform');
    validateOneOf(value, 'Social media platform', allowedSocialMediaPlatforms);
  }

  static void validateSocialMediaHandle(String value) {
    validateNotEmpty(value, 'Social media handle');
    validateLength(value, 'Social media handle', 1, 50);
    validatePattern(
      value,
      'Social media handle',
      socialMediaHandlePattern,
      'Social media handle can only contain letters, numbers, underscores, hyphens, and optionally start with @',
    );
  }

  static void validatePictureUrl(String value) {
    validateNotEmpty(value, 'Picture URL');
    validateLength(value, 'Picture URL', 1, 500);
    validatePattern(
      value,
      'Picture URL',
      httpUrlPattern,
      'Picture URL must start with http:// or https://',
    );
  }
}
