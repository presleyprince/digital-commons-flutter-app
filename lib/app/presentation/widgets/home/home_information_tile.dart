import 'package:digital_shores/app/domain/entities/information.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/image_with_placeholder.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/parse_date.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeInformationTile extends StatelessWidget {
  const HomeInformationTile({
    super.key,
    required this.information,
  });

  final Information information;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Provider.of<InformationNotifier>(context, listen: false).setInformationDetail(information);
        router.push('/home/information/detail');
      },
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.grey.withValues(alpha: 0.3),
      highlightColor: Colors.grey.withValues(alpha: 0.1),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ImageWithPlaceholder(
                  url: information.imageUrl,
                  width: 180,
                  height: 120,
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kDefaultRadius / 2),
                      color: color.primary,
                    ),
                    child: Text(
                      information.category.label,
                      style: kTitle7TextStyle.copyWith(color: color.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    information.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: kTitle6TextStyle,
                  ),
                  SizedBox(height: 4),
                  Text(
                    ParseDate.toText(information.createdAt),
                    style: kTitle7TextStyle.copyWith(color: kGreyColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
