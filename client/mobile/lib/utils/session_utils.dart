import 'dart:async';

import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<AuthResult> signOut(BuildContext context) async {
  final session = _Session.of(context);
  final result = await session.auth.logout();
  await session.clear();
  resetToLogin();
  return result;
}

Future<void> endSession(BuildContext context) async {
  final session = _Session.of(context);
  await session.clear();
  resetToLogin();
}

void handleUnauthorized() {
  final context = appNavigatorKey.currentContext;
  if (context != null) {
    unawaited(_Session.of(context).clear());
  }
  redirectToLogin();
}

class _Session {
  const _Session({
    required this.auth,
    required this.profile,
    required this.messages,
  });

  factory _Session.of(BuildContext context) => _Session(
    auth: Provider.of<AuthProvider>(context, listen: false),
    profile: Provider.of<ProfileProvider>(context, listen: false),
    messages: Provider.of<MessageProvider>(context, listen: false),
  );

  final AuthProvider auth;
  final ProfileProvider profile;
  final MessageProvider messages;

  Future<void> clear() async {
    auth.clearSession();
    profile.clear();
    await messages.clear();
  }
}
