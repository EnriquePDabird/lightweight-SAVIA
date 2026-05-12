import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'receiver_form_screen.dart';

class HomeScreen extends StatelessWidget {
  final String campaignId;
  final String userName;
  final String userLastName;
  final String userRole;

  const HomeScreen({
    super.key,
    required this.campaignId,
    required this.userName,
    required this.userLastName,
    required this.userRole, // <-- NUEVO
  });

  @override
  Widget build(BuildContext context) {
    // Unimos nombre y apellido, si ambos están vacíos, ponemos "Usuario" por defecto
    final String fullName = (userName.isEmpty && userLastName.isEmpty)
        ? 'Usuario'
        : '$userName $userLastName'.trim();

    final bool isTechnic = userRole == 'technic';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isTechnic
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReceiverFormScreen(campaignId: campaignId),
                  ),
                );
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: FirestoreService().getCampaignById(campaignId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No se pudo cargar la información de la campaña.'),
            );
          }

          final campaignData = snapshot.data!;
          final String campaignName =
              (campaignData['name'] == null || campaignData['name'] == "")
              ? "Campaña sin nombre"
              : campaignData['name'];
          final String category =
              (campaignData['category'] == null ||
                  campaignData['category'] == "")
              ? "N/A"
              : campaignData['category'];
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
                // NUEVO: Saludo personalizado
                Text(
                  '¡Hola, $fullName!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24), // Espaciador

                const Text(
                  'Campaña Asignada',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

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

                const SizedBox(height: 30),

                const Text(
                  'Receptores Endpoint',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirestoreService().getReceiversStream(campaignId),
                    builder: (context, receiversSnapshot) {
                      if (receiversSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!receiversSnapshot.hasData ||
                          receiversSnapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aún no hay receptores en esta campaña.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }

                      final receivers = receiversSnapshot.data!;

                      return ListView.builder(
                        itemCount: receivers.length,
                        itemBuilder: (context, index) {
                          final receiver = receivers[index];
                          final String phone =
                              receiver['phone'] ?? 'Sin número';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.blueGrey,
                              ),
                              // Mostramos el nombre, si no hay, ponemos 'Sin nombre'
                              title: Text(
                                receiver['name'] != null &&
                                        receiver['name'].toString().isNotEmpty
                                    ? receiver['name']
                                    : 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Pasamos el teléfono al subtítulo
                              subtitle: Text('Tel: $phone'),

                              // La magia de los permisos: Si es técnico, ve botones. Si no, una flecha.
                              trailing: isTechnic
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // BOTÓN EDITAR
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ReceiverFormScreen(
                                                      campaignId: campaignId,
                                                      existingReceiver:
                                                          receiver, // Pasamos los datos para editar
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                        // BOTÓN BORRAR
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            // Cuadro de confirmación antes de borrar
                                            bool confirm =
                                                await showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text(
                                                      '¿Borrar receptor?',
                                                    ),
                                                    content: const Text(
                                                      'Esta acción no se puede deshacer.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Cancelar',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          'Borrar',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ) ??
                                                false;

                                            if (confirm) {
                                              await FirestoreService()
                                                  .deleteReceiver(
                                                    receiver['docId'],
                                                  );
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                              onTap: () {
                                print(
                                  'Clic en el receptor con teléfono: $phone',
                                );
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
