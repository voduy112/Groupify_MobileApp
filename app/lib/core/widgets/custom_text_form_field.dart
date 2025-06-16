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
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late FocusNode _focusNode;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_touched) {
        setState(() {
          _touched = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initialValue,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      decoration: InputDecoration(labelText: widget.label),
      validator: (value) {
        if (!_touched) return null;
        final v = widget.validator ??
            (value) => Validate.notEmpty(value,
                fieldName: widget.fieldName ?? widget.label);
        return v(value);
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
