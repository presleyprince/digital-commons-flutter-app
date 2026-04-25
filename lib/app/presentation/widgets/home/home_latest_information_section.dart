import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/error_column_widget.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/home/home_information_tile.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeLatestInformationSection extends StatefulWidget { // changed to Stateful so initState can be used to trigger the news fetch
  const HomeLatestInformationSection({super.key});

  @override
  State<HomeLatestInformationSection> createState() => _HomeLatestInformationSectionState();
}

class _HomeLatestInformationSectionState extends State<HomeLatestInformationSection> {
  @override
  void initState() {
    super.initState(); // overring the initstate
    Future.microtask(() => // runs the feth after the widget is fully loaded
    Provider.of<InformationNotifier>(context, listen: false).fetchData() // calls the backened to get the news (firebase) data
  );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 24), // create space above the section
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
                  onTap: () => router.go('/home/information'), // naviagate to full news list
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
                  return const LoadingIndicator(); // spinner indicator for loading
                } else if (state.stateError()) {
                  return ErrorColumnWidget( // show error with retry if fetch fails
                    text: state.failure!.message,
                    onPressed: () => notifier.fetchData(),
                  );
                }

                final data = notifier.getHomeLatestInformations(5); // gets latest 5 news items
                return ListView.separated(
                  scrollDirection: Axis.horizontal, // horizontal scrolling cards
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return HomeInformationTile( // each new cards
                      key: ValueKey(data[index].id),
                      information: data[index],
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 10), // gap between cards
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
