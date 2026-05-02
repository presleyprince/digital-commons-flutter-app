import 'dart:io';

import 'package:digital_shores/app/presentation/provider/add_information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/image_with_placeholder.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class InformationImageInput extends StatelessWidget {
  const InformationImageInput({
    super.key,
    required this.notifier,
  });

  final AddInformationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return FormField<File>(
      enabled: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        // removed validator condition, no image still works
        return null; // image is optional
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gambar',
              style: kTitle6TextStyle,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => notifier.showOptions(context),
              child: ValueListenableBuilder(
                valueListenable: notifier.imageController,
                builder: (context, value, child) {
                  final containerHeight = 250.0;
                  // show the image url if the information is edited
                  if (notifier.selectedData != null && value == null) {
                    return ImageWithPlaceholder(
                      url: notifier.selectedData!.imageUrl,
                      width: double.infinity,
                      height: containerHeight,
                    );
                  }
                  return Container(
                    height: containerHeight,
                    width: double.infinity,
                    padding: value == null ? const EdgeInsets.all(8) : null,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kDefaultRadius),
                      image: value != null
                          ? DecorationImage(
                              image: FileImage(value),
                              fit: BoxFit.contain,
                            )
                          : null,
                      border: value == null
                          ? Border.all(
                              color: field.hasError ? kDefaultErrorColor : kGreyColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: value == null
                        ? Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, color: kGreyColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Pilih Gambar',
                                  style: kBodyTextStyle.copyWith(color: kGreyColor),
                                ),
                              ],
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 13,
                    color: kDefaultErrorColor,
                    height: 0.5,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
