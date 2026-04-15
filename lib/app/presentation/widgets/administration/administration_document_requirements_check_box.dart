import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/parse_document_requirement.dart';
import 'package:flutter/material.dart';

class AdministrationDocumentRequirementsCheckBox extends StatelessWidget {
  const AdministrationDocumentRequirementsCheckBox({
    super.key,
    required this.notifier,
  });

  final AdministrationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (notifier.requirementsController.value.isEmpty) {
          return 'Pilih minimal satu keperluan berkas';
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...DocumentRequirement.values.map(
              (e) {
                return ValueListenableBuilder(
                  valueListenable: notifier.requirementsController,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        Checkbox(
                          value: value.contains(e),
                          side: BorderSide(
                            color: color.primary,
                            width: 2,
                          ),
                          onChanged: (value) {
                            notifier.setDocumentRequirements(e);
                          },
                        ),
                        Expanded(
                          child: Text(
                            ParseDocumentRequirement.toText(e),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 10, bottom: 24),
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
          ],
        );
      },
    );
  }
}
