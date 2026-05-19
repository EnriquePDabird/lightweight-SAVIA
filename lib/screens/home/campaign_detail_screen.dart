import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../theme/savia_colors.dart';
import '../../utils/list_query_utils.dart';
import '../../widgets/receiver_summary_popup.dart';
import '../../widgets/receivers_map_view.dart';
import '../../widgets/savia_widgets.dart';
import 'receiver_form_screen.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;
  final String userRole;
  final String userOrganization;

  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
    required this.userRole,
    required this.userOrganization,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen>
    with SingleTickerProviderStateMixin {
  late final Future<Map<String, dynamic>?> _campaignFuture;
  late final Stream<List<Map<String, dynamic>>> _receiversStream;
  late final TabController _receiversTabController;
  final TextEditingController _receiverSearch = TextEditingController();

  ActiveTriFilter _activeFilter = ActiveTriFilter.all;
  String? _sexFilter;
  String? _groupFilter;
  ReceiverSortMode _receiverSort = ReceiverSortMode.nameAsc;

  /// Última lista del stream (para opciones de grupo en filtros).
  List<Map<String, dynamic>> _rawReceiversCache = [];

  final GlobalKey<ReceiversMapViewState> _mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _campaignFuture = FirestoreService().getCampaignById(widget.campaignId);
    _receiversStream = FirestoreService().getReceiversStream(widget.campaignId);
    _receiversTabController = TabController(length: 2, vsync: this);
    _receiversTabController.addListener(_onReceiversTabChanged);
  }

  void _onReceiversTabChanged() {
    if (_receiversTabController.index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapKey.currentState?.recenter();
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _receiversTabController.removeListener(_onReceiversTabChanged);
    _receiversTabController.dispose();
    _receiverSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTechnic = widget.userRole == 'technic';
    return SaviaScaffold(
      title: 'Campaña',
      appBar: SaviaAppBar(
        title: 'Campaña',
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
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: isTechnic
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiverFormScreen(
                      campaignId: widget.campaignId,
                      userOrganization: widget.userOrganization,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.person_add_outlined),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor:
                                  SaviaColors.primary.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.campaign,
                                color: SaviaColors.primary,
                              ),
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
                                    style: Theme.of(context).textTheme.bodySmall,
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
                            Text(
                              'Receptores',
                              style: Theme.of(context).textTheme.titleLarge,
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
                                    style: Theme.of(context).textTheme.bodySmall,
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
                                  () => _activeFilter =
                                      ActiveTriFilter.activeOnly,
                                ),
                              ),
                              ChoiceChip(
                                label: const Text('Inactivos'),
                                selected:
                                    _activeFilter ==
                                    ActiveTriFilter.inactiveOnly,
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
                              DropdownMenuItem(
                                value: null,
                                child: Text('Todos'),
                              ),
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
                Padding(
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
                              color: SaviaColors.textMuted,
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

                      final h = (MediaQuery.sizeOf(context).height * 0.42)
                          .clamp(280.0, 480.0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${filtered.length} de ${raw.length} receptores · '
                            '${labelReceiverSort(_receiverSort)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Material(
                            color: SaviaColors.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              side: BorderSide(color: SaviaColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: TabBar(
                              controller: _receiversTabController,
                              tabs: const [
                                Tab(icon: Icon(Icons.list), text: 'Lista'),
                                Tab(
                                  icon: Icon(Icons.map_outlined),
                                  text: 'Mapa',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Visibility(
                            visible: _receiversTabController.index == 0,
                            maintainState: true,
                            maintainAnimation: true,
                            child: filtered.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Ningún receptor coincide con la búsqueda y los filtros.',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
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
                                        leading: const Icon(Icons.person),
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                      color: SaviaColors.primary,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ReceiverFormScreen(
                                                            campaignId:
                                                                widget.campaignId,
                                                            userOrganization: widget
                                                                .userOrganization,
                                                            existingReceiver:
                                                                receiver,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: SaviaColors.error,
                                                    ),
                                                    onPressed: () async {
                                                      final bool confirm =
                                                          await showDialog<bool>(
                                                                context: context,
                                                                builder: (ctx) =>
                                                                    AlertDialog(
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
                                                                          color: SaviaColors
                                                                              .error,
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
                                                color: SaviaColors.textMuted,
                                              ),
                                        onTap: () {
                                          showReceiverEssentialPopup(
                                            context,
                                            receiver,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                          ),
                          Visibility(
                            visible: _receiversTabController.index == 1,
                            maintainState: true,
                            maintainAnimation: true,
                            child: SizedBox(
                              height: h,
                              width: double.infinity,
                              child: ReceiversMapView(
                                key: _mapKey,
                                receivers: filtered,
                              ),
                            ),
                          ),
                        ],
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
