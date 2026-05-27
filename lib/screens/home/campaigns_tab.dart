import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/savia_colors.dart';
import '../../utils/list_query_utils.dart';
import 'campaign_detail_screen.dart';

/// Campañas en las que el usuario es miembro ([members] en Firestore).
class CampaignsTab extends StatefulWidget {
  final String userId;
  final String organization;
  final String userName;
  final String userLastName;
  final String userRole;
  final CampaignSortMode sortMode;
  final ValueChanged<CampaignSortMode>? onSortChanged;

  const CampaignsTab({
    super.key,
    required this.userId,
    required this.organization,
    required this.userName,
    required this.userLastName,
    required this.userRole,
    required this.sortMode,
    this.onSortChanged,
  });

  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> {
  late Future<List<Map<String, dynamic>>> _campaignsFuture;
  final TextEditingController _search = TextEditingController();
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CampaignsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sortMode != widget.sortMode) {
      setState(() {});
    }
  }

  void _load() {
    _campaignsFuture = FirestoreService().getCampaignsForMember(widget.userId);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _campaignsFuture;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = (widget.userName.isEmpty && widget.userLastName.isEmpty)
        ? 'Usuario'
        : '${widget.userName} ${widget.userLastName}'.trim();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _campaignsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudieron cargar las campañas: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final campaigns = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _refresh,
          color: SaviaColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '¡Hola, $fullName!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: SaviaColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.organization,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SaviaColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              Text('Campañas', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (campaigns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    'No perteneces a ninguna campaña todavía.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                )
              else ...[
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, categoría, zona horaria, ID…',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _search.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                _buildFilters(context, campaigns),
                const SizedBox(height: 8),
                ..._buildCampaignList(context, campaigns),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(
    BuildContext context,
    List<Map<String, dynamic>> campaigns,
  ) {
    final categories = distinctCampaignCategories(campaigns).toList()..sort();
    final effectiveCategory =
        _categoryFilter != null && categories.contains(_categoryFilter)
            ? _categoryFilter
            : null;

    final filtered = filterAndSortCampaigns(
      campaigns,
      query: _search.text,
      categoryFilter: effectiveCategory,
      sort: widget.sortMode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: effectiveCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
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
                  _search.clear();
                  widget.onSortChanged?.call(CampaignSortMode.nameAsc);
                });
              },
              child: const Text('Limpiar'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${filtered.length} de ${campaigns.length} campañas · '
          '${labelCampaignSort(widget.sortMode)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  List<Widget> _buildCampaignList(
    BuildContext context,
    List<Map<String, dynamic>> campaigns,
  ) {
    final categories = distinctCampaignCategories(campaigns).toList()..sort();
    final effectiveCategory =
        _categoryFilter != null && categories.contains(_categoryFilter)
            ? _categoryFilter
            : null;

    final filtered = filterAndSortCampaigns(
      campaigns,
      query: _search.text,
      categoryFilter: effectiveCategory,
      sort: widget.sortMode,
    );

    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Ninguna campaña coincide con la búsqueda y el filtro.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    return filtered.map((c) {
      final campaignId = c['campaignId'] as String? ?? '';
      final name = (c['name'] == null || c['name'] == '')
          ? 'Campaña sin nombre'
          : c['name'] as String;
      final category =
          (c['category'] == null || c['category'] == '') ? 'N/A' : c['category'] as String;
      final tz = (c['timezone'] == null || c['timezone'] == '')
          ? '—'
          : c['timezone'] as String;

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: SaviaColors.primary.withValues(alpha: 0.2),
              child: const Icon(Icons.campaign, color: SaviaColors.primary),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: SaviaColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Categoría: $category · Zona: $tz',
              style: const TextStyle(color: SaviaColors.textSecondary),
            ),
            trailing: const Icon(Icons.chevron_right, color: SaviaColors.textMuted),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CampaignDetailScreen(
                    campaignId: campaignId,
                    userId: widget.userId,
                    userRole: widget.userRole,
                    userOrganization: widget.organization,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }
}
