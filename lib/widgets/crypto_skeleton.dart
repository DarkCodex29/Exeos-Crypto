import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class CryptoSkeleton extends StatefulWidget {
  final int itemCount;
  final bool isGridView;

  const CryptoSkeleton({
    super.key,
    this.itemCount = 3,
    this.isGridView = false,
  });

  @override
  State<CryptoSkeleton> createState() => _CryptoSkeletonState();
}

class _CryptoSkeletonState extends State<CryptoSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGridView) {
      return _buildGridSkeleton();
    } else {
      return _buildListSkeleton();
    }
  }

  Widget _buildGridSkeleton() {
    final columns = ResponsiveHelper.getCryptoListColumns(context);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: ResponsiveHelper.getResponsiveValue(
          context,
          mobile: 1.0,
          tablet: 1.2,
          desktop: 1.5,
        ),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: ResponsiveHelper.getResponsiveValue(
        context,
        mobile: 2.0,
        tablet: 4.0,
        desktop: 6.0,
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        )),
        child: ResponsiveHelper.isDesktop(context)
            ? _buildDesktopSkeletonContent()
            : _buildMobileSkeletonContent(),
      ),
    );
  }

  Widget _buildDesktopSkeletonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSkeletonAvatar(),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonLine(width: 120),
                  SizedBox(height: 4),
                  _buildSkeletonLine(width: 60),
                ],
              ),
            ),
          ],
        ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildSkeletonLine(width: 80),
            SizedBox(height: 4),
            _buildSkeletonLine(width: 50),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileSkeletonContent() {
    return ListTile(
      leading: _buildSkeletonAvatar(),
      title: _buildSkeletonLine(width: 120),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4),
        child: _buildSkeletonLine(width: 60),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSkeletonLine(width: 80),
          SizedBox(height: 4),
          _buildSkeletonLine(width: 50),
        ],
      ),
    );
  }

  Widget _buildSkeletonAvatar() {
    final avatarRadius = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: avatarRadius * 2,
          height: avatarRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLine({required double width}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}