import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class SliderIndicator extends StatelessWidget {
  final int page;
  final int currentPage;

  const SliderIndicator({
    super.key,
    required this.page,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: page == currentPage ? kGreyColor : kLightGreyColor,
      ),
    );
  }
}
