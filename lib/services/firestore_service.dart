import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/campaign_members.dart';

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

  /// Campañas en las que el usuario figura en el array [members] (UIDs).
  Future<List<Map<String, dynamic>>> getCampaignsForMember(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return [];
    }
    try {
      final snapshot = await _db
          .collection('tests')
          .doc('app_tests')
          .collection('campaigns')
          .where('members', arrayContains: uid)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['campaignId'] = doc.id;
            return data;
          })
          .where((c) => campaignHasMember(c, uid))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        throw Exception(
          'Falta el índice de Firestore para members (array-contains). '
          'Abre el enlace del error en la consola de Firebase y créalo.',
        );
      }
      print('Error leyendo campañas del miembro: $e');
      rethrow;
    } catch (e) {
      print('Error leyendo campañas del miembro: $e');
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
        final data = Map<String, dynamic>.from(
          docSnapshot.data()! as Map<String, dynamic>,
        );
        data['campaignId'] = docSnapshot.id;
        return data;
      } else {
        print('La campaña con ID $campaignId no existe');
        return null;
      }
    } catch (e) {
      print('Error leyendo la campaña: $e');
      return null;
    }
  }

  /// Receptores de varias campañas (lotes de 10 por límite de Firestore `whereIn`).
  Future<List<Map<String, dynamic>>> getReceiversForCampaigns(
    List<String> campaignIds,
  ) async {
    if (campaignIds.isEmpty) return [];

    final results = <Map<String, dynamic>>[];
    for (var i = 0; i < campaignIds.length; i += 10) {
      final end = (i + 10 > campaignIds.length) ? campaignIds.length : i + 10;
      final batch = campaignIds.sublist(i, end);
      final snapshot = await _db
          .collection('tests')
          .doc('app_tests')
          .collection('campaignReceivers')
          .where('campaignId', whereIn: batch)
          .get();
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['docId'] = doc.id;
        results.add(data);
      }
    }
    return results;
  }

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
