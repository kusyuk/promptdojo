import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A prominent warning banner displayed when Watsonx AI is unavailable
///
/// This usually indicates that the watsonx sandbox session has expired
/// and the `.env` file needs to be updated with a fresh API key.
class SandboxWarningBanner extends StatelessWidget {
  const SandboxWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.15),
        border: Border.all(color: AppTheme.errorColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Watsonx Sandbox Expired',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The watsonx.ai connection is currently unavailable. Your sandbox session may have expired. Using offline fallback evaluation so you can continue your journey!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
