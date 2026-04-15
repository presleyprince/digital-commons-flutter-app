import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class AdministrationSearchBox extends StatelessWidget {
  const AdministrationSearchBox({
    super.key,
    required this.notifier,
  });

  final AdministrationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textAlign: TextAlign.center,
              controller: notifier.searchController,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Cari Berkas',
                hintStyle: kSubtitle5TextStyle.copyWith(
                  color: color.onSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: color.secondary,
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.search,
            size: 24,
            color: color.primary,
          ),
        ],
      ),
    );
  }
}
