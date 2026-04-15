import 'dart:io';

import 'package:digital_shores/app/domain/entities/administration_document.dart';
import 'package:digital_shores/app/domain/repositories/administration_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/local_image_handler.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class AdministrationNotifier extends ChangeNotifier {
  // state
  NotifierState<void> addDataState = NotifierState();
  NotifierState<void> deleteDataState = NotifierState();
  NotifierState<void> fetchDataState = NotifierState();
  NotifierState<void> syncDataState = NotifierState();

  // form
  late ValueNotifier<DocumentType?> documentTypeController;
  late TextEditingController customTypeController;
  late ValueNotifier<List<DocumentRequirement>> requirementsController;
  late ValueNotifier<List<File>> imagesController;
  late GlobalKey<FormState> formKey;
  late ValueNotifier<List<File>> newImagesController;
  // late int addedImage; // this is used to track how many images have been added when update a document. get n values from tail of imagesController.value
  AdministrationDocument? selectedData;

  late ValueNotifier<DocumentRequirement?> documentRequirementFilterController;
  late TextEditingController searchController;

  // data
  ValueNotifier<List<AdministrationDocument>> documents =
      ValueNotifier([]); // this variable is used to show filtered data
  List<AdministrationDocument> allDocuments =
      []; // this variable is used to store all data. when filter is off, show this data

  final AdministrationRepository _repository;

  AdministrationNotifier({required AdministrationRepository repository}) : _repository = repository;

  void initFilter() {
    documentRequirementFilterController = ValueNotifier(null);
    searchController = TextEditingController();

    documentRequirementFilterController.addListener(updateFilter);

    searchController.addListener(() {
      updateFilter();
    });
  }

  void updateFilter() {
    final DocumentRequirement? filter = documentRequirementFilterController.value;
    final String search = searchController.text;

    documents.value = allDocuments.where((e) {
      final bool isRequirementMatch = filter == null || e.requirements.contains(filter);
      final bool isSearchMatch =
          search.isEmpty || e.type.label.toLowerCase().contains(search.toLowerCase());
      return isRequirementMatch && isSearchMatch;
    }).toList();
    Future.microtask(() => notifyListeners());
  }

  void resetFilter() {
    documentRequirementFilterController.value = null;
    searchController.clear();
  }

  void setSelectedData(AdministrationDocument data) {
    selectedData = data;
  }

  void deleteDataList() {
    documents.value = [];
  }

  void clearDocumentsFromLocal() async {
    await _repository.clearDocumentsFromLocal();
  }

  void initForm() {
    addDataState.reset();
    documentTypeController = ValueNotifier(selectedData?.type);
    customTypeController = TextEditingController(text: selectedData?.customType);
    requirementsController = ValueNotifier(selectedData?.requirements ?? []);
    imagesController = ValueNotifier(selectedData?.images
            .where((e) => !e.isDeleted)
            .map((e) => LocalImageHandler.getFileFromLocalPath(e.localPath))
            .toList() ??
        []);
    if (selectedData != null) newImagesController = ValueNotifier([]);
    formKey = GlobalKey<FormState>();
  }

  void clearForm() {
    selectedData = null;
    documentTypeController.value = null;
    customTypeController.clear();
    requirementsController.value = [];
    imagesController.value = [];
    if (selectedData != null) newImagesController.value = [];
  }

  void clearCustomType() {
    customTypeController.clear();
  }

  void reset() {
    clearForm();
  }

  void setDocumentRequirements(DocumentRequirement requirement) {
    if (requirementsController.value.contains(requirement)) {
      requirementsController.value =
          requirementsController.value.where((e) => e != requirement).toList();
    } else {
      requirementsController.value = [...requirementsController.value, requirement];
    }
  }

  void addImage(File image) {
    imagesController.value = [...imagesController.value, image];
    if (selectedData != null) {
      newImagesController.value = [...newImagesController.value, image];
    }
  }

  void removeImage(File image) {
    imagesController.value = imagesController.value.where((e) => e != image).toList();
    if (selectedData != null) {
      newImagesController.value = newImagesController.value.where((e) => e != image).toList();
      // set the image in the selected data image is_deleted to true
      selectedData = selectedData!.copyWith(
        images: selectedData!.images
            .map((e) => e.localPath == image.path ? e.copyWith(isDeleted: true) : e)
            .toList(),
      );
    }
  }

  Future<void> fetchData(String userId) async {
    fetchDataState.setLoading();
    final result = await _repository.getDocuments(userId: userId);
    result.fold(
      (failure) => fetchDataState.setError(failure: failure),
      (data) {
        documents.value = data;
        allDocuments = data;
        fetchDataState.setSuccess();
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => fetchDataState.reset());
  }

  Future<void> addData() async {
    if (!formKey.currentState!.validate()) return;

    addDataState.setLoading();

    final bool documentUpdated = selectedData != null &&
        (documentTypeController.value != selectedData!.type ||
            customTypeController.text != selectedData!.customType ||
            requirementsController.value != selectedData!.requirements);

    final result = selectedData == null
        ? await _repository.addDocumentToLocal(
            type: documentTypeController.value!,
            customType: customTypeController.text.isEmpty ? null : customTypeController.text,
            requirements: requirementsController.value,
            images: imagesController.value,
          )
        : await _repository.updateDocumentFromLocal(
            id: selectedData!.id,
            type: documentTypeController.value!,
            customType: customTypeController.text.isEmpty ? null : customTypeController.text,
            requirements: requirementsController.value,
            documentUpdated: documentUpdated,
            images: selectedData!.images,
            newImages: newImagesController.value,
          );
    result.fold(
      (failure) => addDataState.setError(failure: failure),
      (data) {
        if (selectedData != null) {
          documents.value = documents.value.map((e) => e.id == data.id ? data : e).toList();
        } else {
          documents.value = [...documents.value, data];
        }

        allDocuments = documents.value;
        addDataState.setSuccess();
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => addDataState.reset());
  }

  Future<void> deleteData(String id) async {
    deleteDataState.setLoading();
    final result = await _repository.deleteDocumentFromLocal(id: id);
    result.fold(
      (failure) => deleteDataState.setError(failure: failure),
      (_) {
        documents.value = documents.value.where((e) => e.id != id).toList();
        allDocuments = documents.value;
        deleteDataState.setSuccess();
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => deleteDataState.reset());
  }

  bool dataEmpty() {
    return documents.value.isEmpty;
  }

  void syncDocuments() async {
    syncDataState.setLoading();
    notifyListeners();
    final result = await _repository.syncDocuments(documents: documents.value);
    result.fold(
      (failure) => syncDataState.setError(failure: failure),
      (data) {
        documents.value = data;
        allDocuments = data;
        syncDataState.setSuccess();
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => syncDataState.reset());
  }

  Future<void> getDataFromLocal() async {
    final data = await _repository.getDocumentsFromLocal();
    documents.value = data;
    allDocuments = data;
  }

  // profile image
  Future<void> showOptions(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Galeri'),
            onPressed: () async {
              Navigator.of(context).pop();
              getImage();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Kamera'),
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

    final File image = File(pickedFile.path);
    addImage(image);
  }
}
