// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NeedHelpCard extends StatelessWidget {
  const NeedHelpCard({
    super.key,
  });

  Future<void> _launchUrl(BuildContext context) async {
    final Uri url = Uri.parse(kHelpUrl);
    if (!await launchUrl(url)) {
      CustomSnackbar.alert(context, 'Gagal membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      color: color.primary,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Butuh bantuan? ',
              style: kBodyTextStyle.copyWith(
                color: color.onPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _launchUrl(context),
              child: Text(
                'Hubungi Kami',
                style: kBodyTextStyle.copyWith(
                  color: color.onPrimary,
                  fontWeight: kFontweightBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
