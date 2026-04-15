// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SeaDiscussionPage extends StatelessWidget {
  const SeaDiscussionPage({super.key});

  Future<void> _launchUrl(BuildContext context) async {
    final Uri url = Uri.parse(kSeaDiscussionUrl);
    if (!await launchUrl(url)) {
      CustomSnackbar.alert(context, 'Gagal membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: TransparentAppBar(title: 'Bincang Laut'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                  image: DecorationImage(
                    image: AssetImage(
                      R.ASSETS_IMAGES_BEACH_PNG,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: kDefaultPadding),
              Text(
                'Dapatkan informasi terbaru, berdiskusi dengan sesama penyuluh, dan berbagi pengalaman di komunitas WhatsApp Digital Shores. Mari bersama membangun jaringan yang lebih kuat!',
                textAlign: TextAlign.justify,
                style: kSubtitle4TextStyle,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_box_rounded, color: color.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Update informasi terbaru',
                            style: kSubtitle4TextStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_box_rounded, color: color.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Diskusi interaktif dengan penyuluh lain',
                            style: kSubtitle4TextStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_box_rounded, color: color.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Akses lebih cepat ke sumber daya',
                            style: kSubtitle4TextStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kDefaultPadding),
                    PrimaryElevatedButton(
                      text: 'Gabung ke Komunitas',
                      size: const Size(double.infinity, 62),
                      onPressed: () => _launchUrl(context),
                      short: true,
                      image: R.ASSETS_ICONS_WHATSAPP_PNG,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
