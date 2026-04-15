import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.red = false,
  });

  final bool red;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Center(
        child: CircularProgressIndicator(
          color: red ? kRedColor : null,
        ),
      ),
    );
  }
}
