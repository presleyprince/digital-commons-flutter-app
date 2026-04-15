import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/parse_date.dart';
import 'package:flutter/material.dart';

class DateInputColumn extends StatefulWidget {
  const DateInputColumn({
    super.key,
    required this.text,
    this.hintText = 'mm/dd/yyyy',
    required this.notifier,
    required this.formKey,
    this.isLastInput = false,
    this.onComplete,
    this.validator,
    this.validatorText = 'Date must be filled',
    this.arterisk = false,
    this.limitLastDateToToday = false,
    this.autoHour = false,
  });

  final String text;
  final String hintText;
  final ValueNotifier<DateTime?> notifier;
  final GlobalKey<FormState> formKey;
  final bool isLastInput;
  final Future<void> Function()? onComplete;
  final bool Function(DateTime? value)? validator;
  final String validatorText;
  final bool arterisk;
  final bool limitLastDateToToday;
  final bool autoHour;

  @override
  State<DateInputColumn> createState() => _DateInputColumnState();
}

class _DateInputColumnState extends State<DateInputColumn> {
  // late FocusNode _focusNode;
  final fieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    // _focusNode = FocusNode();
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return FormField<DateTime>(
      key: fieldKey,
      enabled: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator != null
          ? (value) {
              if (widget.validator!(widget.notifier.value)) {
                return widget.validatorText;
              }
              return null;
            }
          : null,
      builder: (field) {
        return ValueListenableBuilder(
          valueListenable: widget.notifier,
          builder: (context, dateValue, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.text, style: kTitle6TextStyle),
                    if (widget.arterisk)
                      Text(
                        '*',
                        style: kTitle6TextStyle.copyWith(
                          color: kRedColor,
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      initialDatePickerMode: DatePickerMode.year,
                      locale: const Locale('id', 'ID'),
                      firstDate: DateTime(1900),
                      lastDate: widget.limitLastDateToToday ? DateTime.now() : DateTime(2101),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: color.primary,
                              onPrimary: color.onPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        if (widget.autoHour) {
                          // set the hour, minute, and second to now
                          final dateNow = DateTime.now();
                          widget.notifier.value = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            dateNow.hour,
                            dateNow.minute,
                            dateNow.second,
                            dateNow.millisecond,
                            dateNow.microsecond,
                          );
                        } else {
                          widget.notifier.value = picked;
                        }
                        fieldKey.currentState!.validate();
                      });
                      if (widget.onComplete != null) {
                        // _focusNode.unfocus();
                        await widget.onComplete!();
                      } else {
                        // _focusNode.nextFocus();
                      }
                      fieldKey.currentState!.validate();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    field.hasError ? kDefaultErrorColor : kGreyColor.withAlpha(160),
                              ),
                            ),
                          ),
                          child: Text(
                            dateValue == null ? widget.hintText : ParseDate.toText(dateValue),
                            style: dateValue == null
                                ? kSubtitle6TextStyle.copyWith(
                                    color: kLightGreyColor,
                                  )
                                : null,
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
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
