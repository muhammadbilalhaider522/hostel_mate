import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/db_helper.dart';
import '../models/hostel_models.dart';
import '../services/ai_chat_service.dart';
import 'role_select_screen.dart';

class StudentShell extends StatefulWidget {
  static const String routeName = '/student-home';
  final StudentUser? student;

  const StudentShell({super.key, this.student});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _selectedIndex = 0;

  late final StudentUser _activeStudent = widget.student ??
      StudentUser(
        fullName: 'Bilal',
        roomNumber: 'B-204',
        phone: '0300-1234567',
        email: 'bilal@greenview.pk',
        password: '123',
      );

  @override
  Widget build(BuildContext context) {
    final firstName = _activeStudent.fullName.trim().split(' ').first;

    final pages = [
      _DashboardTab(
        firstName: firstName,
        roomNumber: _activeStudent.roomNumber,
        onSwitchTab: (idx) => setState(() => _selectedIndex = idx),
        onLogout: () => Navigator.of(context)
            .pushReplacementNamed(RoleSelectScreen.routeName),
      ),
      _AIChatTab(studentName: firstName),
      _ComplaintsTab(
        defaultName: _activeStudent.fullName,
        defaultRoom: _activeStudent.roomNumber,
      ),
      const _RulesTab(),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF0F766E)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF0F766E)),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_late_outlined),
            selectedIcon: Icon(Icons.assignment_late, color: Color(0xFF0F766E)),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel, color: Color(0xFF0F766E)),
            label: 'Rules',
          ),
        ],
      ),
    );
  }
}

// --- TAB 1: STUDENT HOME DASHBOARD ---
class _DashboardTab extends StatefulWidget {
  final String firstName;
  final String roomNumber;
  final ValueChanged<int> onSwitchTab;
  final VoidCallback onLogout;

