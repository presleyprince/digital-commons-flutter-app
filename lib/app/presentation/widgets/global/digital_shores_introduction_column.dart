import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

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
                      height: 40, // reduced to make more compact
                    ),
                    const SizedBox(width: 8), // lowered the gap
                    Text('Hai Sobat Laut!', style: kTitle6TextStyle),
                  ],
                ),
              )
            : SizedBox(),

        // removed large beach image and line below it

        // added new weather card
        Container (
          width: double.infinity, // create a box that will stretch the full width of the screen
          padding: EdgeInsets.all(16), //  add space inside the box

          decoration: BoxDecoration ( //styling the box
            color: Color(0xFF1A73E8), // set to blue
            borderRadius: BorderRadius.circular(kDefaultRadius), // rounded corners for box
          ),
          child: Column( // stack everything vertically in the box
            crossAxisAlignment: CrossAxisAlignment.start, // line everything to the left
            children: [
              Text(
                'Cuaca Hari Ini', // 'Today's Weather' at the top
                style: kTitle5TextStyle.copyWith(color: Colors.white), // white text, kTitle5TextStyle is defined as a constant in constants.dart
               ),
              const SizedBox(height: 8), // the sun icon and temeprature can be next to each other
              Row(
                children: [ // list of things to diplay
                  Icon(Icons.wb_sunny, color:Colors.white, size:40), // sun icon from Flutter's library
                  const SizedBox(width: 12), // creating gap between the icon and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // start aligns everything to the left
                    children: [
                      Text( // temperature number need to change from text to automatic detection
                        '28C',
                        style: kTitle5TextStyle.copyWith(color: Colors.white),
                      ),
                      Text( // description after temperature, text faded
                        'Cerah, Cocok untuk melaut', // 'Clear, Good for Fishing'
                        style: kSubtitle5TextStyle.copyWith(color: Colors.white70), // used 70 for 70% opactiy
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
