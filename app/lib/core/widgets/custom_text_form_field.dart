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
  final bool? obscureText;
  final VoidCallback? onToggleObscure;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

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
    this.obscureText,
    this.onToggleObscure,
    this.focusNode,
    this.onFieldSubmitted,
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
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _fieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
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
      obscureText: widget.obscureText ?? false,
      style: textTheme.bodySmall?.copyWith(fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle:
            textTheme.labelLarge?.copyWith(fontSize: 15, color: Colors.grey),
        suffixIcon: widget.onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  widget.obscureText == true
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: widget.onToggleObscure,
              )
            : widget.suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0083B0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
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
        if (widget.onFieldSubmitted != null) {
          widget.onFieldSubmitted!(value);
        } else {
          // Mặc định: nếu là ô cuối, đóng bàn phím. Nếu không, focus sang ô tiếp theo.
          if (widget.textInputAction == TextInputAction.done) {
            FocusScope.of(context).unfocus();
          } else {
            FocusScope.of(context).nextFocus();
          }
        }
      },
    );
  }
}
