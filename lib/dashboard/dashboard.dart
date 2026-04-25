import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// AVAILABLE COMPANIES
  final List<Company> companies = [
    Company(name: "Umesh Logistics Pvt Ltd", type: "Transport"),
    Company(name: "SafeHome Packers & Movers", type: "Packers & Movers"),
  ];

  /// SELECTED COMPANY
  late Company selectedCompany;

  @override
  void initState() {
    super.initState();
    selectedCompany = companies.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _appBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActiveWorkspaceCard(company: selectedCompany),
            const SizedBox(height: 24),
            const QuickActionsGrid(),
            const SizedBox(height: 32),
            const RecentActivityList(),
          ],
        ),
      ),
    );
  }

  ////////////////////////
  /// APP BAR
  ////////////////////////
  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      toolbarHeight: 60,
      titleSpacing: 0,

      /// DRAWER
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),

      title: Row(
        children: const [
          Text(
            "Cargo",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Setu",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),

        /// PROFILE AVATAR
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: () {
              _showAccountSwitcher(context);
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueAccent.shade200,
              child: Text(
                selectedCompany.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        ),
      ],
    );
  }

  ////////////////////////
  /// ACCOUNT SWITCHER
  ////////////////////////
  void _showAccountSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // important for safe area + future growth
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea( // ✅ THIS FIXES OVERLAP WITH SYSTEM BUTTONS
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DRAG HANDLE (nice UX)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  "Select Company",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                /// COMPANY LIST
                ...companies.map(
                      (company) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.business),
                    title: Text(company.name),
                    trailing: company == selectedCompany
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedCompany = company;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),

                const Divider(height: 32),

                /// ADD MORE ACCOUNT
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_add),
                  title: const Text(
                    "Add another account",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to add account / login screen
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

////////////////////////
/// COMPANY MODEL
////////////////////////
class Company {
  final String name;
  final String type;
  final bool isActive;

  Company({
    required this.name,
    required this.type,
    this.isActive = true,
  });
}

////////////////////////
/// ACTIVE WORKSPACE CARD
////////////////////////
class ActiveWorkspaceCard extends StatelessWidget {
  final Company company;

  const ActiveWorkspaceCard({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: Colors.orange, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (LOGO + INFO)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                          text: company.type,
                          bg: const Color(0xFFF3F4F6),
                          color: Colors.black,
                        ),
                        const SizedBox(width: 6),
                        const _Chip(
                          text: "● Active",
                          bg: Color(0xFFE6F9EC),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ACTION BUTTONS (RESTORED ✅)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Manage Company
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Manage Company",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Open Dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Open Dashboard",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color color;

  const _Chip({
    required this.text,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

////////////////////////
/// QUICK ACTIONS GRID
////////////////////////
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          primary: false, // ✅ VERY IMPORTANT
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          padding: const EdgeInsets.only(bottom: 8), // 👈 safety padding
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, index) {
            final item = actions[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: item.color.withOpacity(0.15),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

////////////////////////
/// RECENT ACTIVITY
////////////////////////
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...activities.map(
              (a) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        a.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: a.status),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == "Paid"
        ? Colors.green
        : status == "Pending"
        ? Colors.blue
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

////////////////////////
/// DATA
////////////////////////
class DashboardAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  DashboardAction(this.title, this.subtitle, this.icon, this.color);
}

class ActivityItem {
  final String title;
  final String time;
  final String status;

  ActivityItem(this.title, this.time, this.status);
}

final actions = [
  DashboardAction("Manage Staff", "Team roles", Icons.people, Colors.blue),
  DashboardAction("Vehicles", "Fleet", Icons.local_shipping, Colors.blue),
  DashboardAction("Create Customer", "Register client", Icons.person_add, Colors.blue),
  DashboardAction("Generate Bilty", "LR note", Icons.receipt, Colors.orange),
  DashboardAction("Quotation", "Estimate costs", Icons.calculate, Colors.orange),
  DashboardAction("Invoicing", "Billing", Icons.attach_money, Colors.orange),
  DashboardAction(
    "Other Type Bills",
    "Packaging list/others",
    Icons.description,
    Colors.orange,
  ),
];


final activities = [
  ActivityItem("Bilty: BT-9902", "10 mins ago", "Generated"),
  ActivityItem("Invoice: INV-441", "2 hrs ago", "Paid"),
  ActivityItem("Quotation: QT-102", "5 hrs ago", "Pending"),
];
