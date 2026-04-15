import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/image_with_placeholder.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/parse_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

class InformationDetailPage extends StatefulWidget {
  const InformationDetailPage({super.key});

  @override
  State<InformationDetailPage> createState() => _InformationDetailPageState();
}

class _InformationDetailPageState extends State<InformationDetailPage> {
  late InformationNotifier notifier;
  late QuillController controller;

  @override
  void initState() {
    notifier = Provider.of<InformationNotifier>(context, listen: false);
    controller = QuillController(
      document: notifier.informationDetail!.content,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    notifier.clearInformationDetail();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final information = Provider.of<InformationNotifier>(context, listen: false).informationDetail!;
    return Scaffold(
      appBar: TransparentAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                information.title,
                style: kTitle4TextStyle,
              ),
              const SizedBox(height: kDefaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    information.author,
                  ),
                  Text(
                    ParseDate.toText(information.updatedAt),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ImageWithPlaceholder(
                url: information.imageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 12),
              QuillEditor.basic(
                controller: controller,
              ),
              const SizedBox(height: kDefaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
