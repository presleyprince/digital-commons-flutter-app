import 'package:digital_shores/app/domain/entities/weather/weather_data.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/parse_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class WeatherDataCard extends StatefulWidget {
  const WeatherDataCard({
    super.key,
    required this.data,
  });

  final WeatherData data;

  @override
  State<WeatherDataCard> createState() => _WeatherDataCardState();
}

class _WeatherDataCardState extends State<WeatherDataCard> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      width: 300,
      decoration: BoxDecoration(
        color: color.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.data.localDatetime != null
              ? Text(
                  ParseDate.toText(widget.data.localDatetime!),
                  style: kTitle7TextStyle,
                )
              : const SizedBox(),
          const SizedBox(height: 10),
          widget.data.localDatetime != null
              ? Text(
                  '${ParseDate.toTextHour(widget.data.localDatetime!)} WITA',
                  style: kTitle4TextStyle,
                )
              : const SizedBox(),
          const SizedBox(height: 12),
          // data.image != null
          //     ? ImageWithPlaceholder(
          //         url: data.image!,
          //         width: 64,
          //         height: 64,
          //       )
          //     : const SizedBox(),
          widget.data.image != null
              ? SvgPicture.network(
                  widget.data.image!,
                  width: 64,
                  height: 64,
                  placeholderBuilder: (context) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  errorBuilder: (context, url, error) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Append a dummy query parameter to force reload
                          '${widget.data.image}?retry=${DateTime.now().millisecondsSinceEpoch}';
                        });
                      },
                      child: SizedBox(
                        height: 64,
                        width: 64,
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
                )
              : const SizedBox(),
          const SizedBox(height: 12),
          widget.data.t != null
              ? Text(
                  '${widget.data.t!} °C',
                  style: kTitle4TextStyle,
                )
              : const SizedBox(),
          widget.data.weatherDesc != null
              ? Text(
                  widget.data.weatherDesc!,
                  style: kTitle4TextStyle,
                )
              : const SizedBox(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: kGreyColor,
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: kGreyColor,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Kelembapan udara',
                        style: kSubtitle6TextStyle,
                      ),
                      const Spacer(),
                      Text(
                        '${widget.data.humidity ?? '-'}%',
                        style: kTitle6TextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: kGreyColor,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Kecepatan angin',
                        style: kSubtitle6TextStyle,
                      ),
                      const Spacer(),
                      Text(
                        '${widget.data.windSpeed ?? '-'} km/jam',
                        style: kTitle6TextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: kGreyColor,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Arah angin',
                        style: kSubtitle6TextStyle,
                      ),
                      const Spacer(),
                      Text(
                        widget.data.parseWindDirection(),
                        style: kTitle6TextStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: kGreyColor,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Jarak Pandang',
                        style: kSubtitle6TextStyle,
                      ),
                      const Spacer(),
                      Text(
                        widget.data.visibilityText ?? '-',
                        style: kTitle6TextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
