/// Búsqueda combinada (varias palabras = todas deben aparecer), sin acentos opcional — aquí solo minúsculas.
bool matchesCombinedQuery(String rawQuery, String haystack) {
  final h = haystack.toLowerCase();
  for (final t in rawQuery.toLowerCase().trim().split(RegExp(r'\s+'))) {
    if (t.isEmpty) continue;
    if (!h.contains(t)) return false;
  }
  return true;
}

String _txt(dynamic v) {
  if (v == null) return '';
  return v.toString().trim();
}

String receiverHaystack(Map<String, dynamic> r) {
  final parts = <String>[
    _txt(r['name']),
    _txt(r['phone']),
    _txt(r['email']),
    _txt(r['organization']),
    _txt(r['group']),
    _txt(r['sex']),
    _txt(r['country']),
    _txt(r['region']),
    _txt(r['province']),
    _txt(r['municipality']),
    _txt(r['district']),
    _txt(r['campaignId']),
  ];
  final loc = r['location'];
  if (loc is Map) {
    final m = Map<String, dynamic>.from(loc);
    parts.addAll([
      _txt(m['name']),
      _txt(m['municipality']),
      _txt(m['country']),
      _txt(m['region']),
      _txt(m['province']),
    ]);
    final coords = m['coordenadas'];
    if (coords is Map) {
      final c = Map<String, dynamic>.from(coords);
      parts.addAll([_txt(c['lat']), _txt(c['lng'])]);
    }
    final codes = m['locationCodes'];
    if (codes is Map) {
      final cd = Map<String, dynamic>.from(codes);
      for (final v in cd.values) {
        parts.add(_txt(v));
      }
    }
  }
  return parts.where((e) => e.isNotEmpty).join(' ');
}

enum ActiveTriFilter { all, activeOnly, inactiveOnly }

bool receiverPassesActive(Map<String, dynamic> r, ActiveTriFilter f) {
  switch (f) {
    case ActiveTriFilter.all:
      return true;
    case ActiveTriFilter.activeOnly:
      return r['active'] == true;
    case ActiveTriFilter.inactiveOnly:
      return r['active'] == false;
  }
}

bool receiverPassesSex(Map<String, dynamic> r, String? sex) {
  if (sex == null || sex.isEmpty) return true;
  return _txt(r['sex']).toLowerCase() == sex.toLowerCase();
}

bool receiverPassesGroup(Map<String, dynamic> r, String? group) {
  if (group == null || group.isEmpty) return true;
  return _txt(r['group']) == group;
}

int receiverOrderValue(Map<String, dynamic> r) {
  final o = r['order'];
  if (o is int) return o;
  if (o is num) return o.toInt();
  return int.tryParse(o?.toString() ?? '') ?? 0;
}

enum ReceiverSortMode {
  nameAsc,
  nameDesc,
  phoneAsc,
  orderAsc,
  orderDesc,
  groupAsc,
  emailAsc,
}

