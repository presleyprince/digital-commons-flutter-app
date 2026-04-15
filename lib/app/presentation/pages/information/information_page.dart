import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/information/information_action_button.dart';
import 'package:digital_shores/app/presentation/widgets/information/information_filter.dart';
import 'package:digital_shores/app/presentation/widgets/information/information_tile.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformationPage extends StatelessWidget {
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
