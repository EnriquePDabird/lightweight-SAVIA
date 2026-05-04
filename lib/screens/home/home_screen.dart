import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  final String campaignId; // Recibiremos este dato desde el Login

  const HomeScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: FirestoreService().getCampaignById(campaignId),
        builder: (context, snapshot) {
          // 1. Mientras está cargando...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Si hubo un error o la campaña no existe...
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No se pudo cargar la información de la campaña.'),
            );
          }

          // 3. ¡Éxito! Tenemos los datos
          final campaignData = snapshot.data!;

          // Extraemos y validamos los datos (si están vacíos, ponemos un texto por defecto)
          final String campaignName =
              (campaignData['name'] == null || campaignData['name'] == "")
              ? "Campaña sin nombre"
              : campaignData['name'];
          final String category =
              (campaignData['category'] == null ||
                  campaignData['category'] == "")
              ? "N/A"
              : campaignData['category'];

          // NUEVO: Extraemos la organización y la zona horaria
          final String organization =
              (campaignData['organization'] == null ||
                  campaignData['organization'] == "")
              ? "No especificada"
              : campaignData['organization'];
          final String timezone =
              (campaignData['timezone'] == null ||
                  campaignData['timezone'] == "")
              ? "No especificada"
              : campaignData['timezone'];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campaña Asignada',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Tarjeta con la info de la campaña
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.campaign, color: Colors.white),
                    ),
                    title: Text(
                      campaignName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Actualizamos el subtítulo para mostrar una columna con más datos
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categoría: $category'),
                          Text('Organización: $organization'),
                          Text('Zona Horaria: $timezone'),
                          const SizedBox(height: 8),
                          Text(
                            'ID: $campaignId',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(), // Empuja el siguiente texto hacia abajo
                // Mensaje del futuro contenido
                const Center(
                  child: Text(
                    'Próximamente:\nAquí se mostrará la lista de Receptores Endpoint',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
