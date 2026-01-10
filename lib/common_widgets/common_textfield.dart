import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_groceries_app/utils/app_colors.dart';

class CommonTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;
  final int? maxLines;
  final bool isReadOnly;
  final void Function(String)? onChanged;

  const CommonTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = "",
    this.isPassword = false,
    this.obscureText = false,
    this.onToggle,
    this.keyboardType = TextInputType.text, this.maxLines,
    this.onChanged,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Color(0xff7C7C7C),
          ),
        ),

        const SizedBox(height: 4),

        /// TextField
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          cursorColor: AppColors.textColor,
          maxLines: maxLines,
          readOnly: isReadOnly,
          style: TextStyle(fontSize: 18.sp, color: Color(0xff181725)),
          onChanged:onChanged ,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 18.sp, color: Colors.grey.shade400),
            border: const UnderlineInputBorder(),
            errorBorder: const UnderlineInputBorder(),
            focusedBorder: const UnderlineInputBorder(),
            focusedErrorBorder: const UnderlineInputBorder(),
            enabledBorder: const UnderlineInputBorder(),
            disabledBorder: const UnderlineInputBorder(),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
