import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../utils/list_query_utils.dart';
import 'campaign_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String organization;
  final String userName;
  final String userLastName;
  final String userRole;

  const HomeScreen({
    super.key,
    required this.organization,
    required this.userName,
    required this.userLastName,
    required this.userRole,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<Map<String, dynamic>>> _campaignsFuture;
  final TextEditingController _campaignSearch = TextEditingController();

  String? _categoryFilter;
  CampaignSortMode _campaignSort = CampaignSortMode.nameAsc;

  @override
  void initState() {
    super.initState();
    _campaignsFuture = FirestoreService().getCampaignsByOrganization(
      widget.organization,
    );
  }

  @override
  void dispose() {
    _campaignSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String fullName =
        (widget.userName.isEmpty && widget.userLastName.isEmpty)
        ? 'Usuario'
        : '${widget.userName} ${widget.userLastName}'.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<CampaignSortMode>(
            tooltip: 'Ordenar campañas',
            initialValue: _campaignSort,
            onSelected: (m) => setState(() => _campaignSort = m),
            itemBuilder: (ctx) => [
              for (final m in CampaignSortMode.values)
                PopupMenuItem(value: m, child: Text(labelCampaignSort(m))),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _campaignsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No se pudieron cargar las campañas: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final campaigns = snapshot.data ?? [];

          if (campaigns.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $fullName!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organización: ${widget.organization}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No hay campañas registradas para esta organización.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final categories = distinctCampaignCategories(campaigns).toList()
            ..sort();

          final String? effectiveCategory =
              _categoryFilter != null && categories.contains(_categoryFilter)
              ? _categoryFilter
              : null;

          final filtered = filterAndSortCampaigns(
            campaigns,
            query: _campaignSearch.text,
            categoryFilter: effectiveCategory,
            sort: _campaignSort,
          );

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $fullName!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organización: ${widget.organization}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Campañas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _campaignSearch,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, categoría, zona horaria, ID…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    suffixIcon: _campaignSearch.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _campaignSearch.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: effectiveCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todas'),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          ),
                        ],
                        onChanged: (v) => setState(() => _categoryFilter = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _categoryFilter = null;
                          _campaignSearch.clear();
                          _campaignSort = CampaignSortMode.nameAsc;
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${filtered.length} de ${campaigns.length} campañas · '
                  '${labelCampaignSort(_campaignSort)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Ninguna campaña coincide con la búsqueda y el filtro.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final c = filtered[index];
                            final String campaignId =
                                c['campaignId'] as String? ?? '';
                            final String name =
                                (c['name'] == null || c['name'] == '')
                                ? 'Campaña sin nombre'
                                : c['name'] as String;
                            final String category =
                                (c['category'] == null || c['category'] == '')
                                ? 'N/A'
                                : c['category'] as String;
                            final String tz =
                                (c['timezone'] == null || c['timezone'] == '')
                                ? '—'
                                : c['timezone'] as String;

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(
                                    Icons.campaign,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Categoría: $category · Zona: $tz',
                                ),
                                isThreeLine: false,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CampaignDetailScreen(
                                            campaignId: campaignId,
                                            userRole: widget.userRole,
                                          ),
                                    ),
                                  );
                                },
                              ),
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
