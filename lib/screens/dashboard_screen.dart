import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _department = '';
  String _role = '';
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'Admin';
    
    setState(() {
      _adminName = userName;
      // For now, set default department (you can modify based on your logic)
      _department = 'all';
      _role = 'admin';
    });
  }

  // Mock data
  final List<Map<String, dynamic>> _allUsers = [
    {'id': 1, 'name': 'John Doe', 'email': 'john@example.com', 'role': 'Student', 'department': 'engineering'},
    {'id': 2, 'name': 'Jane Smith', 'email': 'jane@example.com', 'role': 'Student', 'department': 'arts-science'},
    {'id': 3, 'name': 'Mike Johnson', 'email': 'mike@example.com', 'role': 'Teacher', 'department': 'medical'},
    {'id': 4, 'name': 'Priya Sharma', 'email': 'priya@example.com', 'role': 'Student', 'department': 'arts-science'},
    {'id': 5, 'name': 'Arun Kumar', 'email': 'arun@example.com', 'role': 'Professor', 'department': 'engineering'},
    {'id': 6, 'name': 'Fatima Ali', 'email': 'fatima@example.com', 'role': 'Student', 'department': 'medical'},
    {'id': 7, 'name': 'Rahul Mehta', 'email': 'rahul@example.com', 'role': 'Student', 'department': 'engineering'},
    {'id': 8, 'name': 'Sophia Thomas', 'email': 'sophia@example.com', 'role': 'Teacher', 'department': 'arts-science'},
  ];

  Map<String, List<Map<String, dynamic>>> get _statsByDept => {
    'arts-science': [
      {'title': 'Total Users', 'value': 350, 'icon': Icons.people, 'color': Colors.blue},
      {'title': 'Careers', 'value': 15, 'icon': Icons.article, 'color': Colors.green},
      {'title': 'Colleges', 'value': 45, 'icon': Icons.business, 'color': Colors.indigo},
      {'title': 'Scholarships', 'value': 12, 'icon': Icons.school, 'color': Colors.amber},
    ],
    'engineering': [
      {'title': 'Total Users', 'value': 500, 'icon': Icons.people, 'color': Colors.blue},
      {'title': 'Careers', 'value': 20, 'icon': Icons.article, 'color': Colors.green},
      {'title': 'Colleges', 'value': 80, 'icon': Icons.business, 'color': Colors.indigo},
      {'title': 'Scholarships', 'value': 15, 'icon': Icons.school, 'color': Colors.amber},
    ],
    'medical': [
      {'title': 'Total Users', 'value': 250, 'icon': Icons.people, 'color': Colors.blue},
      {'title': 'Careers', 'value': 10, 'icon': Icons.article, 'color': Colors.green},
      {'title': 'Colleges', 'value': 30, 'icon': Icons.business, 'color': Colors.indigo},
      {'title': 'Scholarships', 'value': 8, 'icon': Icons.school, 'color': Colors.amber},
    ],
  };

  Map<String, List<Map<String, dynamic>>> get _careerDataByDept => {
    'arts-science': [
      {'name': 'BA English', 'value': 20.0},
      {'name': 'BSc Physics', 'value': 30.0},
      {'name': 'BCom', 'value': 25.0},
      {'name': 'Others', 'value': 25.0},
    ],
    'engineering': [
      {'name': 'CSE', 'value': 35.0},
      {'name': 'ECE', 'value': 25.0},
      {'name': 'Mechanical', 'value': 20.0},
      {'name': 'Civil', 'value': 20.0},
    ],
    'medical': [
      {'name': 'MBBS', 'value': 50.0},
      {'name': 'BDS', 'value': 20.0},
      {'name': 'Nursing', 'value': 15.0},
      {'name': 'Pharmacy', 'value': 15.0},
    ],
  };

  List<Map<String, dynamic>> _getAllStats() {
    final merged = <String, Map<String, dynamic>>{};
    for (var deptStats in _statsByDept.values) {
      for (var stat in deptStats) {
        final title = stat['title'] as String;
        if (!merged.containsKey(title)) {
          merged[title] = {...stat};
        } else {
          merged[title]!['value'] = (merged[title]!['value'] as int) + (stat['value'] as int);
        }
      }
    }
    return merged.values.toList();
  }

  List<Map<String, dynamic>> _getAllCareerDistribution() {
    final merged = <String, Map<String, dynamic>>{};
    for (var deptData in _careerDataByDept.values) {
      for (var career in deptData) {
        final name = career['name'] as String;
        if (!merged.containsKey(name)) {
          merged[name] = {...career};
        } else {
          merged[name]!['value'] = (merged[name]!['value'] as double) + (career['value'] as double);
        }
      }
    }
    return merged.values.toList();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_department == 'all') return _allUsers;
    return _allUsers.where((u) => u['department'] == _department).toList();
  }

  List<Map<String, dynamic>> get _stats {
    if (_department == 'all') return _getAllStats();
    return _statsByDept[_department] ?? [];
  }

  List<Map<String, dynamic>> get _careerDistribution {
    if (_department == 'all') return _getAllCareerDistribution();
    return _careerDataByDept[_department] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              _buildGreetingSection(),
              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsCards(),
              const SizedBox(height: 24),

              // Charts Section
              _buildChartsSection(),
              const SizedBox(height: 24),

              // User Management Table
              _buildUserManagementTable(),
              const SizedBox(height: 24),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $_adminName 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _department == 'all'
                      ? 'Role: $_role (All Departments)'
                      : 'Department: ${_department.replaceAll('-', ' ')}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here are the latest statistics and updates',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Department Dropdown
          if (_role == 'ministry' || _role == 'secretary')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String>(
                value: _department,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Departments')),
                  DropdownMenuItem(value: 'arts-science', child: Text('Arts & Science')),
                  DropdownMenuItem(value: 'engineering', child: Text('Engineering')),
                  DropdownMenuItem(value: 'medical', child: Text('Medical')),
                ],
                onChanged: (value) {
                  setState(() {
                    _department = value!;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _stats.length,
      itemBuilder: (context, index) {
        final stat = _stats[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['title'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stat['value']}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                stat['icon'] as IconData,
                size: 40,
                color: stat['color'] as Color,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return Row(
      children: [
        // Line Chart - User Growth
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Growth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Feb', 'Mar', 'Apr'];
                              if (value.toInt() < months.length) {
                                return Text(months[value.toInt()]);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 50),
                            FlSpot(1, 100),
                            FlSpot(2, 150),
                            FlSpot(3, 200),
                          ],
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Pie Chart - Career Distribution
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Career Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _careerDistribution.asMap().entries.map((entry) {
                        final colors = [Colors.blue, Colors.green, Colors.amber, Colors.indigo];
                        return PieChartSectionData(
                          value: entry.value['value'] as double,
                          title: '${entry.value['value'].toInt()}',
                          color: colors[entry.key % colors.length],
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserManagementTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Users (${_department == 'all' ? 'All Departments' : _department.replaceAll('-', ' ')})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.grey[200]!, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1.5),
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: const [
                  Padding(padding: EdgeInsets.all(12), child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(12), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(12), child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(12), child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(12), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              // Data rows
              ..._filteredUsers.map((user) {
                return TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text('${user['id']}')),
                    Padding(padding: const EdgeInsets.all(12), child: Text(user['name'])),
                    Padding(padding: const EdgeInsets.all(12), child: Text(user['email'])),
                    Padding(padding: const EdgeInsets.all(12), child: Text(user['role'])),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Edit', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Delete', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
          if (_filteredUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: const Center(
        child: Text(
          '© 2025 Career Admin Panel. All rights reserved.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}