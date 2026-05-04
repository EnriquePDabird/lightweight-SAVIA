import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  final String campaignId;

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudo cargar la información de la campaña.'));
          }

          final campaignData = snapshot.data!;
          final String campaignName = (campaignData['name'] == null || campaignData['name'] == "") 
              ? "Campaña sin nombre" : campaignData['name'];
          final String category = (campaignData['category'] == null || campaignData['category'] == "") 
              ? "N/A" : campaignData['category'];
          final String organization = (campaignData['organization'] == null || campaignData['organization'] == "") 
              ? "No especificada" : campaignData['organization'];
          final String timezone = (campaignData['timezone'] == null || campaignData['timezone'] == "") 
              ? "No especificada" : campaignData['timezone'];

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
                
                // Tarjeta con la info de la campaña (No cambia)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.campaign, color: Colors.white),
                    ),
                    title: Text(campaignName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categoría: $category'),
                          Text('Organización: $organization'),
                          Text('Zona Horaria: $timezone'),
                          const SizedBox(height: 8),
                          Text('ID: $campaignId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30), // Espacio entre tarjeta y lista
                
                const Text(
                  'Receptores',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // NUEVO: La lista de receptores que ocupa el espacio restante
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirestoreService().getReceiversStream(campaignId),
                    builder: (context, receiversSnapshot) {
                      // Mientras conecta con la base de datos de receptores
                      if (receiversSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Si no hay datos o la lista está vacía
                      if (!receiversSnapshot.hasData || receiversSnapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Aún no hay receptores en esta campaña.',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      // Extraemos la lista de receptores
                      final receivers = receiversSnapshot.data!;

                      // Construimos la lista en pantalla
                      return ListView.builder(
                        itemCount: receivers.length,
                        itemBuilder: (context, index) {
                          final receiver = receivers[index];
                          // Leemos el teléfono, o mostramos un texto por defecto si no existe
                          final String phone = receiver['phone'] ?? 'Sin número';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.person, color: Colors.blueGrey),
                              title: Text('Teléfono: $phone', style: const TextStyle(fontWeight: FontWeight.w500)),
                              // A futuro, aquí puedes poner más subtítulos como 'Nombre: ${receiver['name']}'
                              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                              onTap: () {
                                // A futuro: Navegar al detalle de este receptor
                                print('Clic en el receptor con teléfono: $phone');
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}