import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ScholarshipsScreen extends StatefulWidget {
  const ScholarshipsScreen({super.key});

  @override
  State<ScholarshipsScreen> createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends State<ScholarshipsScreen> {
  List<Map<String, dynamic>> _scholarships = [];
  bool _isLoading = true;
  bool _showForm = false;
  int? _editingId;

  final _searchController = TextEditingController();

  // Form data
  final Map<String, TextEditingController> _formControllers = {};

  // Filters
  String _filterType = '';
  String _filterGender = '';
  String _filterCategory = '';

  // Scholarship fields
  final List<String> _scholarshipFields = [
    'name',
    'provider',
    'type',
    'region',
    'education_level',
    'gender',
    'category',
    'income_limit',
    'amount_benefit',
    'deadline',
    'link',
    'description',
    'eligibility_details',
    'documents_needed',
  ];

  final List<String> _arrayFields = [
    'category',
    'education_level',
    'documents_needed'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchScholarships();
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
    for (var field in _scholarshipFields) {
      _formControllers[field] = TextEditingController();
    }
  }

  Future<void> _fetchScholarships() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await SupabaseService.client
          .from('scholarships')
          .select()
          .order('id', ascending: false);

      setState(() {
        _scholarships = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading scholarships: $e')),
        );
      }
    }
  }

  Future<void> _saveScholarship() async {
    final payload = <String, dynamic>{};

    for (var field in _scholarshipFields) {
      final value = _formControllers[field]!.text;

      if (_arrayFields.contains(field)) {
        // Convert comma-separated string to list
        payload[field] = value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (field == 'income_limit') {
        // Convert to int
        payload[field] = value.isNotEmpty ? int.tryParse(value) : null;
      } else {
        payload[field] = value.isNotEmpty ? value : null;
      }
    }

    try {
      if (_editingId != null) {
        // Update
        await SupabaseService.client
            .from('scholarships')
            .update(payload)
            .eq('id', _editingId!);
      } else {
        // Insert
        await SupabaseService.client.from('scholarships').insert(payload);
      }

      setState(() {
        _showForm = false;
        _editingId = null;
      });
      _clearForm();
      _fetchScholarships();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scholarship saved successfully')),
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

  void _editScholarship(Map<String, dynamic> scholarship) {
    setState(() {
      _editingId = scholarship['id'];
      _showForm = true;
    });

    for (var field in _scholarshipFields) {
      final value = scholarship[field];
      if (value is List) {
        _formControllers[field]!.text = value.join(', ');
      } else {
        _formControllers[field]!.text = value?.toString() ?? '';
      }
    }
  }

  Future<void> _deleteScholarship(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scholarship'),
        content:
            const Text('Are you sure you want to delete this scholarship?'),
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
        await SupabaseService.client
            .from('scholarships')
            .delete()
            .eq('id', id);
        _fetchScholarships();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scholarship deleted')),
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

  List<Map<String, dynamic>> get _filteredScholarships {
    return _scholarships.where((s) {
      final searchText = _searchController.text.toLowerCase();
      final matchesSearch = s['name']?.toString().toLowerCase().contains(searchText) == true ||
          s['provider']?.toString().toLowerCase().contains(searchText) == true;

      final matchesType = _filterType.isEmpty || s['type'] == _filterType;
      final matchesGender =
          _filterGender.isEmpty || s['gender'] == _filterGender;
      final matchesCategory = _filterCategory.isEmpty ||
          (s['category'] is List &&
              (s['category'] as List).contains(_filterCategory));

      return matchesSearch && matchesType && matchesGender && matchesCategory;
    }).toList();
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
                  '🎓 Scholarships',
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
                  label: const Text('Add Scholarship'),
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

            // Search & Filters
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
            _editingId != null ? '✏️ Edit Scholarship' : '➕ Add Scholarship',
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
              itemCount: _scholarshipFields.length,
              itemBuilder: (context, index) {
                final field = _scholarshipFields[index];
                final isArray = _arrayFields.contains(field);
                return TextField(
                  controller: _formControllers[field],
                  decoration: InputDecoration(
                    labelText: field.replaceAll('_', ' '),
                    hintText: isArray ? 'comma separated' : '',
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
                onPressed: _saveScholarship,
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
                hintText: '🔍 Search scholarships...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterType.isEmpty ? null : _filterType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('All Types')),
                DropdownMenuItem(
                    value: 'Merit Based', child: Text('Merit Based')),
                DropdownMenuItem(
                    value: 'Means Based', child: Text('Means Based')),
                DropdownMenuItem(value: 'Minority', child: Text('Minority')),
                DropdownMenuItem(
                    value: 'Gender Specific', child: Text('Gender Specific')),
                DropdownMenuItem(
                    value: 'Disability', child: Text('Disability')),
              ],
              onChanged: (value) {
                setState(() {
                  _filterType = value ?? '';
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterGender.isEmpty ? null : _filterGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('All Genders')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Any', child: Text('Any')),
              ],
              onChanged: (value) {
                setState(() {
                  _filterGender = value ?? '';
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterCategory.isEmpty ? null : _filterCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('All Categories')),
                DropdownMenuItem(value: 'General', child: Text('General')),
                DropdownMenuItem(value: 'OBC', child: Text('OBC')),
                DropdownMenuItem(value: 'SC', child: Text('SC')),
                DropdownMenuItem(value: 'ST', child: Text('ST')),
                DropdownMenuItem(value: 'Minority', child: Text('Minority')),
              ],
              onChanged: (value) {
                setState(() {
                  _filterCategory = value ?? '';
                });
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
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Region')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Deadline')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _filteredScholarships.map((scholarship) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        scholarship['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(scholarship['provider'] ?? '')),
                      DataCell(Text(scholarship['region'] ?? '')),
                      DataCell(Text('₹ ${scholarship['amount_benefit'] ?? ''}')),
                      DataCell(Text(scholarship['deadline'] ?? '')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editScholarship(scholarship),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteScholarship(scholarship['id']),
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