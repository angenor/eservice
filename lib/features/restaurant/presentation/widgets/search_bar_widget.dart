import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final String hint;
  final Function(String) onSearch;
  final VoidCallback? onVoiceSearch;
  
  const SearchBarWidget({
    super.key,
    required this.hint,
    required this.onSearch,
    this.onVoiceSearch,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onSubmitted: onSearch,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon: onVoiceSearch != null
              ? IconButton(
                  icon: const Icon(Icons.mic, color: AppColors.primary),
                  onPressed: onVoiceSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}