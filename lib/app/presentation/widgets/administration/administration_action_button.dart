import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdministrationActionButton extends StatelessWidget {
  const AdministrationActionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        children: [
          PrimaryElevatedButton(
            text: 'Segarkan',
            onPressed: Provider.of<AdministrationNotifier>(context, listen: false).syncDocuments,
          ),
          const SizedBox(height: 12),
          PrimaryElevatedButton(
            text: 'Tambah Berkas',
            onPressed: () => router.push('/home/administration/add'),
          ),
        ],
      ),
    );
  }
}
