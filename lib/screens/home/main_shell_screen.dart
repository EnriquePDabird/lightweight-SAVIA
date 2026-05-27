import 'package:flutter/material.dart';

import '../../theme/savia_colors.dart';
import '../../utils/list_query_utils.dart';
import '../../widgets/savia_widgets.dart';
import '../profile/profile_screen.dart';
import 'all_receivers_tab.dart';
import 'campaigns_tab.dart';

/// Contenedor principal tras el login: pestañas Campañas / Receptores.
class MainShellScreen extends StatefulWidget {
  final String userId;
  final String organization;
  final String userName;
  final String userLastName;
  final String userRole;
  final String userEmail;

  const MainShellScreen({
    super.key,
    required this.userId,
    required this.organization,
    required this.userName,
    required this.userLastName,
    required this.userRole,
    required this.userEmail,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  SaviaNavTab _tab = SaviaNavTab.campanas;
  CampaignSortMode _campaignSort = CampaignSortMode.nameAsc;

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userName: widget.userName,
          userLastName: widget.userLastName,
          organization: widget.organization,
          email: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _tab == SaviaNavTab.campanas ? 'Campañas' : 'Receptores';

    return SaviaScaffold(
      showBack: false,
      bottomNavTab: _tab,
      onBottomNavTap: (tab) => setState(() => _tab = tab),
      appBar: SaviaAppBar(
        title: title,
        showBack: false,
        onProfileTap: _openProfile,
        actions: _tab == SaviaNavTab.campanas
            ? [
                PopupMenuButton<CampaignSortMode>(
                  tooltip: 'Ordenar campañas',
                  initialValue: _campaignSort,
                  onSelected: (m) => setState(() => _campaignSort = m),
                  itemBuilder: (ctx) => [
                    for (final m in CampaignSortMode.values)
                      PopupMenuItem(
                        value: m,
                        child: Text(labelCampaignSort(m)),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openProfile,
                      customBorder: const CircleBorder(),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: SaviaColors.surfaceElevated,
                        child: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _tab == SaviaNavTab.campanas ? 0 : 1,
        children: [
          CampaignsTab(
            userId: widget.userId,
            organization: widget.organization,
            userName: widget.userName,
            userLastName: widget.userLastName,
            userRole: widget.userRole,
            sortMode: _campaignSort,
            onSortChanged: (m) => setState(() => _campaignSort = m),
          ),
          AllReceiversTab(
            userId: widget.userId,
            userRole: widget.userRole,
          ),
        ],
      ),
    );
  }
}
