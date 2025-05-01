
/// Defines the types of users in the application.
///
/// Represents the two possible user roles: [farmer] and [consumer].

enum UserType { farmer, consumer }

/// Provides utility methods for the [UserType] enum.
///
/// Includes methods to get the string name of a [UserType] and to parse a string
/// into a [UserType] value.

extension UserTypeExtension on UserType {

  /// Gets the string representation of the [UserType].
  ///
  /// Returns the enum value's name in lowercase (e.g., 'farmer' or 'consumer').
  ///
  /// Returns:
  ///   A [String] representing the name of the [UserType].

  String get name => toString().split('.').last;

  /// Converts a string to a [UserType] value.
  ///
  /// Matches the input string (case-insensitive) to a [UserType] name. Returns
  /// [UserType.consumer] if no match is found.
  ///
  /// Parameters:
  ///   - value: The string to convert to a [UserType].
  ///
  /// Returns:
  ///   The corresponding [UserType] value.

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => UserType.consumer,
    );
  }
}
