import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class MyPlotPage extends StatefulWidget {
  const MyPlotPage({super.key});

  @override
  State<MyPlotPage> createState() => _MyPlotPageState();
}

class _MyPlotPageState extends State<MyPlotPage> {
  late final WebViewController _controller;
  bool _hasError = false;
  bool _isLoading = false;
  bool _success = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _progress = progress;
                if (!_isLoading && !_success) {
                  _isLoading = true;
                  _hasError = false;
                }
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _success = true;
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://www.google.com/maps/d/u/6/embed?mid=13ESmKnvSpl4VcRxXFPB6Bs1CN57Cks8&ehbc=2E312F&noprof=1"));
  }

  void _reloadPage() {
    setState(() {
      _hasError = false;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: TransparentAppBar(
        title: "LahanKu",
        actions: [
          IconButton(
            onPressed: _controller.reload,
            icon: const Icon(Icons.replay_rounded),
            color: color.primary,
          ),
          IconButton(
            onPressed: () {
              context.go('/home/gps-test');
            },
            icon: const Icon(Icons.gps_fixed),
            color: color.primary,
          ),
        ],
      ),
      body: _hasError
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Gagal memuat halaman.\nPeriksa koneksi internet Anda.",
                      textAlign: TextAlign.center,
                      style: kTitle6TextStyle,
                    ),
                    SizedBox(height: 10),
                    PrimaryElevatedButton(
                      onPressed: _reloadPage,
                      text: 'Coba Lagi',
                    ),
                  ],
                ),
              ),
            )
          : _isLoading
              ? Center(
                  child: CircularPercentIndicator(
                    radius: 100.0,
                    lineWidth: 10.0,
                    percent: _progress / 100,
                    animation: true,
                    header: Text("Icon header"),
                    center: Text("$_progress%"),
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                  ),
                )
              : WebViewWidget(controller: _controller),
    );
  }
}
