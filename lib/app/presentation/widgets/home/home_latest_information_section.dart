import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/error_column_widget.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/home/home_information_tile.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeLatestInformationSection extends StatelessWidget {
  const HomeLatestInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Info Terkini',
                  style: kTitle6TextStyle,
                ),
                GestureDetector(
                  onTap: () => router.go('/home/information'),
                  child: Text(
                    'Lihat Semua',
                    style: kTitle6TextStyle.copyWith(
                      color: color.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Consumer<InformationNotifier>(
              builder: (context, notifier, child) {
                final state = notifier.fetchDataState;
                if (state.stateLoading()) {
                  return const LoadingIndicator();
                } else if (state.stateError()) {
                  ErrorColumnWidget(
                    text: state.failure!.message,
                    onPressed: () => notifier.fetchData(),
                  );
                }

                final data = notifier.getHomeLatestInformations(5);
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return HomeInformationTile(
                      key: ValueKey(data[index].id),
                      information: data[index],
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
