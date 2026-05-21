import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digital_shores/core/enums.dart';

class PathGuard {
  static void adminGuard(BuildContext context) {
    final isAdmin = Provider.of<AuthNotifier>(context, listen: false).userData?.isAdmin ?? false;
    if (!isAdmin) {
      Future.microtask(() => router.pop());
    }
  }
// added new guard that allows only secretaries and admins to access certain pages
    static void secretaryGuard(BuildContext context) {                                        
    final role = Provider.of<AuthNotifier>(context, listen: false).userData?.role;         // gets the role of the current user
    if (role != UserRole.secretary && role != UserRole.admin) {                              // if user if not a secretary or admin remove them
      Future.microtask(() => router.pop());                                                 // send them back to the previous page
    }                                                                                       
  }           
}
