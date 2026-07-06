/// Role used to determine which shell and permissions are available.
enum UserRole { manager, logistics }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.manager:
        return 'Manager';
      case UserRole.logistics:
        return 'Logistics Staff';
    }
  }
}
