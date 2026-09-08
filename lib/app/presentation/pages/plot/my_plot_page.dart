import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class MyPlotPage extends StatelessWidget {
  const MyPlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TransparentAppBar(
        title: "Rumput Laut",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Text(
              "Informasi Rumput Laut",
              style: kTitle4TextStyle,
            ),

            const SizedBox(height: 8),

            Text(
              "Pelajari informasi dasar tentang rumput laut, manfaatnya, dan panduan budidaya sederhana.",
              style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            ),

            const SizedBox(height: 24),

            _InfoCard(
              icon: Icons.grass,
              title: "Apa itu Rumput Laut?",
              content:
                  "Rumput laut adalah tanaman laut yang banyak dibudidayakan oleh masyarakat pesisir dan dapat digunakan untuk makanan, kosmetik, obat-obatan, dan industri.",
              color: color.primary,
            ),

            _InfoCard(
              icon: Icons.eco,
              title: "Manfaat Rumput Laut",
              content:
                  "Rumput laut dapat menjadi sumber pendapatan bagi petani pesisir, mendukung ekonomi lokal, dan memiliki nilai jual yang baik.",
              color: color.primary,
            ),

            _InfoCard(
              icon: Icons.checklist_rounded,
              title: "Panduan Dasar Budidaya",
              content:
                  "Petani perlu memilih lokasi yang sesuai, menjaga kebersihan tali dan bibit, memantau pertumbuhan, dan melakukan panen pada waktu yang tepat.",
              color: color.primary,
            ),

            _InfoCard(
              icon: Icons.lightbulb_outline_rounded,
              title: "Tips untuk Petani",
              content:
                  "Catat lokasi budidaya, periksa kondisi laut, gunakan bibit yang sehat, dan simpan data peternakan secara teratur.",
              color: color.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kTitle6TextStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
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