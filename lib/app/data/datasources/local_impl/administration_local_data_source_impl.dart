import 'dart:io';

import 'package:digital_shores/app/data/datasources/abstract/menu/administration/administration_local_data_source.dart';
import 'package:digital_shores/app/data/models/administration_document_image_model.dart';
import 'package:digital_shores/app/data/models/administration_document_model.dart';
import 'package:digital_shores/core/database/database_helper.dart';
import 'package:digital_shores/core/parameters/administration_parameters.dart';
import 'package:digital_shores/core/utils/generate_id.dart';
import 'package:digital_shores/core/utils/local_image_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AdministrationLocalDataSourceImpl extends AdministrationLocalDataSource {
  final DatabaseHelper _databaseHelper;
  final SharedPreferences _sharedPreferences;

  AdministrationLocalDataSourceImpl(
      {required DatabaseHelper databaseHelper, required SharedPreferences sharedPreferences})
      : _databaseHelper = databaseHelper,
        _sharedPreferences = sharedPreferences;

  @override
  Future<AdministrationDocumentModel> addDocumentToLocal(AddDocumentToLocalParameter params) async {
    final db = await _databaseHelper.database;
    final userId = _sharedPreferences.getString('user_id')!;
    final createdAt = DateTime.now().millisecondsSinceEpoch;

    final List<AdministrationDocumentImageModel> images = [];

    final documentId = GenerateId.generateNewId();

    // save image to local
    for (final image in params.images) {
      final localPath = await LocalImageHandler.saveImage(image);

      final newImage = AdministrationDocumentImageModel(
        id: GenerateId.generateNewId(),
        documentId: documentId,
        localPath: localPath,
        createdAt: createdAt,
      );

      images.add(newImage);

      // add new image to database
      await db.insert(
        'document_images',
        newImage.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final document = AdministrationDocumentModel(
      id: documentId,
      userId: userId,
      type: params.type,
      customType: params.customType,
      requirements: params.requirements,
      images: images,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final json = document.toJson();
    json.remove('images');
    json.remove('requirements');

    await db.insert(
      'administration_documents',
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final requirement in params.requirements) {
      await db.insert(
        'document_requirements',
        {
          'id': GenerateId.generateNewId(),
          'document_id': document.id,
          'requirement': requirement,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return document;
  }

  @override
  Future<List<AdministrationDocumentModel>> cacheDocumentsToLocal(
      CacheDocumentsToLocalParameter params) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    final List<AdministrationDocumentModel> newDocuments = [];

    for (final document in params.documents) {
      final List<AdministrationDocumentImageModel> newImages = [];
      // save images to local
      for (final image in document.images) {
        final localPath = await LocalImageHandler.saveImageFromFirebase(image.cloudUrl!);

        final newImage = image.copyWith(localPath: localPath);

        batch.insert(
          'document_images',
          newImage.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        newImages.add(newImage);
      }

      final newDocument = document.copyWith(images: newImages);
      final json = newDocument.toJson();
      json.remove('images');
      json.remove('requirements');

      batch.insert(
        'administration_documents',
        // document.toJson(),
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      newDocuments.add(newDocument);

      for (final requirement in document.requirements) {
        batch.insert(
          'document_requirements',
          {
            'id': GenerateId.generateNewId(),
            'document_id': document.id,
            'requirement': requirement,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
    return newDocuments;
  }

  @override
  Future<void> clearDocumentsFromLocal() async {
    final db = await _databaseHelper.database;

    // for all images, delete the images from local storage
    final images = await db.query('document_images');

    for (final image in images) {
      await LocalImageHandler.deleteImage(image['local_path'] as String);
    }

    await db.delete('administration_documents');
    await db.delete('document_images');
    await db.delete('document_requirements');
  }

  @override
  Future<AdministrationDocumentModel> deleteDocumentFromLocal(
      DeleteDocumentFromLocalParameter params) async {
    final db = await _databaseHelper.database;

    final document = await db.query(
      'administration_documents',
      where: 'id = ?',
      whereArgs: [params.id],
    );

    if (document.isNotEmpty) {
      final imagesQuery = await db.query(
        'document_images',
        where: 'document_id = ?',
        whereArgs: [params.id],
      );

      final images = imagesQuery.map((image) => image).toList();

      final requirementsQuery = await db.query(
        'document_requirements',
        where: 'document_id = ?',
        whereArgs: [params.id],
      );

      final requirements =
          requirementsQuery.map((requirement) => requirement['requirement'] as int).toList();

      final Map<String, dynamic> json = Map.from(document.first);

      json['images'] = images;
      json['requirements'] = requirements;

      final documentModel = AdministrationDocumentModel.fromJson(json);

      // delete images from local storage
      for (final image in documentModel.images) {
        await LocalImageHandler.deleteImage(image.localPath!);
      }

      // make all images and document as deleted
      await db.update(
        'administration_documents',
        {
          'is_deleted': 1,
          'deleted_at': DateTime.now().millisecondsSinceEpoch,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [params.id],
      );

      await db.update(
        'document_images',
        {
          'is_deleted': 1,
          'deleted_at': DateTime.now().millisecondsSinceEpoch,
          'is_synced': 0,
        },
        where: 'document_id = ?',
        whereArgs: [params.id],
      );

      // delete document
      // await db.delete(
      //   'administration_documents',
      //   where: 'id = ?',
      //   whereArgs: [params.id],
      // );

      // delete images
      // await db.delete(
      //   'document_images',
      //   where: 'document_id = ?',
      //   whereArgs: [params.id],
      // );

      // delete requirements
      // await db.delete(
      //   'document_requirements',
      //   where: 'document_id = ?',
      //   whereArgs: [params.id],
      // );

      return documentModel;
    } else {
      throw Exception('Document not found');
    }
  }

  @override
  Future<List<AdministrationDocumentModel>> getDocumentsFromLocal(
      GetDocumentsFromLocalParameter params) async {
    final db = await _databaseHelper.database;

    final documents = await db.query(
      'administration_documents',
      where: params.includeDeleted ? null : 'is_deleted = ?',
      whereArgs: params.includeDeleted ? null : [0],
    );

    final List<AdministrationDocumentModel> documentModels = [];

    for (final data in documents) {
      Map<String, dynamic> document = Map.from(data);
      final requirements = await db.query(
        'document_requirements',
        where: 'document_id = ?',
        whereArgs: [document['id']],
      );
      document['requirements'] = requirements.map((e) => e['requirement'] as int).toList();

      final images = await db.query(
        'document_images',
        where: 'document_id = ?',
        whereArgs: [document['id']],
      );

      document['images'] = images;

      final documentModel = AdministrationDocumentModel.fromJson(document);

      // final documentImages = images.where((image) => image['document_id'] == documentModel.id);
      // final documentRequirements =
      //     requirements.where((requirement) => requirement['document_id'] == documentModel.id);

      // final imagesList =
      //     documentImages.map((image) => AdministrationDocumentImageModel.fromJson(image)).toList();
      // final requirementsList =
      //     documentRequirements.map((requirement) => requirement['requirement'] as int).toList();

      documentModels.add(documentModel);
    }

    return documentModels;
  }

  Future<bool> areFilesIdentical(File file1, File file2) async {
    if (await file1.length() != await file2.length()) {
      return false; // Different sizes mean different files
    }

    List<int> bytes1 = await file1.readAsBytes();
    List<int> bytes2 = await file2.readAsBytes();

    return bytes1.length == bytes2.length && bytes1.every((byte) => bytes2.contains(byte));
  }

  @override
  Future<AdministrationDocumentModel> updateDocumentFromLocal(
      UpdateDocumentFromLocalParameter params) async {
    final db = await _databaseHelper.database;

    final documentQuery = await db.query(
      'administration_documents',
      where: 'id = ?',
      whereArgs: [params.id],
    );

    Map<String, dynamic> documentMap = Map.from(documentQuery.first);

    final requirements = await db.query(
      'document_requirements',
      where: 'document_id = ?',
      whereArgs: [params.id],
    );

    documentMap['requirements'] = requirements.map((e) => e['requirement'] as int).toList();

    final images = await db.query(
      'document_images',
      where: 'document_id = ?',
      whereArgs: [params.id],
    );

    documentMap['images'] = images;

    final document = AdministrationDocumentModel.fromJson(documentMap);

    final newImages = <AdministrationDocumentImageModel>[];
    final deletedImages = <AdministrationDocumentImageModel>[];

    // if any images are deleted or added, update the images
    if (true) {
      // check for any deleted image
      for (final image in params.images) {
        if (image.isDeleted == 1) {
          await LocalImageHandler.deleteImage(image.localPath!);
          deletedImages.add(image);
          await db.update(
            'document_images',
            {'is_deleted': 1},
            where: 'id = ?',
            whereArgs: [image.id],
          );
        } else {
          newImages.add(image);
        }
      }

      // add new images
      for (final image in params.newImages) {
        final localPath = await LocalImageHandler.saveImage(image);

        final newImage = AdministrationDocumentImageModel(
          id: GenerateId.generateNewId(),
          documentId: params.id,
          localPath: localPath,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        newImages.add(newImage);

        await db.insert(
          'document_images',
          newImage.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    // new document
    AdministrationDocumentModel updatedDocument = document.copyWith(
      type: params.type,
      customType: params.customType,
      requirements: params.requirements,
      images: newImages,
    );

    // check if document has been updated
    if (params.documentUpdated) {
      final updatedAt = DateTime.now().millisecondsSinceEpoch;

      updatedDocument = updatedDocument.copyWith(
        updatedAt: updatedAt,
        isSynced: 0,
      );

      final json = updatedDocument.toJson();
      json.remove('images');
      json.remove('requirements');

      await db.update(
        'administration_documents',
        json,
        where: 'id = ?',
        whereArgs: [params.id],
      );

      // update requirements
      await db.delete(
        'document_requirements',
        where: 'document_id = ?',
        whereArgs: [params.id],
      );

      for (final requirement in params.requirements) {
        await db.insert(
          'document_requirements',
          {
            'id': GenerateId.generateNewId(),
            'document_id': params.id,
            'requirement': requirement,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    // if the images updated, update the images
    if (newImages.isNotEmpty) {
      updatedDocument = updatedDocument.copyWith(images: newImages);
    }

    return updatedDocument;
  }

  // this method will be called after all data synced to firebase. the parameter contains the documents that are synced to firebase with cloud url
  @override
  Future<List<AdministrationDocumentModel>> syncDocumentsToLocal(
      SyncDocumentsToLocalParameter params) async {
    // for all documents, check if its deleted. if yes, then delete it and all of its requirements and images
    // if not, then check if all of its images is deleted. if yes, then delete the images. if not, then set the images as synced. in the end, set this image as synced
    final db = await _databaseHelper.database;

    // final documents = await db.query('administration_documents');
    final documents = params.documents;

    final List<AdministrationDocumentModel> updatedDocuments = [];

    for (final document in documents) {
      // final documentModel = AdministrationDocumentModel.fromJson(document);
      final documentModel = document;

      if (documentModel.isDeleted == 1) {
        // delete document
        await db.delete(
          'administration_documents',
          where: 'id = ?',
          whereArgs: [documentModel.id],
        );

        // delete images. no need to remove the images from local storage as they are already deleted
        await db.delete(
          'document_images',
          where: 'document_id = ?',
          whereArgs: [documentModel.id],
        );

        // delete requirements
        await db.delete(
          'document_requirements',
          where: 'document_id = ?',
          whereArgs: [documentModel.id],
        );
      } else {
        // delete images that are deleted
        await db.delete(
          'document_images',
          where: 'document_id = ? AND is_deleted = 1',
          whereArgs: [documentModel.id],
        );

        // for the images that are not deleted, set them as synced
        await db.update(
          'document_images',
          {'is_synced': 1},
          where: 'document_id = ?',
          whereArgs: [documentModel.id],
        );

        // get all images
        final images = await db.query(
          'document_images',
          where: 'document_id = ?',
          whereArgs: [documentModel.id],
        );

        final syncedImages =
            images.map((image) => AdministrationDocumentImageModel.fromJson(image)).toList();

        // set the document as synced
        final updatedDocument = documentModel.copyWith(
          images: syncedImages,
          isSynced: 1,
        );

        updatedDocuments.add(updatedDocument);
        final json = updatedDocument.toJson();
        json.remove('images');
        json.remove('requirements');

        await db.update(
          'administration_documents',
          // updatedDocument.toJson(),
          json,
          where: 'id = ?',
          whereArgs: [documentModel.id],
        );
      }
    }

    // use join query to get all the documents with images and requirements

    final allDocuments =
        await getDocumentsFromLocal(GetDocumentsFromLocalParameter(includeDeleted: false));

    return allDocuments;
  }

  @override
  Future<bool> canSyncDocumentsToLocal() async {
    final db = await _databaseHelper.database;

    final documents = await db.query('administration_documents', where: 'is_synced = 0');

    final images = await db.query('document_images', where: 'is_synced = 0');

    return documents.isNotEmpty || images.isNotEmpty;
  }
}
