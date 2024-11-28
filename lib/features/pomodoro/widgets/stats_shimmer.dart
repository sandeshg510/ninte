import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';

class StatsShimmer extends StatelessWidget {
  const StatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Column(
        children: [
          // Daily Stats Shimmer
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.surfaceLight.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: theme.surfaceLight,
                  highlightColor: theme.surface,
                  child: Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShimmerStat(theme),
                    Container(
                      height: 40,
                      width: 1,
                      color: theme.surfaceLight,
                    ),
                    _buildShimmerStat(theme),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total Stats Shimmer
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.surfaceLight.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: theme.surfaceLight,
                  highlightColor: theme.surface,
                  child: Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShimmerStat(theme),
                    Container(
                      height: 40,
                      width: 1,
                      color: theme.surfaceLight,
                    ),
                    _buildShimmerStat(theme),
                    Container(
                      height: 40,
                      width: 1,
                      color: theme.surfaceLight,
                    ),
                    _buildShimmerStat(theme),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStat(AppThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.surfaceLight,
      highlightColor: theme.surface,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.surfaceLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: theme.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: theme.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
} 