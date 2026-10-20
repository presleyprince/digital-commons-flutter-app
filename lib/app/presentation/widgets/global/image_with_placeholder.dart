import 'package:cached_network_image/cached_network_image.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageWithPlaceholder extends StatefulWidget {
  const ImageWithPlaceholder({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  State<ImageWithPlaceholder> createState() => _ImageWithPlaceholderState();
}

class _ImageWithPlaceholderState extends State<ImageWithPlaceholder> {
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.url;
  }

 @override
Widget build(BuildContext context) {
  //news placeholder instead of reload
  if (widget.url.isEmpty) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: const Icon(Icons.image_outlined, color: kGreyColor),
    );
  }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorWidget: (context, url, error) {
          return GestureDetector(
            onTap: () {
              setState(() {
                // Append a dummy query parameter to force reload
                imageUrl = '${widget.url}?retry=${DateTime.now().millisecondsSinceEpoch}';
              });
            },
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: kGreyColor),
                  Text('Muat Ulang'),
                ],
              ),
            ),
          );
        },
        progressIndicatorBuilder: (context, url, progress) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: widget.width ?? 100,
              height: widget.height ?? 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        },
      ),
    );
  }
}
