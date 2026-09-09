import 'package:digital_shores/app/presentation/pages/plot/seaweed_information_card.dart';
import 'package:flutter/material.dart';

class SeaweedInformationDialog
    extends StatefulWidget {
  const SeaweedInformationDialog({
    super.key,
    required this.dialogTitle,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialIcon = 'info',
  });

  final String dialogTitle;
  final String initialTitle;
  final String initialContent;
  final String initialIcon;

  @override
  State<SeaweedInformationDialog>
      createState() =>
          _SeaweedInformationDialogState();
}

class _SeaweedInformationDialogState
    extends State<SeaweedInformationDialog> {
  late final TextEditingController
      _titleController;

  late final TextEditingController
      _contentController;

  late String _selectedIcon;

  final List<String> _icons = [
    'grass',
    'eco',
    'water',
    'waves',
    'book',
    'lightbulb',
    'warning',
    'science',
    'info',
  ];

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(
      text: widget.initialTitle,
    );

    _contentController =
        TextEditingController(
      text: widget.initialContent,
    );

    _selectedIcon =
        _icons.contains(widget.initialIcon)
            ? widget.initialIcon
            : 'info';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  void _save() {
    final title =
        _titleController.text.trim();

    final content =
        _contentController.text.trim();

    if (title.isEmpty ||
        content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Judul dan isi tidak boleh kosong.',
          ),
        ),
      );

      return;
    }

    Navigator.pop(
      context,
      {
        'title': title,
        'content': content,
        'icon': _selectedIcon,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(
        widget.dialogTitle,
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              TextField(
                controller:
                    _titleController,
                decoration:
                    const InputDecoration(
                  labelText: 'Judul',
                  border:
                      OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller:
                    _contentController,
                maxLines: 5,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Isi Informasi',
                  border:
                      OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Ikon',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _icons.map(
                  (iconName) {
                    final selected =
                        _selectedIcon ==
                            iconName;

                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          _selectedIcon =
                              iconName;
                        });
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.all(10),
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                          border: Border.all(
                            color: selected
                                ? primaryColor
                                : Colors.grey,
                            width: selected
                                ? 2
                                : 1,
                          ),
                        ),
                        child: Icon(
                          seaweedIconFromName(
                            iconName,
                          ),
                          color: selected
                              ? primaryColor
                              : Colors.grey,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}