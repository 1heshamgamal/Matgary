import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom text field widget
class CustomTextField extends StatelessWidget {
  /// Text editing controller
  final TextEditingController controller;
  
  /// Field label
  final String label;
  
  /// Hint text
  final String? hintText;
  
  /// Keyboard type
  final TextInputType? keyboardType;
  
  /// Whether the text is obscured
  final bool obscureText;
  
  /// Prefix icon
  final IconData? prefixIcon;
  
  /// Suffix icon widget
  final Widget? suffixIcon;
  
  /// Validator function
  final String? Function(String?)? validator;
  
  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;
  
  /// Max lines
  final int? maxLines;
  
  /// Min lines
  final int? minLines;
  
  /// On changed callback
  final Function(String)? onChanged;
  
  /// On submitted callback
  final Function(String)? onSubmitted;
  
  /// Focus node
  final FocusNode? focusNode;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Whether the field is read-only
  final bool readOnly;
  
  /// Constructor
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Text field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}