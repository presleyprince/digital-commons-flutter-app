import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class PrimaryDropdownButton<T> extends StatefulWidget {
  const PrimaryDropdownButton({
    super.key,
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
  });

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

  @override
  State<PrimaryDropdownButton<T>> createState() => _PrimaryDropdownButtonState<T>();
}

class _PrimaryDropdownButtonState<T> extends State<PrimaryDropdownButton<T>> {
  late FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  void onChanged(T? value) {
    widget.notifier.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T?>(
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kGreyColor,
                    ),
                  ),
                ),
              Container(
                margin: widget.margin,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // decoration: BoxDecoration(
                //   color: const Color(0xffE9EAEA),
                //   borderRadius: BorderRadius.circular(12.0),
                // ),
                child: ValueListenableBuilder<T?>(
                  valueListenable: widget.notifier,
                  builder: (context, value, child) => DropdownButton<T>(
                    focusNode: _focusNode,
                    value: value,
                    hint: widget.hint != null ? Text(widget.hint!) : null,
                    items: widget.itemBuilder ??
                        widget.items!
                            .map(
                              (e) => DropdownMenuItem<T>(
                                value: e,
                                child: Text(e.toString()),
                              ),
                            )
                            .toList(),
                    onChanged: onChanged,
                    isExpanded: widget.isExpanded,
                    // underline: Container(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 10),
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
        );
      },
    );
  }
}
