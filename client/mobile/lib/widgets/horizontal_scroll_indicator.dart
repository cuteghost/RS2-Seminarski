import 'package:ebooking/config/app_theme.dart';
import 'package:flutter/material.dart';

/// A slim track under a horizontal row that says how much of it is off screen
/// and where the viewport sits inside it.
///
/// A row of cards on its own reads as one card and a sliver of a second, with
/// nothing telling the reader there is more to the right.
class HorizontalScrollIndicator extends StatefulWidget {
  const HorizontalScrollIndicator({
    super.key,
    required this.controller,
    this.width = 96,
    this.thickness = 3,
  });

  final ScrollController controller;
  final double width;
  final double thickness;

  @override
  State<HorizontalScrollIndicator> createState() =>
      _HorizontalScrollIndicatorState();
}

class _HorizontalScrollIndicatorState extends State<HorizontalScrollIndicator> {
  @override
  void initState() {
    super.initState();
    // The controller has no clients while the list is still being laid out,
    // and attaching one does not notify listeners, so the first frame needs
    // its own rebuild or the track would stay hidden until the first scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        if (!widget.controller.hasClients) return const SizedBox.shrink();

        final position = widget.controller.position;
        if (!position.hasContentDimensions) return const SizedBox.shrink();

        final maxScroll = position.maxScrollExtent;
        if (maxScroll <= 0) return const SizedBox.shrink();

        final viewport = position.viewportDimension;
        final thumbWidth =
            (viewport / (viewport + maxScroll)).clamp(0.15, 1.0) * widget.width;
        final travel = widget.width - thumbWidth;
        final offset =
            (position.pixels / maxScroll).clamp(0.0, 1.0) * travel;

        return SizedBox(
          width: widget.width,
          height: widget.thickness,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(widget.thickness),
                  ),
                ),
              ),
              Positioned(
                left: offset,
                child: Container(
                  width: thumbWidth,
                  height: widget.thickness,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(widget.thickness),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