void sortReceivers(List<Map<String, dynamic>> list, ReceiverSortMode mode) {
  int cmpStr(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
  switch (mode) {
    case ReceiverSortMode.nameAsc:
      list.sort((a, b) => cmpStr(_txt(a['name']), _txt(b['name'])));
      break;
    case ReceiverSortMode.nameDesc:
      list.sort((a, b) => cmpStr(_txt(b['name']), _txt(a['name'])));
      break;
    case ReceiverSortMode.phoneAsc:
      list.sort((a, b) => cmpStr(_txt(a['phone']), _txt(b['phone'])));
      break;
    case ReceiverSortMode.orderAsc:
      list.sort(
        (a, b) => receiverOrderValue(a).compareTo(receiverOrderValue(b)),
      );
      break;
    case ReceiverSortMode.orderDesc:
      list.sort(
        (a, b) => receiverOrderValue(b).compareTo(receiverOrderValue(a)),
      );
      break;
    case ReceiverSortMode.groupAsc:
      list.sort((a, b) => cmpStr(_txt(a['group']), _txt(b['group'])));
      break;
    case ReceiverSortMode.emailAsc:
      list.sort((a, b) => cmpStr(_txt(a['email']), _txt(b['email'])));
      break;
  }
}

List<Map<String, dynamic>> filterAndSortReceivers(
  List<Map<String, dynamic>> raw, {
  required String query,
  required ActiveTriFilter activeFilter,
  String? sexFilter,
  String? groupFilter,
  required ReceiverSortMode sort,
}) {
  final list = raw.where((r) {
    if (!receiverPassesActive(r, activeFilter)) return false;
    if (!receiverPassesSex(r, sexFilter)) return false;
    if (!receiverPassesGroup(r, groupFilter)) return false;
    if (!matchesCombinedQuery(query, receiverHaystack(r))) return false;
    return true;
  }).toList();
  sortReceivers(list, sort);
  return list;
}

Set<String> distinctReceiverGroups(List<Map<String, dynamic>> raw) {
  final s = <String>{};
  for (final r in raw) {
    final g = _txt(r['group']);
    if (g.isNotEmpty) s.add(g);
  }
  return s;
}

// --- Campañas ---

String campaignHaystack(Map<String, dynamic> c) {
  return [
    _txt(c['name']),
    _txt(c['category']),
    _txt(c['organization']),
    _txt(c['timezone']),
    _txt(c['campaignId']),
  ].where((e) => e.isNotEmpty).join(' ');
}

enum CampaignSortMode { nameAsc, nameDesc, categoryAsc, timezoneAsc }

void sortCampaigns(List<Map<String, dynamic>> list, CampaignSortMode mode) {
  int cmpStr(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
  switch (mode) {
    case CampaignSortMode.nameAsc:
      list.sort((a, b) => cmpStr(_txt(a['name']), _txt(b['name'])));
      break;
    case CampaignSortMode.nameDesc:
      list.sort((a, b) => cmpStr(_txt(b['name']), _txt(a['name'])));
      break;
    case CampaignSortMode.categoryAsc:
      list.sort((a, b) => cmpStr(_txt(a['category']), _txt(b['category'])));
      break;
    case CampaignSortMode.timezoneAsc:
      list.sort((a, b) => cmpStr(_txt(a['timezone']), _txt(b['timezone'])));
      break;
  }
}

bool campaignPassesCategory(Map<String, dynamic> c, String? category) {
  if (category == null || category.isEmpty) return true;
  return _txt(c['category']) == category;
}

List<Map<String, dynamic>> filterAndSortCampaigns(
  List<Map<String, dynamic>> raw, {
  required String query,
  String? categoryFilter,
  required CampaignSortMode sort,
}) {
  final list = raw.where((c) {
    if (!campaignPassesCategory(c, categoryFilter)) return false;
    if (!matchesCombinedQuery(query, campaignHaystack(c))) return false;
    return true;
  }).toList();
  sortCampaigns(list, sort);
  return list;
}

Set<String> distinctCampaignCategories(List<Map<String, dynamic>> raw) {
  final s = <String>{};
  for (final c in raw) {
    final cat = _txt(c['category']);
    if (cat.isNotEmpty && cat != 'N/A') s.add(cat);
  }
  return s;
}

String labelReceiverSort(ReceiverSortMode m) {
  switch (m) {
    case ReceiverSortMode.nameAsc:
      return 'Nombre (A–Z)';
    case ReceiverSortMode.nameDesc:
      return 'Nombre (Z–A)';
    case ReceiverSortMode.phoneAsc:
      return 'Teléfono';
    case ReceiverSortMode.orderAsc:
      return 'Orden (menor primero)';
    case ReceiverSortMode.orderDesc:
      return 'Orden (mayor primero)';
    case ReceiverSortMode.groupAsc:
      return 'Grupo';
    case ReceiverSortMode.emailAsc:
      return 'Email';
  }
}

String labelCampaignSort(CampaignSortMode m) {
  switch (m) {
    case CampaignSortMode.nameAsc:
      return 'Nombre (A–Z)';
    case CampaignSortMode.nameDesc:
      return 'Nombre (Z–A)';
    case CampaignSortMode.categoryAsc:
      return 'Categoría';
    case CampaignSortMode.timezoneAsc:
      return 'Zona horaria';
  }
}
