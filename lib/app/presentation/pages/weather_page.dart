import 'package:digital_shores/app/presentation/provider/weather_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/error_column_widget.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/input/dropdown_input_column.dart';
import 'package:digital_shores/app/presentation/widgets/weather/weather_data_card.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<WeatherNotifier>(context, listen: false);
    notifier.init();
    super.initState();
  }

  @override
  void dispose() {
    notifier.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WeatherData weather = WeatherData(
    //   datetime: DateTime.parse("2025-03-20T12:00:00Z"),
    //   t: 26,
    //   tcc: 89,
    //   tp: 0,
    //   weather: 2,
    //   weatherDesc: "Cerah Berawan",
    //   weatherDescEn: "Partly Cloudy",
    //   wdDeg: 42,
    //   windDirection: "N",
    //   wdTo: "S",
    //   windSpeed: 7.4,
    //   humidity: 91,
    //   vs: 7001,
    //   visibilityText: "< 8 km",
    //   timeIndex: "-1-0",
    //   analysisDate: DateTime.parse("2025-03-20T12:00:00"),
    //   image: "https://api-apps.bmkg.go.id/storage/icon/cuaca/cerah berawan-am.svg",
    //   utcDatetime: DateTime.parse("2025-03-20 12:00:00"),
    //   localDatetime: DateTime.parse("2025-03-20 20:00:00"),
    // );
    return SafeArea(
      child: Scaffold(
        appBar: TransparentAppBar(
          title: 'Cuaca',
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                child: DropdownInputColumn(
                  text: "Lokasi",
                  hint: "Pilih lokasi",
                  isExpanded: true,
                  itemBuilder: WeatherRegionCode.values.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e.region),
                    );
                  }).toList(),
                  notifier: notifier.regionCodeController,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: notifier.regionCodeController,
                builder: (context, value, child) {
                  if (value == null) {
                    return Text(
                      'Silakan memilih lokasi',
                      style: kTitle6TextStyle,
                    );
                  }

                  return Consumer<WeatherNotifier>(
                    builder: (context, notifier, child) {
                      final state = notifier.fetchDataState;
                      if (state.stateLoading()) {
                        // build shimmer
                        return Column(
                          children: [
                            SizedBox(
                              height: 430,
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 300,
                                      height: 430,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: kDefaultPadding),
                                itemCount: 3,
                              ),
                            ),
                            const SizedBox(height: kDefaultPadding),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      } else if (state.stateError()) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                          child: ErrorColumnWidget(
                            text: state.failure!.message,
                            onPressed: notifier.fetchWeather,
                          ),
                        );
                      } else if (state.stateSuccess()) {
                        if (notifier.weathers.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                            child: Text('Data tidak ditemukan', style: kTitle6TextStyle),
                          );
                        }
                        return Column(
                          children: [
                            SizedBox(
                              height: 430,
                              child: ListView.separated(
                                shrinkWrap: true,
                                // physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  // final weather = notifier.fetchDataState.value!.weathers?[1][index];
                                  final weather = notifier.weathers[index];
                                  return WeatherDataCard(data: weather);
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: kDefaultPadding),
                                itemCount: notifier.weathers.length,
                              ),
                            ),
                            const SizedBox(height: kDefaultPadding),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Deskripsi', style: kTitle6TextStyle),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '1.',
                                              style: kSubtitle6TextStyle,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Kelembapan Udara (%): Persentase kadar uap air di udara. Semakin tinggi, udara terasa lebih lembap atau gerah.',
                                                style: kSubtitle6TextStyle,
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '2.',
                                              style: kSubtitle6TextStyle,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Kecepatan Angin (km/jam): Seberapa cepat angin bergerak.',
                                                style: kSubtitle6TextStyle,
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '3.',
                                              style: kSubtitle6TextStyle,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Arah Angin: Dari mana angin bertiup.',
                                                style: kSubtitle6TextStyle,
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '4.',
                                              style: kSubtitle6TextStyle,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Jarak Pandang (km): Seberapa jauh mata bisa melihat dengan jelas.',
                                                style: kSubtitle6TextStyle,
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  Row(
                                    children: [
                                      Image.asset(
                                        R.ASSETS_ICONS_BMKG_PNG,
                                        width: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Data cuaca bersumber dari ',
                                          style: kSubtitle6TextStyle),
                                      Text(
                                        'BMKG',
                                        style: kSubtitle6TextStyle.copyWith(
                                            fontWeight: kFontweightBold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return SizedBox();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
