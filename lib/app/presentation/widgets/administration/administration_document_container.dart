// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/domain/entities/administration_document.dart';
import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/core/utils/local_image_handler.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdministrationDocumentContainer extends StatefulWidget {
  const AdministrationDocumentContainer({
    super.key,
    required this.data,
  });

  final AdministrationDocument data;

  @override
  State<AdministrationDocumentContainer> createState() => _AdministrationDocumentContainerState();
}

class _AdministrationDocumentContainerState extends State<AdministrationDocumentContainer>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _opacityFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _opacityFactor = _controller.drive(
      CurveTween(curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data.type != DocumentType.other
                        ? widget.data.type.label
                        : widget.data.customType!,
                    style: kSubtitle4TextStyle,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: color.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: Opacity(
                    opacity: _opacityFactor.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  // Image that takes full width
                  ...widget.data.images.map(
                    (image) => image.isDeleted
                        ? SizedBox()
                        : Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Image.file(
                              LocalImageHandler.getFileFromLocalPath(image.localPath),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryElevatedButton(
                          text: 'Ubah',
                          short: true,
                          onPressed: () => Future.microtask(
                            () {
                              Provider.of<AdministrationNotifier>(context, listen: false)
                                  .setSelectedData(widget.data);
                              router.push('/home/administration/add');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Consumer<AdministrationNotifier>(builder: (context, value, child) {
                          // final state = value.deleteDataState;

                          // if (state.stateError()) {
                          //   // Future.microtask(() => Navigator.pop(context));
                          //   CustomSnackbar.alert(context, state.failure!.message);
                          // } else if (state.stateSuccess()) {
                          //   // Future.microtask(() => Navigator.pop(context));
                          //   CustomSnackbar.success(context, 'Berhasil menghapus data');
                          // }

                          // if (!state.stateInitial()) {
                          //   return const LoadingIndicator();
                          // }

                          return PrimaryElevatedButton(
                            text: 'Hapus',
                            red: true,
                            short: true,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Consumer<AdministrationNotifier>(
                                    builder: (context, value, child) {
                                      final state = value.deleteDataState;

                                      if (state.stateError()) {
                                        Navigator.pop(context);
                                        CustomSnackbar.alert(context, state.failure!.message);
                                      } else if (state.stateSuccess()) {
                                        Future.microtask(() => Navigator.pop(context));
                                        CustomSnackbar.success(context, 'Berhasil menghapus data');
                                      } else if (state.stateLoading()) {
                                        return const LoadingIndicator();
                                      }

                                      return AlertDialog(
                                        title: const Text('Hapus Data'),
                                        content: Text(
                                          'Berkas ${widget.data.customType ?? widget.data.type.label} akan dihapus.\nApakah Anda yakin?',
                                          textAlign: TextAlign.start,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              value.deleteData(widget.data.id);
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
