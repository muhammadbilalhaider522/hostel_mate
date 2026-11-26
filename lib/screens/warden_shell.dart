import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/hostel_models.dart';
import 'role_select_screen.dart';

class WardenShell extends StatefulWidget {
  static const String routeName = '/warden-desk';

  const WardenShell({super.key});

  @override
  State<WardenShell> createState() => _WardenShellState();
}

class _WardenShellState extends State<WardenShell> {
  int _selectedIndex = 0;

  void _exitWardenMode() {
    Navigator.of(context).pushReplacementNamed(RoleSelectScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _WardenMessNoticesTab(onExit: _exitWardenMode),
      _WardenComplaintsTab(onExit: _exitWardenMode),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFCCFBF1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_calendar_outlined),
            selectedIcon: Icon(Icons.edit_calendar, color: Color(0xFF0F766E)),
            label: 'Mess & Notices',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_late_outlined),
            selectedIcon: Icon(Icons.assignment_late, color: Color(0xFF0F766E)),
            label: 'Complaints',
          ),
        ],
      ),
    );
  }
}

class _WardenMessNoticesTab extends StatefulWidget {
  final VoidCallback onExit;

  const _WardenMessNoticesTab({required this.onExit});

  @override
  State<_WardenMessNoticesTab> createState() => _WardenMessNoticesTabState();
}

class _WardenMessNoticesTabState extends State<_WardenMessNoticesTab> {
  final _breakfastCtrl = TextEditingController();
  final _lunchCtrl = TextEditingController();
  final _dinnerCtrl = TextEditingController();
  final _noticeTitleCtrl = TextEditingController();
  final _noticeBodyCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentInfo();
  }

  @override
  void dispose() {
    _breakfastCtrl.dispose();
    _lunchCtrl.dispose();
    _dinnerCtrl.dispose();
    _noticeTitleCtrl.dispose();
    _noticeBodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentInfo() async {
    final info = await DBHelper.instance.getHostelInfo();
    if (!mounted) return;
    _breakfastCtrl.text = info.breakfast;
    _lunchCtrl.text = info.lunch;
    _dinnerCtrl.text = info.dinner;
    _noticeTitleCtrl.text = info.noticeTitle;
    _noticeBodyCtrl.text = info.noticeBody;
  }

  Future<void> _saveAndPublish() async {
    setState(() => _saving = true);
    await DBHelper.instance.updateHostelInfo(
      HostelInfo(
        breakfast: _breakfastCtrl.text.trim(),
        lunch: _lunchCtrl.text.trim(),
        dinner: _dinnerCtrl.text.trim(),
        noticeTitle: _noticeTitleCtrl.text.trim(),
        noticeBody: _noticeBodyCtrl.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mess menu & notice saved! Students and AI Bot now see updates.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _wardenTopBar(title: 'Mess & Notices', onExit: widget.onExit),
          const SizedBox(height: 16),

          // Card 1: Today's Mess Menu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.restaurant, color: Color(0xFF0F766E), size: 19),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Today's Mess Menu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Breakfast', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: _breakfastCtrl, decoration: _wardenInput()),
                const SizedBox(height: 12),
                const Text('Lunch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: _lunchCtrl, decoration: _wardenInput()),
                const SizedBox(height: 12),
                const Text('Dinner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: _dinnerCtrl, decoration: _wardenInput()),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Hostel Notice Board
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.campaign_outlined, color: Color(0xFF334155), size: 19),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Hostel Notice Board',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Notice Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: _noticeTitleCtrl, decoration: _wardenInput()),
                const SizedBox(height: 12),
                const Text('Notice Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _noticeBodyCtrl,
                  maxLines: 3,
                  decoration: _wardenInput(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _saveAndPublish,
              icon: const Icon(Icons.upload, size: 19),
              label: Text(
                _saving ? 'Saving...' : 'Save & Publish',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _wardenInput() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F766E)),
      ),
    );
  }
}

class _WardenComplaintsTab extends StatefulWidget {
  final VoidCallback onExit;

  const _WardenComplaintsTab({required this.onExit});

  @override
  State<_WardenComplaintsTab> createState() => _WardenComplaintsTabState();
}

class _WardenComplaintsTabState extends State<_WardenComplaintsTab> {
  String _filter = 'All';
  List<ComplaintItem> _complaints = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await DBHelper.instance.getComplaints(filter: _filter);
    if (mounted) setState(() => _complaints = rows);
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Plumbing':
        return Icons.plumbing_outlined;
      case 'Wi-Fi':
        return Icons.wifi;
      case 'Cleaning':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.bolt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _wardenTopBar(title: 'Complaints Desk', onExit: widget.onExit),
          const SizedBox(height: 12),
          Row(
            children: ['All', 'Pending', 'Resolved'].map((tab) {
              final active = _filter == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() => _filter = tab);
                    _load();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF0F766E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          if (_complaints.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text('No complaints found.', style: TextStyle(color: Color(0xFF64748B))),
              ),
            )
          else
            ..._complaints.map((c) {
              final isResolved = c.status == 'Resolved';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            _iconForCategory(c.category),
                            color: const Color(0xFF0F766E),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Room ${c.roomNumber} • ${c.category}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isResolved
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isResolved
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      c.description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.35),
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${c.studentName} • ${c.createdAt}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isResolved)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F766E),
                              side: const BorderSide(color: Color(0xFF0F766E)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              await DBHelper.instance.updateComplaintStatus(c.id!, 'Resolved');
                              await _load();
                            },
                            child: const Text(
                              'Mark Resolved',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () async {
                                await DBHelper.instance.updateComplaintStatus(c.id!, 'Pending');
                                await _load();
                              },
                              child: const Text(
                                'Reopen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

Widget _wardenTopBar({required String title, required VoidCallback onExit}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Warden Mode',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F766E),
          ),
        ),
      ),
      const SizedBox(width: 8),
      InkWell(
        onTap: onExit,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 16, color: Color(0xFF334155)),
              SizedBox(width: 5),
              Text(
                'Exit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}