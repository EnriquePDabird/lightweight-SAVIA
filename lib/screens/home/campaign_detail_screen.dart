import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../utils/list_query_utils.dart';
import 'receiver_form_screen.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;
  final String userRole;

  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
    required this.userRole,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  late final Future<Map<String, dynamic>?> _campaignFuture;
  late final Stream<List<Map<String, dynamic>>> _receiversStream;
  final TextEditingController _receiverSearch = TextEditingController();

  ActiveTriFilter _activeFilter = ActiveTriFilter.all;
  String? _sexFilter;
  String? _groupFilter;
  ReceiverSortMode _receiverSort = ReceiverSortMode.nameAsc;

  /// Última lista del stream (para opciones de grupo en filtros).
  List<Map<String, dynamic>> _rawReceiversCache = [];

  @override
  void initState() {
    super.initState();
    _campaignFuture = FirestoreService().getCampaignById(widget.campaignId);
    _receiversStream = FirestoreService().getReceiversStream(widget.campaignId);
  }

  @override
  void dispose() {
    _receiverSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTechnic = widget.userRole == 'technic';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaña'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<ReceiverSortMode>(
            tooltip: 'Ordenar',
            initialValue: _receiverSort,
            onSelected: (m) => setState(() => _receiverSort = m),
            itemBuilder: (ctx) => [
              for (final m in ReceiverSortMode.values)
                PopupMenuItem(value: m, child: Text(labelReceiverSort(m))),
            ],
          ),
        ],
      ),
      floatingActionButton: isTechnic
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReceiverFormScreen(campaignId: widget.campaignId),
                  ),
                );
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _campaignFuture,
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
              (campaignData['name'] == null || campaignData['name'] == '')
              ? "Campaña sin nombre"
              : campaignData['name'] as String;
          final String category =
              (campaignData['category'] == null ||
                  campaignData['category'] == "")
              ? "N/A"
              : campaignData['category'] as String;
          final String organization =
              (campaignData['organization'] == null ||
                  campaignData['organization'] == "")
              ? "No especificada"
              : campaignData['organization'] as String;
          final String timezone =
              (campaignData['timezone'] == null ||
                  campaignData['timezone'] == "")
              ? "No especificada"
              : campaignData['timezone'] as String;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Card(
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
                            'ID: ${widget.campaignId}',
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receptores',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _receiverSearch,
                      decoration: InputDecoration(
                        hintText:
                            'Búsqueda instantánea (varias palabras, combina con filtros)',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        suffixIcon: _receiverSearch.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _receiverSearch.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'Filtros avanzados',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Estado',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Todos'),
                              selected: _activeFilter == ActiveTriFilter.all,
                              onSelected: (_) => setState(
                                () => _activeFilter = ActiveTriFilter.all,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Activos'),
                              selected:
                                  _activeFilter == ActiveTriFilter.activeOnly,
                              onSelected: (_) => setState(
                                () =>
                                    _activeFilter = ActiveTriFilter.activeOnly,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Inactivos'),
                              selected:
                                  _activeFilter == ActiveTriFilter.inactiveOnly,
                              onSelected: (_) => setState(
                                () => _activeFilter =
                                    ActiveTriFilter.inactiveOnly,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String?>(
                          value: _sexFilter,
                          decoration: const InputDecoration(
                            labelText: 'Sexo',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Todos')),
                            DropdownMenuItem(
                              value: 'Hombre',
                              child: Text('Hombre'),
                            ),
                            DropdownMenuItem(
                              value: 'Mujer',
                              child: Text('Mujer'),
                            ),
                            DropdownMenuItem(
                              value: 'Otro',
                              child: Text('Otro'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _sexFilter = v),
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final groups = distinctReceiverGroups(
                              _rawReceiversCache,
                            ).toList()..sort();
                            final String? effectiveGroup =
                                _groupFilter != null &&
                                    groups.contains(_groupFilter)
                                ? _groupFilter
                                : null;
                            return DropdownButtonFormField<String?>(
                              value: effectiveGroup,
                              decoration: const InputDecoration(
                                labelText: 'Grupo',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Todos'),
                                ),
                                ...groups.map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _groupFilter = v),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _activeFilter = ActiveTriFilter.all;
                                _sexFilter = null;
                                _groupFilter = null;
                                _receiverSearch.clear();
                              });
                            },
                            child: const Text('Limpiar filtros y búsqueda'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _receiversStream,
                    builder: (context, receiversSnapshot) {
                      if (receiversSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final raw = receiversSnapshot.data ?? [];
                      _rawReceiversCache = raw;

                      if (raw.isEmpty) {
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

                      final filtered = filterAndSortReceivers(
                        raw,
                        query: _receiverSearch.text,
                        activeFilter: _activeFilter,
                        sexFilter: _sexFilter,
                        groupFilter:
                            _groupFilter != null &&
                                distinctReceiverGroups(
                                  raw,
                                ).contains(_groupFilter)
                            ? _groupFilter
                            : null,
                        sort: _receiverSort,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${filtered.length} de ${raw.length} receptores · '
                            '${labelReceiverSort(_receiverSort)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: filtered.isEmpty
                                ? Center(
                                    child: Text(
                                      'Ningún receptor coincide con la búsqueda y los filtros.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final receiver = filtered[index];
                                      final String phone =
                                          receiver['phone'] ?? 'Sin número';

                                      return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.person,
                                            color: Colors.blueGrey,
                                          ),
                                          title: Text(
                                            receiver['name'] != null &&
                                                    receiver['name']
                                                        .toString()
                                                        .isNotEmpty
                                                ? receiver['name'] as String
                                                : 'Sin nombre',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text('Tel: $phone'),
                                          trailing: isTechnic
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
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
                                                                  campaignId: widget
                                                                      .campaignId,
                                                                  existingReceiver:
                                                                      receiver,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () async {
                                                        final bool confirm =
                                                            await showDialog<
                                                              bool
                                                            >(
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
                                                                        color: Colors
                                                                            .red,
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
                                                                receiver['docId']
                                                                    as String,
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
                                            debugPrint(
                                              'Clic en el receptor con teléfono: $phone',
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
