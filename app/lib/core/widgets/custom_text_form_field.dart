import 'package:flutter/material.dart';
import '../../../core/utils/validate.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? fieldName;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.initialValue,
    this.fieldName,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSaved,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late FocusNode _focusNode;
  final _fieldKey = GlobalKey<FormFieldState>();
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      key: _fieldKey,
      initialValue: widget.initialValue,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      style: textTheme.bodySmall?.copyWith(fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        suffixIcon: widget.suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      validator: (value) {
        final normalized = Validate.normalizeText(value ?? '');
        if (widget.validator != null) {
          return widget.validator!(normalized);
        }
        return Validate.notEmpty(
          normalized,
          fieldName: widget.fieldName ?? widget.label,
        );
      },
      onChanged: (value) {
        final normalized = Validate.normalizeText(value);
        if (normalized.isNotEmpty && !_hasInput) {
          setState(() {
            _hasInput = true;
          });
        }
        widget.onChanged?.call(value);
        _fieldKey.currentState?.validate();
      },
      onSaved: (value) =>
          widget.onSaved?.call(Validate.normalizeText(value ?? '')),
      onFieldSubmitted: (value) {
        if (Validate.normalizeText(value).isEmpty) {
          FocusScope.of(context).unfocus();
        } else {
          FocusScope.of(context).nextFocus();
        }
      },
    );
  }
}
