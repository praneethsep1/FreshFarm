enum UserType { farmer, consumer }

extension UserTypeExtension on UserType {
  String get name => toString().split('.').last;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => UserType.consumer,
    );
  }
}
