import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/savia_colors.dart';
import '../../utils/list_query_utils.dart';
import '../../widgets/receiver_summary_popup.dart';

/// Receptores de las campañas en las que el usuario es miembro.
class AllReceiversTab extends StatefulWidget {
  final String userId;
  final String userRole;

  const AllReceiversTab({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<AllReceiversTab> createState() => _AllReceiversTabState();
}

class _AllReceiversTabState extends State<AllReceiversTab> {
  late Future<_ReceiversBundle> _dataFuture;
  final TextEditingController _search = TextEditingController();
  ReceiverSortMode _sort = ReceiverSortMode.nameAsc;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _dataFuture = _fetch();
  }

  Future<_ReceiversBundle> _fetch() async {
    final fs = FirestoreService();
    final campaigns = await fs.getCampaignsForMember(widget.userId);
    final ids = campaigns
        .map((c) => c['campaignId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    final receivers = await fs.getReceiversForCampaigns(ids);
    final names = <String, String>{
      for (final c in campaigns)
        if ((c['campaignId'] as String?)?.isNotEmpty ?? false)
          c['campaignId'] as String: (c['name']?.toString().isNotEmpty ?? false)
              ? c['name'] as String
              : 'Campaña sin nombre',
    };
    return _ReceiversBundle(receivers: receivers, campaignNames: names);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _dataFuture;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ReceiversBundle>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudieron cargar los receptores: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final bundle = snapshot.data!;
        final raw = bundle.receivers;

        final filtered = filterAndSortReceivers(
          raw,
          query: _search.text,
          activeFilter: ActiveTriFilter.all,
          sort: _sort,
        );

        return RefreshIndicator(
          onRefresh: _refresh,
          color: SaviaColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Receptores', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Receptores de tus campañas asignadas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (raw.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    'No hay receptores en tus campañas asignadas.',
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
                    hintText: 'Buscar receptor…',
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
                Text(
                  '${filtered.length} de ${raw.length} receptores · '
                  '${labelReceiverSort(_sort)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Ningún receptor coincide con la búsqueda.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...filtered.map((r) {
                    final phone = r['phone']?.toString() ?? 'Sin número';
                    final name = r['name']?.toString().trim();
                    final campaignId = r['campaignId']?.toString() ?? '';
                    final campaignName =
                        bundle.campaignNames[campaignId] ?? campaignId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.person, color: SaviaColors.textMuted),
                          title: Text(
                            (name != null && name.isNotEmpty) ? name : 'Sin nombre',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: SaviaColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Tel: $phone · $campaignName',
                            style: const TextStyle(color: SaviaColors.textSecondary),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: SaviaColors.textMuted,
                          ),
                          onTap: () => showReceiverEssentialPopup(context, r),
                        ),
                      ),
                    );
                  }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReceiversBundle {
  final List<Map<String, dynamic>> receivers;
  final Map<String, String> campaignNames;

  _ReceiversBundle({required this.receivers, required this.campaignNames});
}
