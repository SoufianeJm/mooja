import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';
import '../../../core/models/protest_model.dart';
import '../../../core/services/api_service.dart';

class ProtestCard extends StatelessWidget {
  final Protest protest;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const ProtestCard({
    super.key,
    required this.protest,
    this.onTap,
    this.onMoreTap,
  });

  ImageProvider _getImageProvider(String? pictureUrl) {
    if (pictureUrl == null || pictureUrl.isEmpty) {
      return const AssetImage('assets/images/avatar1.png');
    }

    // Check if it's a network URL (full URL) - includes Supabase Storage URLs
    if (pictureUrl.startsWith('http://') || pictureUrl.startsWith('https://')) {
      return NetworkImage(pictureUrl);
    }

    // Check if it's a server upload path (relative URL)
    if (pictureUrl.startsWith('/uploads/')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', ''); // Remove /api suffix
      return NetworkImage('$baseUrl$pictureUrl');
    }

    // Check if it's a local asset path
    if (pictureUrl.startsWith('assets/')) {
      return AssetImage(pictureUrl);
    }

    // Default fallback
    return const AssetImage('assets/images/avatar1.png');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: AppShadows.up,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(context), 16.v, _buildContent(context)],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gray400.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image(
                    image: _getImageProvider(protest.organizer?.pictureUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/avatar1.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              12.h,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      protest.organizer?.displayName ?? 'Unknown Organization',
                      style: AppTypography.bodyMedium.copyWith(
                        color: ThemeColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.v,
                    Text(
                      protest.organizer?.organizationType ?? 'Organization',
                      style: AppTypography.bodySubMedium.copyWith(
                        color: ThemeColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onMoreTap,
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Icon(
              Icons.more_horiz,
              size: 20,
              color: ThemeColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          protest.title,
          style: AppTypography.h3Medium.copyWith(
            color: ThemeColors.textPrimary(context),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        12.v,
        Row(
          children: [
            _buildInfoPill(
              context: context,
              label: 'Time',
              value: protest.formattedTime,
              isFill: false,
            ),
            10.h,
            Expanded(
              child: _buildInfoPill(
                context: context,
                label: 'Day',
                value: protest.formattedDate,
                isFill: true,
              ),
            ),
          ],
        ),
        12.v,
        _buildInfoPill(
          context: context,
          label: 'Location',
          value: protest.location,
          isFill: true,
        ),
      ],
    );
  }

  Widget _buildInfoPill({
    required BuildContext context,
    required String label,
    required String value,
    required bool isFill,
  }) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodySubMedium.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
          ),
          2.v,
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: ThemeColors.textPrimary(context),
            ),
            maxLines: label == 'Location' ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (isFill) {
      return SizedBox(width: double.infinity, child: content);
    }

    // Otherwise return as-is (hug content)
    return content;
  }
}
