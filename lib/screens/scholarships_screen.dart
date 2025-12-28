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
                    '🎓 Scholarships',
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
                              hintText: '🔍 Search scholarships...',
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
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          
                          // Type Dropdown
                          DropdownButtonFormField<String>(
                            value: _filterType.isEmpty ? null : _filterType,
                            decoration: InputDecoration(
                              labelText: 'Type',
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
                            items: const [
                              DropdownMenuItem(value: '', child: Text('All Types')),
                              DropdownMenuItem(value: 'Merit Based', child: Text('Merit Based')),
                              DropdownMenuItem(value: 'Means Based', child: Text('Means Based')),
                              DropdownMenuItem(value: 'Minority', child: Text('Minority')),
                              DropdownMenuItem(value: 'Gender Specific', child: Text('Gender Specific')),
                              DropdownMenuItem(value: 'Disability', child: Text('Disability')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filterType = value ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Gender Dropdown
                          DropdownButtonFormField<String>(
                            value: _filterGender.isEmpty ? null : _filterGender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
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
                          const SizedBox(height: 12),
                          
                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            value: _filterCategory.isEmpty ? null : _filterCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
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
                          const SizedBox(height: 24),
                          
                          // Scholarships List
                          _buildScholarshipsList(),
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
                  _editingId != null ? 'Edit Scholarship' : 'Add New Scholarship',
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
                children: _scholarshipFields.map((field) {
                  final isArray = _arrayFields.contains(field);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _formControllers[field],
                      maxLines: isArray || field == 'description' || field == 'eligibility_details' ? 3 : 1,
                      keyboardType: field == 'income_limit' ? TextInputType.number : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: field.replaceAll('_', ' ').toUpperCase(),
                        hintText: isArray ? 'Enter comma separated values' : '',
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
                    onPressed: _saveScholarship,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save Scholarship',
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

  Widget _buildScholarshipsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredScholarships.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No scholarships found',
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
            itemCount: _filteredScholarships.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final scholarship = _filteredScholarships[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  scholarship['name'] ?? 'Unnamed Scholarship',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${scholarship['provider'] ?? ''} • ₹${scholarship['amount_benefit'] ?? ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                      onPressed: () => _editScholarship(scholarship),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                      onPressed: () => _deleteScholarship(scholarship['id']),
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