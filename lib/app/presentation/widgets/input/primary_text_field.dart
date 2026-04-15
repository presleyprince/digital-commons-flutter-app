import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrimaryTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool isLastInput;
  final bool email;
  final bool number;
  final void Function()? onComplete;
  final Widget? prefix;
  final GlobalKey<FormState> formKey;
  final bool Function(String value)? validator;
  final String validatorText;
  final bool autoFocus;
  final bool currency;

  const PrimaryTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.email = false,
    this.number = false,
    this.isPassword = false,
    this.isLastInput = false,
    required this.formKey,
    this.onComplete,
    this.prefix,
    this.validator,
    this.validatorText = 'Field must be filled',
    this.autoFocus = false,
    this.currency = false,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  late FocusNode _focusNode;
  late bool _isObscure;
  late Widget? _suffixIcon;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _isObscure = widget.isPassword;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    _suffixIcon = _getSuffix();
    return TextFormField(
      cursorColor: color.secondary,
      autofocus: widget.autoFocus,
      focusNode: _focusNode,
      validator: widget.validator != null
          ? (value) {
              if (widget.validator!(value!)) {
                return widget.validatorText;
              }
              return null;
            }
          : null,
      onEditingComplete: () {
        if (widget.onComplete != null) {
          _focusNode.unfocus();
          widget.onComplete!();
        } else {
          _focusNode.nextFocus();
        }
      },
      controller: widget.controller,
      autovalidateMode: AutovalidateMode.disabled,
      obscureText: _isObscure,
      keyboardType: widget.email
          ? TextInputType.emailAddress
          : widget.number || widget.currency
              ? TextInputType.number
              : widget.isPassword
                  ? TextInputType.visiblePassword
                  : TextInputType.text,
      // deny minus sign for number input
      inputFormatters: widget.number
          ? [
              FilteringTextInputFormatter.deny('-'),
              FilteringTextInputFormatter.deny(','),
              FilteringTextInputFormatter.deny(' '),
            ]
          : widget.currency
              ? [
                  CurrencyInputFormatter(),
                  FilteringTextInputFormatter.deny('-'),
                  FilteringTextInputFormatter.deny(','),
                  FilteringTextInputFormatter.deny(' '),
                ]
              : null,
      textInputAction: widget.isLastInput ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.only(top: 8, bottom: 5),
        fillColor: color.surface,
        filled: true,
        hintText: widget.hintText,
        labelStyle: TextStyle(
          fontSize: 16,
          color: color.onSurface,
        ),
        hintMaxLines: 2,
        hintStyle: kSubtitle6TextStyle.copyWith(
          color: kLightGreyColor,
        ),
        prefixIcon: widget.prefix,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: kGreyColor,
          ),
        ),
        suffixIcon: _suffixIcon,
      ),
    );
  }

  Widget? _getSuffix() {
    if (widget.isPassword) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
        child: Icon(
          _isObscure ? Icons.visibility : Icons.visibility_off,
          color: kGreyColor,
        ),
      );
    }
    return null;
  }
}
