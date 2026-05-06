import 'package:digital_shores/app/presentation/provider/weather_notifier.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart'; // Added so it will lets us navigate to weather page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DigitalShoresIntroductionColumn extends StatelessWidget {
  const DigitalShoresIntroductionColumn({
    super.key,
    this.titleBlue = true,
  });

  final bool titleBlue;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      children: [
        !titleBlue
            ? Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Image.asset(
                      R.ASSETS_IMAGES_APP_LOGO_PNG,
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    Text('Hai Sobat Laut!', style: kTitle6TextStyle),
                  ],
                ),
              )
            : SizedBox(),

        
        InkWell(
          onTap: () => router.push('/home/weather'),
          borderRadius: BorderRadius.circular(kDefaultRadius),
          child: Consumer<WeatherNotifier>( 
            builder: (context, notifier, child) {

              try {
                notifier.regionCodeController;
              } catch (e) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A73E8),
                    borderRadius: BorderRadius.circular(kDefaultRadius),
                  ),
                  child: Text(
                    'Memuat cuaca...',
                    style: kTitle5TextStyle.copyWith(color: Colors.white),
                  ),
                );
              }

              final hasWeather = notifier.weathers.isNotEmpty;
              final weather = hasWeather ? notifier.weathers.first : null;
              final tempText = weather?.t != null ? '${weather!.t}°C' : '--°C';
              final descText = weather?.weatherDesc ?? 'Pilih lokasi di menu Cuaca';

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A73E8),
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuaca Hari Ini',
                      style: kTitle5TextStyle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.white, size: 40),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tempText,
                              style: kTitle5TextStyle.copyWith(color: Colors.white),
                            ),
                            Text(
                              descText,
                              style: kSubtitle5TextStyle.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ), 
        ), 

        const SizedBox(height: 16),
      ],
    );
  }
}