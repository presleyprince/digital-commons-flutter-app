import 'package:cloud_firestore/cloud_firestore.dart';

class LocationRemoteDataSourceFirebase {
  final FirebaseFirestore firestore;

  LocationRemoteDataSourceFirebase({required this.firestore});

  Future<List<Map<String, dynamic>>> getRegions() async {
    final snapshot = await firestore.collection('regions').get();

    return snapshot.docs.map((doc) {
      return {
        'document_id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getDistricts() async {
    final snapshot = await firestore.collection('districts').get();

    return snapshot.docs.map((doc) {
      return {
        'document_id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getDistrictsByRegion(String regionId) async {
    final snapshot = await firestore
        .collection('districts')
        .where('region_id', isEqualTo: regionId)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'document_id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }
}