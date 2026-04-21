import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/information/information_action_button.dart';
import 'package:digital_shores/app/presentation/widgets/information/information_filter.dart';
import 'package:digital_shores/app/presentation/widgets/information/information_tile.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart'; // added 4 imports from sea_discussion to merge the features
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/const/resource.dart';

class InformationPage extends StatelessWidget {
  
  //added from sea_discussion to merge the whatsapp button 
    Future<void> _launchUrl(BuildContext context) async {
    final Uri url = Uri.parse(kSeaDiscussionUrl);
    if (!await launchUrl(url)) {
      CustomSnackbar.alert(context, 'Gagal membuka WhatsApp');
    }
  }
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<InformationNotifier>(context, listen: false);
    notifier.init();
    return Scaffold(
      appBar: TransparentAppBar(title: 'Informasi'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InformationFilter(notifier: notifier),

              PrimaryElevatedButton( // moved from sea_discussion to merge the whatsapp feature
                text: 'Gabung ke Komunitas',
                size: const Size(double.infinity, 62),
                onPressed: () => _launchUrl(context),
                short: true,
                image: R.ASSETS_ICONS_WHATSAPP_PNG,
                    ),
              
              const SizedBox(height: 16), // added to give a gap between the buttons

              InformationActionButton(),
              Consumer<InformationNotifier>(
                builder: (context, notifier, child) {
                  final datas = notifier.getInformations();
                  return ListView.separated(
                    itemCount: datas.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return InformationTile(
                        key: ValueKey(datas[index].id),
                        information: datas[index],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
