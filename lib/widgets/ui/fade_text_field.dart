import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';

/// Labelled text input. The label sits ABOVE the field (never only a
/// placeholder) so it stays visible while typing, which is easier to scan and
/// better for accessibility.
///
/// ```dart
/// FadeTextField(label: 'Business name', hint: 'e.g. Southside Cuts', controller: c)
/// FadeTextField(label: 'Price', prefixText: '\$ ', keyboardType: TextInputType.number)
/// ```
class FadeTextField extends StatefulWidget {
  const FadeTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.optional = false,
  });

  final String? label;
  final String? hint;
  final String? helper;

  /// Shown in place of [helper], in the danger color.
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  /// Adds a show/hide toggle automatically.
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  /// Appends "Optional" to the label.
  final bool optional;

  @override
  State<FadeTextField> createState() => _FadeTextFieldState();
}

class _FadeTextFieldState extends State<FadeTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;

    Widget? suffix = widget.suffix;
    if (widget.obscureText) {
      suffix = IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
        tooltip: _obscured ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    final field = TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: _obscured,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      style: FadeType.body.copyWith(
        color: widget.enabled ? c.textPrimary : c.textTertiary,
      ),
      cursorColor: c.accent,
      decoration: InputDecoration(
        hintText: widget.hint,
        helperText: widget.errorText == null ? widget.helper : null,
        helperMaxLines: 3,
        errorText: widget.errorText,
        errorMaxLines: 3,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20),
        prefixText: widget.prefixText,
        prefixStyle: FadeType.body.copyWith(color: c.textSecondary),
        suffixIcon: suffix,
        counterText: '',
      ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: FadeSpace.s8),
          child: Text.rich(
            TextSpan(
              text: widget.label,
              children: [
                if (widget.optional)
                  TextSpan(
                    text: '  Optional',
                    style: FadeType.caption.copyWith(color: c.textTertiary),
                  ),
              ],
            ),
            style: FadeType.labelSm.copyWith(color: c.textSecondary),
          ),
        ),
        field,
      ],
    );
  }
}

/// Pill-shaped search input with a clear button.
class FadeSearchField extends StatefulWidget {
  const FadeSearchField({
    super.key,
    this.hint = 'Search',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<FadeSearchField> createState() => _FadeSearchFieldState();
}

class _FadeSearchFieldState extends State<FadeSearchField> {
  TextEditingController? _own;
  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fadeColors;
    final pill = OutlineInputBorder(
      borderRadius: FadeRadius.fullAll,
      borderSide: BorderSide(color: c.border),
    );
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) => TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: FadeType.body.copyWith(color: c.textPrimary),
        cursorColor: c.accent,
        decoration: InputDecoration(
          hintText: widget.hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FadeSpace.s16,
            vertical: FadeSpace.s12,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                ),
          border: pill,
          enabledBorder: pill,
          focusedBorder: pill.copyWith(
            borderSide: BorderSide(color: c.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
