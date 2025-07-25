import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MeasuredNetworkImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;

  const MeasuredNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MeasuredNetworkImage> createState() => _MeasuredNetworkImageState();
}

class _MeasuredNetworkImageState extends State<MeasuredNetworkImage> {
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant MeasuredNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _startTimer();
    }
  }

  void _startTimer() {
    _startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: (widget.width * 2).toInt(),
      cacheHeight: (widget.height * 2).toInt(),
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error, size: widget.width, color: Colors.red);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          final duration = DateTime.now().difference(_startTime!);
          return child;
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Match the circular shape
              ),
            ),
          );
        }
      },
    );
  }
}