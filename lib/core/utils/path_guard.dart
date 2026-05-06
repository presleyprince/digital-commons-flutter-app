import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PathGuard {
  static void adminGuard(BuildContext context) {
    final isAdmin = Provider.of<AuthNotifier>(context, listen: false).isAdmin();
    if (!isAdmin) {
      Future.microtask(() => router.pop());
    }
  }
}
