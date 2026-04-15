import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:flutter/material.dart';

class ScreenDialogLoadingIndicator extends StatelessWidget {
  const ScreenDialogLoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: LoadingIndicator(),
      ),
    );
  }
}