  const _DashboardTab({
    required this.firstName,
    required this.roomNumber,
    required this.onSwitchTab,
    required this.onLogout,
  });

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  HostelInfo? _info;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final data = await DBHelper.instance.getHostelInfo();
    if (mounted) setState(() => _info = data);
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('EEEE').format(DateTime.now());
    final info = _info ??
        HostelInfo(
          breakfast: 'Paratha & Omelette • 7:30–9:00 AM',
          lunch: 'Daal Chawal • 1:00–2:30 PM',
          dinner: 'Chicken Karahi • 8:00–9:30 PM',
          noticeTitle: 'Water Tank Cleaning',
          noticeBody:
          'Supply will be paused on Saturday from 10:00 AM to 12:00 PM for overhead tank maintenance.',
        );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadInfo,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GREENVIEW STUDENT RESIDENCY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assalam-o-Alaikum, ${widget.firstName}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 13, color: Color(0xFF0F766E)),
                              SizedBox(width: 4),
                              Text(
                                'Gate: 10:30 PM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Room ${widget.roomNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: widget.onLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.logout, size: 18, color: Color(0xFF0F766E)),
                        SizedBox(height: 2),
                        Text(
                          'Exit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mess Menu Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Today's Mess Menu",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF99F6E4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dayLabel,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _mealLine('Breakfast', info.breakfast),
                  const Divider(color: Colors.white24, height: 18),
                  _mealLine('Lunch', info.lunch),
                  const Divider(color: Colors.white24, height: 18),
                  _mealLine('Dinner', info.dinner),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2x2 Quick Action Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _actionTile(
                  iconBg: const Color(0xFFCCFBF1),
                  icon: Icons.auto_awesome,
                  iconColor: const Color(0xFF0F766E),
                  title: 'Ask AI Bot',
                  subtitle: 'English & Roman Urdu',
                  onTap: () => widget.onSwitchTab(1),
                ),
                _actionTile(
                  iconBg: const Color(0xFFFEF3C7),
                  icon: Icons.build_outlined,
                  iconColor: const Color(0xFFB45309),
                  title: 'Log Complaint',
                  subtitle: 'Room & Wi-Fi issues',
                  onTap: () => widget.onSwitchTab(2),
                ),
                _actionTile(
                  iconBg: const Color(0xFFDCFCE7),
                  icon: Icons.payments_outlined,
                  iconColor: const Color(0xFF15803D),
                  title: 'Rent & Fee',
                  subtitle: 'Due 5th of month',
                  onTap: () => widget.onSwitchTab(3),
                ),
                _actionTile(
                  iconBg: const Color(0xFFF1F5F9),
                  icon: Icons.local_laundry_service_outlined,
                  iconColor: const Color(0xFF334155),
                  title: 'Laundry',
                  subtitle: 'Tue & Fri • 9:00 AM',
                  onTap: () => widget.onSwitchTab(3),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notice Board Card
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.campaign_outlined, color: Color(0xFF0F766E), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Notice Board',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '1 Active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    info.noticeTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.noticeBody,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealLine(String title, String detail) {
    final parts = detail.split('•');
    final dish = parts.first.trim();
    final timing = parts.length > 1 ? parts.sublist(1).join('•').trim() : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            if (timing.isNotEmpty)
              Text(
                timing,
                style: const TextStyle(color: Color(0xFFCCFBF1), fontSize: 12),
              ),
          ],
        ),
        Flexible(
          child: Text(
            dish,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TAB 2: AI HOSTEL ASSISTANT ---
class _AIChatTab extends StatefulWidget {
  final String studentName;

  const _AIChatTab({required this.studentName});

  @override
  State<_AIChatTab> createState() => _AIChatTabState();
}

class _AIChatTabState extends State<_AIChatTab> {
  final TextEditingController _msgCtrl = TextEditingController();
  bool _sending = false;

  late final List _messages = [
  {
  'sender': 'bot',
  'text':
  "Assalam-o-Alaikum, ${widget.studentName}! I'm your GreenView Hostel assistant. Ask me about mess timings, rent due dates, laundry, or room complaints in English or Roman Urdu.",
  'time': '9:14 AM',
  },
  {
  'sender': 'user',
  'text': 'Aaj dinner mein kya ha aur rent ki last date kya ha?',
  'time': '9:15 AM',
  },
  {
  'sender': 'bot',
  'text':
  'Aaj dinner mein Chicken Karahi hai (8:00–9:30 PM).\n\nMonthly rent ki due date 5th of every month hai. 10th ke baad PKR 200/day late fine lagta hai.',
  'time': '9:15 AM',
  },
  ];

  final List<String> _chips = [
    'Mess Timings',
    'Monthly Rent',
    'Laundry Days',
    'Gate Timing',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _msgCtrl.text).trim();
    if (text.isEmpty || _sending) return;

    final nowStr = DateFormat('h:mm a').format(DateTime.now());
    setState(() {
      _messages.add({'sender': 'user', 'text': text, 'time': nowStr});
      _sending = true;
      if (preset == null) _msgCtrl.clear();
    });

    final reply = await AIChatService.getReply(
      prompt: text,
      studentName: widget.studentName,
    );
    if (!mounted) return;
    setState(() {
      _messages.add({
        'sender': 'bot',
        'text': reply,
        'time': DateFormat('h:mm a').format(DateTime.now()),
      });
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF0F766E), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HostelMate AI',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFF16A34A)),
                          SizedBox(width: 5),
                          Text(
                            'Online • English & Roman Urdu',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'GreenView',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final item = _messages[idx];
                final isUser = item['sender'] == 'user';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.auto_awesome, size: 15, color: Color(0xFF0F766E)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF0F766E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isUser
                                ? null
                                : Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['text']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: isUser ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  item['time']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isUser ? Colors.white70 : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'HostelMate AI is replying...',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => InkWell(
                onTap: () => _sendMessage(_chips[i]),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    _chips[i],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask anything about hostel...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF0F766E)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF0F766E),
                  child: IconButton(
                    icon: const Icon(Icons.send_outlined, color: Colors.white, size: 19),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- TAB 3: COMPLAINTS & STATUS TRACKER ---
class _ComplaintsTab extends StatefulWidget {
  final String defaultName;
  final String defaultRoom;

  const _ComplaintsTab({
    required this.defaultName,
    required this.defaultRoom,
  });

  @override
  State<_ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<_ComplaintsTab> {
  late final TextEditingController _nameCtrl = TextEditingController(text: widget.defaultName);
  late final TextEditingController _roomCtrl = TextEditingController(text: widget.defaultRoom);
  final TextEditingController _descCtrl = TextEditingController();

  String _filter = 'All';
  String _category = 'Electrical';
  List<ComplaintItem> _items = [];

  final List<String> _categories = ['Electrical', 'Plumbing', 'Wi-Fi', 'Cleaning'];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    final list = await DBHelper.instance.getComplaints(filter: _filter);
    if (mounted) setState(() => _items = list);
  }

  Future<void> _submitComplaint() async {
    final name = _nameCtrl.text.trim();
    final room = _roomCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (name.isEmpty || room.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill Student Name, Room Number, and Issue Description.')),
      );
      return;
    }

    await DBHelper.instance.insertComplaint(
      ComplaintItem(
        studentName: name,
        roomNumber: room,
        category: _category,
        description: desc,
        status: 'Pending',
        createdAt: 'Today, ${DateFormat('h:mm a').format(DateTime.now())}',
      ),
    );
    _descCtrl.clear();
    await _loadComplaints();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted and routed to Warden Desk.')),
    );
  }

  IconData _categoryIcon(String cat) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Room Complaints',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Staff & Student',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['All', 'Pending', 'Resolved'].map((tab) {
              final active = _filter == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() => _filter = tab);
                    _loadComplaints();
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

          // New Complaint Form Card
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Complaint',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Auto-routed to Warden',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Student Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameCtrl,
                            decoration: _fieldDeco('Bilal Ahmed'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Room Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _roomCtrl,
                            decoration: _fieldDeco('B-204'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final selected = _category == cat;
                    return InkWell(
                      onTap: () => setState(() => _category = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFCCFBF1) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _categoryIcon(cat),
                              size: 14,
                              color: selected ? const Color(0xFF0F766E) : const Color(0xFF475569),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? const Color(0xFF0F766E) : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Issue Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: _fieldDeco('Describe the issue briefly...'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitComplaint,
                    child: const Text('Submit Complaint', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Recent Tickets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text('No tickets in this filter.', style: TextStyle(color: Color(0xFF64748B))),
              ),
            )
          else
            ..._items.map((item) {
              final isResolved = item.status == 'Resolved';
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
                            _categoryIcon(item.category),
                            color: const Color(0xFF0F766E),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room ${item.roomNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                item.category,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
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
                            item.status,
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
                      item.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.createdAt,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final nextStatus = isResolved ? 'Pending' : 'Resolved';
                            await DBHelper.instance.updateComplaintStatus(item.id!, nextStatus);
                            await _loadComplaints();
                          },
                          icon: const Icon(Icons.sync, size: 14),
                          label: const Text('Toggle Status', style: TextStyle(fontSize: 12)),
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

  InputDecoration _fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

// --- TAB 4: HOSTEL RULES, FEE & WARDEN CONTACT ---
class _RulesTab extends StatelessWidget {
  const _RulesTab();

  Future<void> callWardenPhone(
      BuildContext context, {
        String phoneNumber = '+923064713642',
      }) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      final bool opened = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer. Call: $phoneNumber')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer. Call: $phoneNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          const Text(
            'GREENVIEW STUDENT RESIDENCY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Hostel Rules & Info',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),

          // Card 1: Monthly Rent & Fee
          _infoCard(
            iconBg: const Color(0xFFCCFBF1),
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFF0F766E),
            title: 'Monthly Rent & Fee',
            rows: [
              _kvRow('2-Seater Room', 'PKR 18,000', valueColor: const Color(0xFF0F172A)),
              _kvRow('3-Seater Room', 'PKR 15,000', valueColor: const Color(0xFF0F172A)),
              _kvRow('Due Date', '5th of every month', valueColor: const Color(0xFF0F766E)),
              _kvRow('Late Fine', 'PKR 200/day after 10th', valueColor: const Color(0xFFB45309)),
            ],
          ),
          const SizedBox(height: 14),

          // Card 2: Hostel Policies
          _infoCard(
            iconBg: const Color(0xFFF1F5F9),
            icon: Icons.verified_user_outlined,
            iconColor: const Color(0xFF334155),
            title: 'Hostel Policies',
            rows: [
              _policyRow(Icons.door_front_door_outlined, 'Gate Closes', '10:30 PM'),
              _policyRow(Icons.local_laundry_service_outlined, 'Laundry Pickup', 'Tue & Fri, 9:00 AM'),
              _policyRow(Icons.nightlight_outlined, 'Quiet Hours', '11:00 PM – 6:00 AM'),
              _policyRow(Icons.groups_outlined, 'Visitors', 'Lobby till 8:00 PM'),
            ],
          ),
          const SizedBox(height: 14),

          // Card 3: Warden Contact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.support_agent, color: Color(0xFF0F766E)),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hostel Warden',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          'Mr. Tariq Mehmood',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '+92-300-1234567',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'GreenView Student Residency, Plot 14-B,\nGreenView Avenue, Sector G-11/3, Islamabad',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => callWardenPhone(context, phoneNumber: '+923064713642'),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call Warden', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _kvRow(String label, String value, {required Color valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _policyRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}