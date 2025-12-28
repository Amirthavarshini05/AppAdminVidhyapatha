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
      body: SafeArea(
        child: Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎓 Colleges',
                    style: TextStyle(
                      fontSize: 24,
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
                    icon: Icon(_showForm ? Icons.close : Icons.add),
                    label: Text(_showForm ? 'Cancel' : 'Add'),
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
            ),

            // Content
            Expanded(
              child: _showForm
                  ? _buildForm()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Search Box (Full Width)
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '🔍 Search college name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) => _fetchColleges(),
                          ),
                          const SizedBox(height: 16),
                          
                          // State Dropdown
                          DropdownButtonFormField<String>(
                            value: _filterState.isEmpty ? null : _filterState,
                            decoration: InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            isExpanded: true,
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
                          const SizedBox(height: 12),
                          
                          // District Dropdown
                          DropdownButtonFormField<String>(
                            value: _filterDistrict.isEmpty ? null : _filterDistrict,
                            decoration: InputDecoration(
                              labelText: 'District',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            isExpanded: true,
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
                          const SizedBox(height: 12),
                          
                          // Medium Dropdown
                          DropdownButtonFormField<String>(
                            value: _filterMedium.isEmpty ? null : _filterMedium,
                            decoration: InputDecoration(
                              labelText: 'Medium',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            isExpanded: true,
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
                          const SizedBox(height: 12),
                          
                          // Stream Dropdown
                          DropdownButtonFormField<String>(
                            value: _filterStream.isEmpty ? null : _filterStream,
                            decoration: InputDecoration(
                              labelText: 'Stream',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            isExpanded: true,
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
                          const SizedBox(height: 24),
                          
                          // College List
                          _buildCollegeList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Form Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _editingId != null ? Icons.edit : Icons.add_circle,
                  color: const Color(0xFF4F46E5),
                ),
                const SizedBox(width: 8),
                Text(
                  _editingId != null ? 'Edit College' : 'Add New College',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Form Fields (Scrollable) - SINGLE COLUMN
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _collegeFields.map((field) {
                  final isJson = _jsonFields.contains(field);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _formControllers[field],
                      maxLines: isJson ? 3 : 1,
                      decoration: InputDecoration(
                        labelText: field.replaceAll('_', ' ').toUpperCase(),
                        hintText: isJson ? 'Enter comma separated values' : '',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Save/Cancel Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveCollege,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save College',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showForm = false;
                        _clearForm();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_colleges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No colleges found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _colleges.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final college = _colleges[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  college['name'] ?? 'Unnamed College',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                      onPressed: () => _editCollege(college),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                      onPressed: () => _deleteCollege(college['id']),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}