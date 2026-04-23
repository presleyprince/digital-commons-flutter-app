import 'package:flutter/material.dart';
import 'package:digital_shores/core/constants.dart';

class SeaweedFarmerHome extends StatelessWidget {
  const SeaweedFarmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Baru'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: const Center(
            child: Text('Halaman Baru'),
          ),
        ),
      ),
    );
  }
}