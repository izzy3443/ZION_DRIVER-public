import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import 'package:zion_driver_553/models/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, AppUser?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<AppUser?> {
  UserNotifier() : super(null);

  void setUser(AppUser user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  void updateName({required String firstName, required String lastName}) {
    if (state != null) {
      state = state!.copyWith(firstName: firstName, lastName: lastName);
    }
  }

  void updateSubscription({
    required DateTime expiry,
    required bool active,
  }) {
    if (state != null) {
      state = state!.copyWith(
        subscriptionExpiry: expiry,
        subscriptionActive: active,
      );
    }
  }
}
