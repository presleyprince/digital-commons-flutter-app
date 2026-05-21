import 'package:flutter/material.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:go_router/go_router.dart';

class SeaweedFarmerHome extends StatelessWidget {
  const SeaweedFarmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rumput Laut'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Offline Plot Recording',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Record seaweed plot boundary points using GPS without relying on an online map.',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/home/gps-test');
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Open GPS Plot Recorder'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/home/saved-plots');
                },
                icon: const Icon(Icons.task_alt),
                label: const Text('Choose Plot For Form'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/verify-plots');
                },
                icon: const Icon(Icons.verified_user),
                label: const Text('Verify Plots'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
