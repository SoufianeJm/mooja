import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/api_service.dart';
import '../../core/themes/theme_exports.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/router/app_router.dart';

class VerificationTimelinePage extends StatefulWidget {
  final String? username;
  final String?
  initialStatus; // optional boot value, will be overridden by fetch

  const VerificationTimelinePage({
    super.key,
    this.username,
    this.initialStatus,
  });

  @override
  State<VerificationTimelinePage> createState() =>
      _VerificationTimelinePageState();
}

class _VerificationTimelinePageState extends State<VerificationTimelinePage> {
  String _status = 'pending';
  bool _loading = false;
  String? _error;

  List<_TimelineStep> _buildStepsForStatus(String status) {
    final isUnderReview =
        status == 'under_review' ||
        status == 'approved' ||
        status == 'rejected';
    final isDecision = status == 'approved' || status == 'rejected';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    return const [
          _TimelineStep(
            title: 'Request Submitted',
            subtitle: 'We received your application and queued it for review',
            active: true,
          ),
        ] +
        [
          _TimelineStep(
            title: 'Under Review',
            subtitle:
                'Our team is verifying your information and social presence',
            active: isUnderReview,
          ),
          _TimelineStep(
            title: 'Decision',
            active: isDecision,
            subtitle: isApproved
                ? 'Approved — check your inbox for the invite code'
                : isRejected
                ? 'Rejected — see reason in admin notices'
                : 'Awaiting decision from our review team',
          ),
        ];
  }

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? 'pending';
    // Fetch from backend if username provided
    if (widget.username != null && widget.username!.isNotEmpty) {
      _refreshStatus(showSnackbars: false);
    }
  }

  Future<void> _refreshStatus({bool showSnackbars = true}) async {
    if (widget.username == null || widget.username!.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (showSnackbars) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing status...'),
            duration: Duration(milliseconds: 600),
          ),
        );
      }
      final api = sl<ApiService>();
      final newStatus = await api.getOrgStatusByUsername(widget.username!);
      if (!mounted) return;
      setState(() {
        _status = newStatus;
        _loading = false;
      });
      if (showSnackbars) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status: $newStatus'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to refresh status';
      });
      if (showSnackbars) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh status'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(),

              Center(
                child: Transform.rotate(
                  angle: -0.1745,
                  child: AppChip(
                    label: 'step 04',
                    backgroundColor: AppColors.lemon,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Verification timeline',
                style: AppTypography.h1SemiBold.copyWith(
                  color: ThemeColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                _VerticalTimeline(steps: _buildStepsForStatus(_status)),

              const Spacer(),

              AppButton.primary(
                text: _status == 'approved'
                    ? 'Input Verification Code'
                    : 'Continue',
                onPressed: () {
                  if (_status == 'approved') {
                    // TODO: route to code entry screen when available
                  } else {
                    context.goToProtestorFeed();
                  }
                },
                isFullWidth: true,
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _refreshStatus,
                child: Text(
                  'Refresh',
                  style: AppTypography.bodySubMedium.copyWith(
                    color: ThemeColors.textSecondary(context),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AppTypography.bodySubMedium.copyWith(
                    color: AppColors.red500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension _TimelineBuilder on VerificationTimelinePage {
  List<_TimelineStep> _buildStepsForStatus(String status) {
    final isUnderReview =
        status == 'under_review' ||
        status == 'approved' ||
        status == 'rejected';
    final isDecision = status == 'approved' || status == 'rejected';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    return [
      const _TimelineStep(
        title: 'Request Submitted',
        subtitle: 'We received your application and queued it for review',
        active: true,
      ),
      _TimelineStep(
        title: 'Under Review',
        subtitle: 'Our team is verifying your information and social presence',
        active: isUnderReview,
      ),
      _TimelineStep(
        title: 'Decision',
        active: isDecision,
        subtitle: isApproved
            ? 'Approved — check your inbox for the invite code'
            : isRejected
            ? 'Rejected — see reason in admin notices'
            : 'Awaiting decision from our review team',
      ),
    ];
  }
}

class _VerticalTimeline extends StatelessWidget {
  final List<_TimelineStep> steps;

  static const double _indicatorSize = 24;
  static const double _lineWidth = 2;
  static const double _spacing = 32;

  const _VerticalTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return _TimelineRow(step: step, isLast: isLast);
      }).toList(),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.gray900;
    final inactiveColor = AppColors.gray400.withValues(alpha: 0.4);
    final textColor = step.active
        ? ThemeColors.textPrimary(context)
        : ThemeColors.textSecondary(context).withValues(alpha: 0.4);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator column
        Column(
          children: [
            // Circle indicator
            Image.asset(
              'assets/icons/check-circle.png',
              width: _VerticalTimeline._indicatorSize,
              height: _VerticalTimeline._indicatorSize,
              color: step.active ? activeColor : inactiveColor,
            ),
            // Connecting line (only if not last item)
            if (!isLast)
              Container(
                width: _VerticalTimeline._lineWidth,
                height: 60, // Fixed height that works well for most content
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                child: _DashedLine(
                  dashColor: AppColors.gray300,
                  dashHeight: 4,
                  dashGap: 4,
                  width: _VerticalTimeline._lineWidth,
                ),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Content column
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: (_VerticalTimeline._indicatorSize - 20) / 2,
              bottom: isLast ? 0 : _VerticalTimeline._spacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTypography.bodySemiBold.copyWith(color: textColor),
                ),
                if (step.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle!,
                    style: AppTypography.bodySubMedium.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String title;
  final String? subtitle;
  final bool active;

  const _TimelineStep({
    required this.title,
    this.subtitle,
    required this.active,
  });
}

class _DashedLine extends StatelessWidget {
  final double dashHeight;
  final double dashGap;
  final Color dashColor;
  final double width;

  const _DashedLine({
    this.dashHeight = 4,
    this.dashGap = 6,
    this.dashColor = Colors.grey,
    this.width = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(
        dashColor: dashColor,
        dashHeight: dashHeight,
        dashGap: dashGap,
        strokeWidth: width,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color dashColor;
  final double dashHeight;
  final double dashGap;
  final double strokeWidth;

  const _DashedLinePainter({
    required this.dashColor,
    required this.dashHeight,
    required this.dashGap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dashColor
      ..strokeWidth = strokeWidth;

    double currentY = 0;
    final totalHeight = size.height;

    while (currentY < totalHeight) {
      final endY = (currentY + dashHeight).clamp(0.0, totalHeight);

      canvas.drawLine(
        Offset(size.width / 2, currentY),
        Offset(size.width / 2, endY),
        paint,
      );

      currentY += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
