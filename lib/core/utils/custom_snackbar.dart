// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  static alert(BuildContext context, String text) {
    Future.microtask(
      () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          backgroundColor: kDefaultErrorColor,
        ),
      ),
    );
  }

  static success(BuildContext context, String text) {
    Future.microtask(
      () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 14,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
