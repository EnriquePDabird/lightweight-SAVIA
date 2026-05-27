/// UIDs del array [members] de una campaña (Firestore).
List<String> parseCampaignMemberUids(dynamic members) {
  if (members is! List) return [];
  return members
      .map((e) => e?.toString().trim() ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
}

bool campaignHasMember(Map<String, dynamic> campaign, String userId) {
  final uid = userId.trim();
  if (uid.isEmpty) return false;
  return parseCampaignMemberUids(campaign['members']).contains(uid);
}
