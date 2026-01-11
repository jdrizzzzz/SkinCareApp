import '../models/user_profile.dart';

class UserProfileStore {
  UserProfileStore._();
  static final UserProfileStore instance = UserProfileStore._();

  UserProfile? _profile;

  UserProfile? get profile => _profile;

  bool get hasProfile => _profile != null;

  void setProfile(UserProfile profile) {
    _profile = profile;
  }

  void clear() {
    _profile = null;
  }
}