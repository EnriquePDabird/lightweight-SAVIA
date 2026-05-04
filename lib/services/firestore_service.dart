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

  // NUEVO: Método para escuchar los receptores de una campaña en tiempo real
  Stream<List<Map<String, dynamic>>> getReceiversStream(String campaignId) {
    return _db
        .collection('tests')
        .doc('app_tests')
        .collection('campaignReceivers')
        .where(
          'campaignId',
          isEqualTo: campaignId,
        ) // Trae solo los de esta campaña
        .snapshots() // 'snapshots()' crea la conexión en tiempo real
        .map((snapshot) {
          // Convertimos cada documento encontrado en un Mapa (diccionario)
          return snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
  }
}
