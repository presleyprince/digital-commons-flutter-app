import 'package:digital_shores/app/domain/entities/information.dart';
import 'package:digital_shores/app/presentation/provider/add_information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/image_with_placeholder.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/core/utils/parse_date.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformationTile extends StatelessWidget {
  const InformationTile({
    super.key,
    required this.information,
  });

  final Information information;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Provider.of<InformationNotifier>(context, listen: false).setInformationDetail(information);
        router.push('/home/information/detail');
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageWithPlaceholder(
              url: information.imageUrl,
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(kDefaultRadius),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: color.primary,
                          borderRadius: BorderRadius.circular(kDefaultRadius),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          information.category.label,
                          style: kTitle7TextStyle.copyWith(color: color.onPrimary),
                        ),
                      ),
                      Spacer(),
                      Provider.of<AuthNotifier>(context, listen: false).isAdmin()
                          ? Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Provider.of<AddInformationNotifier>(context, listen: false)
                                        .setSelectedData(information);
                                    router.push('/home/add-information');
                                  },
                                  child: Image.asset(
                                    R.ASSETS_ICONS_EDIT_PNG,
                                    color: color.primary,
                                    width: 24,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        // Get the appropriate notifier state and deleteData function
                                        return Consumer<AddInformationNotifier>(
                                          builder: (context, notifier, child) {
                                            final state = notifier.deleteDataState;
                                            // Handle state changes
                                            if (state.stateError()) {
                                              // Schedule in next frame to avoid build issues
                                              CustomSnackbar.alert(
                                                  dialogContext, state.failure!.message);
                                              Navigator.of(dialogContext)
                                                  .pop(); // Close dialog on error
                                            } else if (state.stateSuccess()) {
                                              CustomSnackbar.success(
                                                  dialogContext, 'Berhasil menghapus data');
                                              Navigator.of(dialogContext).pop();
                                              Provider.of<InformationNotifier>(context,
                                                      listen: false)
                                                  .deleteData(information.id);
                                            }

                                            if (!state.stateInitial()) {
                                              return const LoadingIndicator();
                                            }

                                            return AlertDialog(
                                              title: const Text('Hapus Data'),
                                              content: Text(
                                                'Informasi ${information.title} akan dihapus\nApakah Anda yakin?',
                                                textAlign: TextAlign.start,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    notifier.deleteInformation(information);
                                                  },
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Image.asset(
                                    R.ASSETS_ICONS_DELETE_PNG,
                                    color: kRedColor,
                                    width: 24,
                                  ),
                                )
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    information.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: kTitle5TextStyle,
                  ),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ParseDate.toText(information.createdAt),
                      style: kSubtitle6TextStyle.copyWith(color: kGreyColor),
                    ),
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
