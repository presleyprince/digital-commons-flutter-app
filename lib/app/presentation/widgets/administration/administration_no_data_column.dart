import 'package:digital_shores/app/presentation/widgets/administration/administration_action_button.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class AdministrationNoDataColumn extends StatelessWidget {
  const AdministrationNoDataColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Image.asset(
                      R.ASSETS_ICONS_ADD_DOCUMENT_PNG,
                      width: 100,
                    ),
                    Text(
                      'Tidak Ada Berkas yang Ditambahkan',
                      style: kTitle6TextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              AdministrationActionButton(),
            ],
          ),
        ),
      );
    });
  }
}
