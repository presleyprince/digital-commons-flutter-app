import 'package:digital_shores/app/presentation/widgets/input/primary_dropdown_button.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class DropdownInputColumn<T> extends StatelessWidget {
  const DropdownInputColumn({
    super.key,
    required this.text,
    required this.notifier,
    this.items,
    this.formKey,
    this.validator,
    this.validatorText = 'Field tidak boleh kosong',
    this.title,
    this.margin,
    this.isExpanded = false,
    this.itemBuilder,
    this.hint,
    this.arterisk = false,
    this.titlePrimary = false,
  });

  final String text;
  final ValueNotifier<T?> notifier;
  final List<T>? items;
  final EdgeInsetsGeometry? margin;
  final bool isExpanded;
  final String? title;
  final GlobalKey<FormState>? formKey;
  final bool Function(T? value)? validator;
  final String validatorText;
  final List<DropdownMenuItem<T>>? itemBuilder;
  final String? hint;
  final bool arterisk;
  final bool titlePrimary;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              text,
              style: kTitle6TextStyle.copyWith(
                color: titlePrimary ? color.primary : null,
              ),
            ),
            if (arterisk)
              Text(
                '*',
                style: kTitle6TextStyle.copyWith(
                  color: kRedColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryDropdownButton(
          hint: hint,
          notifier: notifier,
          items: items,
          margin: margin,
          isExpanded: isExpanded,
          title: title,
          formKey: formKey,
          validator: validator,
          validatorText: validatorText,
          itemBuilder: itemBuilder,
        ),
      ],
    );
  }
}
