import 'dart:io';

import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class AnimatedImageGrid extends StatefulWidget {
  final AdministrationNotifier notifier;

  const AnimatedImageGrid({
    super.key,
    required this.notifier,
  });

  @override
  State<AnimatedImageGrid> createState() => _AnimatedImageGridState();
}

class _AnimatedImageGridState extends State<AnimatedImageGrid> {
  final GlobalKey<AnimatedGridState> _gridKey = GlobalKey<AnimatedGridState>();
  late List<File> _currentList;

  @override
  void initState() {
    super.initState();
    _currentList = List.from(widget.notifier.imagesController.value);

    // Listen for changes and handle animations
    widget.notifier.imagesController.addListener(_handleListChanges);
  }

  @override
  void dispose() {
    widget.notifier.imagesController.removeListener(_handleListChanges);
    super.dispose();
  }

  void _handleListChanges() {
    final newList = widget.notifier.imagesController.value;

    // Create a map of files that exist in both lists to their new positions
    final Map<File, int> newPositions = {};
    for (int i = 0; i < newList.length; i++) {
      newPositions[newList[i]] = i;
    }

    // Handle removals first
    final List<File> itemsToRemove = [];
    for (int i = 0; i < _currentList.length; i++) {
      if (!newPositions.containsKey(_currentList[i])) {
        itemsToRemove.add(_currentList[i]);
      }
    }

    // Remove items in reverse order to prevent index issues
    for (int i = _currentList.length - 1; i >= 0; i--) {
      if (itemsToRemove.contains(_currentList[i])) {
        final removedItem = _currentList[i];
        _gridKey.currentState?.removeItem(
          i,
          (context, animation) => _buildItem(removedItem, animation),
          duration: const Duration(milliseconds: 300),
        );
        _currentList.removeAt(i);
      }
    }

    // Now handle additions and moves
    for (int newIndex = 0; newIndex < newList.length; newIndex++) {
      final File item = newList[newIndex];
      final int oldIndex = _currentList.indexOf(item);

      if (oldIndex < 0) {
        // This is a new item
        _currentList.insert(newIndex, item);
        _gridKey.currentState?.insertItem(
          newIndex,
          duration: const Duration(milliseconds: 300),
        );
      } else if (oldIndex != newIndex) {
        // This item moved
        final movedItem = _currentList.removeAt(oldIndex);
        _currentList.insert(newIndex, movedItem);
        _gridKey.currentState?.insertItem(
          newIndex,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
  }

  Widget _buildItem(File file, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.5),
                    BlendMode.lighten,
                  ),
                ),
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                    size: 48,
                  ),
                  onPressed: () => widget.notifier.removeImage(file),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return FormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (widget.notifier.imagesController.value.isEmpty) {
            return 'Pilih minimal satu gambar';
          }
          return null;
        },
        builder: (field) {
          return ValueListenableBuilder<List<File>>(
            valueListenable: widget.notifier.imagesController,
            builder: (context, value, child) {
              // Calculate grid height based on number of items
              final int itemCount = value.length + 1; // +1 for add button
              final int itemsPerRow =
                  (MediaQuery.of(context).size.width - 32) ~/ 98; // 90 + 8 spacing
              final int rowCount = (itemCount / itemsPerRow).ceil();
              final double gridHeight = rowCount * 98; // 90 + 8 spacing

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gambar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: gridHeight,
                    child: AnimatedGrid(
                      key: _gridKey,
                      initialItemCount: itemCount,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 100,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index, animation) {
                        if (index == value.length) {
                          // Add button
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: InkWell(
                                onTap: () => widget.notifier.showOptions(context),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: color.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: color.onPrimary,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tambah\nGambar',
                                        style: TextStyle(
                                          color: color.onPrimary,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        // Image items
                        return _buildItem(value[index], animation);
                      },
                    ),
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        top: 10,
                        bottom: kDefaultPadding,
                      ),
                      child: Text(
                        field.errorText!,
                        style: const TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 13,
                          color: kDefaultErrorColor,
                          height: 0.5,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        });
  }
}
