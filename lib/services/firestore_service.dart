import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para obtener usuario directamente por su UID
  Future<Map<String, dynamic>?> getUserDataById(String uid) async {
    try {
      // Leemos el documento directo (.doc().get())
      DocumentSnapshot docSnapshot = await _db
          .collection('tests')
          .doc('app_tests')
          .collection('users')
          .doc(uid) // Buscamos por el ID directamente
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        print('El usuario existe en Auth pero no tiene documento en Firestore');
        return null;
      }
    } catch (e) {
      print('Error leyendo Firestore: $e');
      return null;
    }
  }

  /// Campañas cuyo campo [organization] coincide con el del usuario.
  Future<List<Map<String, dynamic>>> getCampaignsByOrganization(
    String organization,
  ) async {
    if (organization.isEmpty) {
      return [];
    }
    try {
      final snapshot = await _db
          .collection('tests')
          .doc('app_tests')
          .collection('campaigns')
          .where('organization', isEqualTo: organization)
          .get();

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['campaignId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error leyendo campañas por organización: $e');
      rethrow;
    }
  }

  // Método para buscar una campaña
  Future<Map<String, dynamic>?> getCampaignById(String campaignId) async {
    try {
      DocumentSnapshot docSnapshot = await _db
          .collection('tests')
          .doc('app_tests')
          .collection('campaigns')
          .doc(campaignId) // Buscamos directamente el documento por su ID
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        print('La campaña con ID $campaignId no existe');
        return null;
      }
    } catch (e) {
      print('Error leyendo la campaña: $e');
      return null;
    }
  }

  // Método para escuchar los receptores de una campaña en tiempo real
  Stream<List<Map<String, dynamic>>> getReceiversStream(String campaignId) {
    return _db
        .collection('tests')
        .doc('app_tests')
        .collection('campaignReceivers')
        .where('campaignId', isEqualTo: campaignId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['docId'] = doc.id;
            return data;
          }).toList();
        });
  } // <--- ¡AQUÍ CERRAMOS EL MÉTODO getReceiversStream!

  // --- MÉTODOS CRUD PARA RECEPTORES ---

  Future<void> createReceiver(Map<String, dynamic> data) async {
    await _db
        .collection('tests')
        .doc('app_tests')
        .collection('campaignReceivers')
        .add(data);
  }

  Future<void> updateReceiver(String docId, Map<String, dynamic> data) async {
    await _db
        .collection('tests')
        .doc('app_tests')
        .collection('campaignReceivers')
        .doc(docId)
        .update(data);
  }

  Future<void> deleteReceiver(String docId) async {
    await _db
        .collection('tests')
        .doc('app_tests')
        .collection('campaignReceivers')
        .doc(docId)
        .delete();
  }
}
