import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class CollegesScreen extends StatefulWidget {
  const CollegesScreen({super.key});

  @override
  State<CollegesScreen> createState() => _CollegesScreenState();
}

class _CollegesScreenState extends State<CollegesScreen> {
  List<Map<String, dynamic>> _colleges = [];
  bool _isLoading = true;
  bool _showForm = false;
  int? _editingId;
  
  final _searchController = TextEditingController();
  
  // Form data
  final Map<String, TextEditingController> _formControllers = {};
  
  // Filters
  String _filterState = '';
  String _filterDistrict = '';
  String _filterMedium = '';
  String _filterStream = '';
  
  // Filter options
  List<String> _states = [];
  List<String> _districts = [];
  List<String> _mediums = [];
  List<String> _streams = [];

  // College fields
  final List<String> _collegeFields = [
    'name', 'rank', 'type', 'address', 'state', 'district', 'contact', 'email',
    'stream', 'degrees', 'courses_ids', 'medium', 'eligible', 'duration',
    'admission_mode', 'fees', 'hostel', 'lab', 'lib', 'net', 'food',
    'transport', 'sports', 'disable', 'placements', 'career', 'alumini',
    'clubs', 'rating', 'cutoff', 'gender', 'website', 'college_pic',
    'latitude', 'longitude',
  ];

  final List<String> _jsonFields = [
    'contact', 'email', 'stream', 'degrees', 'courses_ids', 'cutoff'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadFilterOptions();
    _fetchColleges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _formControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (var field in _collegeFields) {
      _formControllers[field] = TextEditingController();
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      final data = await SupabaseService.client
          .from('colleges')
          .select('state, district, medium, stream');

      final states = <String>{};
      final districts = <String>{};
      final mediums = <String>{};
      final streams = <String>{};

      for (var row in data) {
        if (row['state'] != null) states.add(row['state']);
        if (row['district'] != null) districts.add(row['district']);
        if (row['medium'] != null) mediums.add(row['medium']);
        if (row['stream'] != null && row['stream'] is List) {
          streams.addAll((row['stream'] as List).cast<String>());
        }
      }

      setState(() {
        _states = states.toList()..sort();
        _districts = districts.toList()..sort();
        _mediums = mediums.toList()..sort();
        _streams = streams.toList()..sort();
      });
    } catch (e) {
      print('Error loading filter options: $e');
    }
  }

  Future<void> _fetchColleges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var query = SupabaseService.client.from('colleges').select();

      if (_filterState.isNotEmpty) {
        query = query.eq('state', _filterState);
      }
      if (_filterDistrict.isNotEmpty) {
        query = query.eq('district', _filterDistrict);
      }
      if (_filterMedium.isNotEmpty) {
        query = query.eq('medium', _filterMedium);
      }
      if (_filterStream.isNotEmpty) {
        query = query.contains('stream', [_filterStream]);
      }
      if (_searchController.text.isNotEmpty) {
        query = query.ilike('name', '%${_searchController.text}%');
      }

      final data = await query;
      setState(() {
        _colleges = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading colleges: $e')),
        );
      }
    }
  }

  Future<void> _saveCollege() async {
    final payload = <String, dynamic>{};
    
    for (var field in _collegeFields) {
      final value = _formControllers[field]!.text;
      if (_jsonFields.contains(field)) {
        // Convert comma-separated string to list
        payload[field] = value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else {
        payload[field] = value;
      }
    }

    try {
      if (_editingId != null) {
        // Update
        await SupabaseService.client
            .from('colleges')
            .update(payload)
            .eq('id', _editingId!);
      } else {
        // Insert
        await SupabaseService.client.from('colleges').insert(payload);
      }

      setState(() {
        _showForm = false;
        _editingId = null;
      });
      _clearForm();
      _fetchColleges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('College saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  void _editCollege(Map<String, dynamic> college) {
    setState(() {
      _editingId = college['id'];
      _showForm = true;
    });

    for (var field in _collegeFields) {
      final value = college[field];
      if (value is List) {
        _formControllers[field]!.text = value.join(', ');
      } else {
        _formControllers[field]!.text = value?.toString() ?? '';
      }
    }
  }

  Future<void> _deleteCollege(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete College'),
        content: const Text('Are you sure you want to delete this college?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService.client.from('colleges').delete().eq('id', id);
        _fetchColleges();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('College deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  void _clearForm() {
    for (var controller in _formControllers.values) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🎓 Colleges',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showForm = !_showForm;
                      _editingId = null;
                      _clearForm();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add College'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            if (_showForm) _buildForm(),

            // Filters
            _buildFilters(),
            const SizedBox(height: 24),

            // Table
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
            _editingId != null ? '✏️ Edit College' : '➕ Add College',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemCount: _collegeFields.length,
              itemBuilder: (context, index) {
                final field = _collegeFields[index];
                final isJson = _jsonFields.contains(field);
                return TextField(
                  controller: _formControllers[field],
                  decoration: InputDecoration(
                    labelText: field,
                    hintText: isJson ? 'comma separated' : '',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: _saveCollege,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Save'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showForm = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '🔍 Search college name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) => _fetchColleges(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterState.isEmpty ? null : _filterState,
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('All states')),
                ..._states.map((s) => DropdownMenuItem(value: s, child: Text(s))),
              ],
              onChanged: (value) {
                setState(() {
                  _filterState = value ?? '';
                });
                _fetchColleges();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterDistrict.isEmpty ? null : _filterDistrict,
              decoration: const InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('All districts')),
                ..._districts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
              ],
              onChanged: (value) {
                setState(() {
                  _filterDistrict = value ?? '';
                });
                _fetchColleges();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterMedium.isEmpty ? null : _filterMedium,
              decoration: const InputDecoration(
                labelText: 'Medium',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('All mediums')),
                ..._mediums.map((m) => DropdownMenuItem(value: m, child: Text(m))),
              ],
              onChanged: (value) {
                setState(() {
                  _filterMedium = value ?? '';
                });
                _fetchColleges();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterStream.isEmpty ? null : _filterStream,
              decoration: const InputDecoration(
                labelText: 'Stream',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('All streams')),
                ..._streams.map((s) => DropdownMenuItem(value: s, child: Text(s))),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStream = value ?? '';
                });
                _fetchColleges();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('State')),
                  DataColumn(label: Text('District')),
                  DataColumn(label: Text('Stream')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _colleges.map((college) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        college['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(college['state'] ?? '')),
                      DataCell(Text(college['district'] ?? '')),
                      DataCell(Text(
                        college['stream'] is List
                            ? (college['stream'] as List).join(', ')
                            : '',
                      )),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editCollege(college),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCollege(college['id']),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}