import 'dart:convert';
import 'dart:io';

import 'package:digital_shores/app/domain/entities/information.dart';
import 'package:digital_shores/app/domain/repositories/information_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';

class AddInformationNotifier extends ChangeNotifier {
  // form
  late TextEditingController titleController;
  late TextEditingController authorController;
  late QuillController contentController;
  late ValueNotifier<InformationCategory?> categoryController;
  late ValueNotifier<DateTime?> createdAtController;
  late ValueNotifier<File?> imageController;
  late GlobalKey<FormState> formKey;
  Information? selectedData;

  // state
  NotifierState<Information> addDataState = NotifierState();
  NotifierState<Information> updateDataState = NotifierState();
  NotifierState<Information> deleteDataState = NotifierState();

  final InformationRepository _repository;

  AddInformationNotifier({required InformationRepository repository}) : _repository = repository;

  void initForm() {
    titleController = TextEditingController(text: selectedData?.title);
    authorController = TextEditingController(text: selectedData?.author);
    contentController = QuillController.basic();
    contentController.document = selectedData?.content ?? Document();
    categoryController = ValueNotifier(selectedData?.category ?? InformationCategory.regulation);
    createdAtController = ValueNotifier(selectedData?.updatedAt);
    imageController = ValueNotifier(null);
    formKey = GlobalKey<FormState>();
  }

  void reset() async {
    titleController.clear();
    authorController.clear();
    // contentController.document.close();
    contentController.document = Document();
    categoryController.value = null;
    createdAtController.value = DateTime.now();
    imageController.value = null;
    formKey.currentState?.reset();
    selectedData = null;
  }

  void setSelectedData(Information information) {
    selectedData = information;
  }

  void setCategory(InformationCategory category) {
    categoryController.value = category;
    notifyListeners();
  }

  bool isEdit() => selectedData != null;

  Future<void> addInformation(String authorId) async {
    if (!formKey.currentState!.validate()) return;

    addDataState.setLoading();
    notifyListeners();

    final result = await _repository.addInformation(
      title: titleController.text,
      image: imageController.value!,
      content: jsonEncode(contentController.document.toDelta().toJson()),
      authorId: authorId,
      authorName: authorController.text,
      category: categoryController.value!.index,
    );

    result.fold(
      (failure) => addDataState.setError(failure: failure),
      (data) {
        addDataState.setSuccess(value: data);
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => addDataState.reset());
  }

  Future<void> updateInformation(String authorId) async {
    if (!formKey.currentState!.validate()) return;

    updateDataState.setLoading();
    notifyListeners();

    final result = await _repository.updateInformation(
      id: selectedData!.id,
      title: titleController.text,
      image: imageController.value,
      content: jsonEncode(contentController.document.toDelta().toJson()),
      authorId: authorId,
      category: categoryController.value!.index,
      oldInformation: selectedData!,
    );

    result.fold(
      (failure) => updateDataState.setError(failure: failure),
      (data) {
        updateDataState.setSuccess(value: data);
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => updateDataState.reset());
  }

  Future<void> deleteInformation(Information information) async {
    deleteDataState.setLoading();
    notifyListeners();

    final result = await _repository.deleteInformation(information: information);

    result.fold(
      (failure) => deleteDataState.setError(failure: failure),
      (information) {
        deleteDataState.setSuccess(value: information);
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => deleteDataState.reset());
  }

  Future<void> showOptions(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () async {
              Navigator.of(context).pop();
              getImage();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () async {
              Navigator.of(context).pop();
              getImage(fromGallery: false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> getImage({bool fromGallery = true}) async {
    final ImagePicker picker = ImagePicker();
    late XFile? pickedFile;
    if (fromGallery) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    }

    if (pickedFile == null) return;

    imageController.value = File(pickedFile.path);
  }
}
