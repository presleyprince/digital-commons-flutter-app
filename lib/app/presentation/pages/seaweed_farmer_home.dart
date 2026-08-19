import 'package:flutter/material.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart'; // added to ensure only admins/secretaries ccan access the page
import 'package:provider/provider.dart';

class SeaweedFarmerHome extends StatelessWidget {
  const SeaweedFarmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LahanKu'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Rekam dan kelola lahan Anda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola dan pantau data lahan Anda.',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/home/gps-test');
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Lahan baru'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/home/plot-overview');
                },
                icon: const Icon(Icons.grid_view_outlined),
                label: const Text('Lahan saya'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/home/saved-plots');
                },
                icon: const Icon(Icons.task_alt),
                label: const Text('Pilih lahan untuk memverifikasi'),
              ),
              if (Provider.of<AuthNotifier>(context, listen: false).isAdmin()) ...[ // added for security only admins and secretaries can access the verify plots page
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/verify-plots');
                },
                icon: const Icon(Icons.verified_user),
                label: const Text('Verifikasi Lahan'),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}
