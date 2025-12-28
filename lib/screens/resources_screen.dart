import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  List<Map<String, dynamic>> _resources = [];
  bool _isLoading = true;
  bool _showForm = false;
  int? _editingId;

  // Form controllers
  final _categoryController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _languageController = TextEditingController();
  final _dataController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stateController = TextEditingController();
  final _classController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subjectsController.dispose();
    _languageController.dispose();
    _dataController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _stateController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _fetchResources() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await SupabaseService.client
          .from('resource')
          .select()
          .order('id');

      setState(() {
        _resources = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading resources: $e')),
        );
      }
    }
  }

  Future<void> _saveResource() async {
    final payload = {
      'category': _categoryController.text.isNotEmpty ? _categoryController.text : null,
      'subjects': _subjectsController.text.isNotEmpty ? _subjectsController.text : null,
      'language': _languageController.text.isNotEmpty ? _languageController.text : null,
      'data': _dataController.text.isNotEmpty ? _dataController.text : null,
      'title': _titleController.text.isNotEmpty ? _titleController.text : null,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'state': _stateController.text.isNotEmpty ? _stateController.text : null,
      'class': _classController.text.isNotEmpty ? _classController.text : null,
    };

    try {
      if (_editingId != null) {
        await SupabaseService.client
            .from('resource')
            .update(payload)
            .eq('id', _editingId!);
      } else {
        await SupabaseService.client.from('resource').insert(payload);
      }

      _resetForm();
      _fetchResources();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource saved successfully')),
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

  void _editResource(Map<String, dynamic> resource) {
    setState(() {
      _editingId = resource['id'];
      _showForm = true;
    });

    _categoryController.text = resource['category']?.toString() ?? '';
    _subjectsController.text = resource['subjects']?.toString() ?? '';
    _languageController.text = resource['language']?.toString() ?? '';
    _dataController.text = resource['data']?.toString() ?? '';
    _titleController.text = resource['title']?.toString() ?? '';
    _descriptionController.text = resource['description']?.toString() ?? '';
    _stateController.text = resource['state']?.toString() ?? '';
    _classController.text = resource['class']?.toString() ?? '';
  }

  Future<void> _deleteResource(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure you want to delete this resource?'),
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
        await SupabaseService.client.from('resource').delete().eq('id', id);
        _fetchResources();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resource deleted')),
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

  void _resetForm() {
    _categoryController.clear();
    _subjectsController.clear();
    _languageController.clear();
    _dataController.clear();
    _titleController.clear();
    _descriptionController.clear();
    _stateController.clear();
    _classController.clear();
    setState(() {
      _editingId = null;
      _showForm = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-Books & Resources',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage digital learning materials',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (!_showForm)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showForm = true;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Resource'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            if (_showForm) _buildForm(),

            // Table
            _buildTable(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _editingId != null ? 'Edit Resource' : 'Add Resource',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _resetForm,
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 4,
            ),
            children: [
              _buildTextField('Category', _categoryController),
              _buildTextField('Subjects', _subjectsController),
              _buildTextField('Language', _languageController),
              _buildTextField('Link/URL', _dataController),
              _buildTextField('Title', _titleController),
              _buildTextField('State', _stateController),
              _buildTextField('Class', _classController),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Description', _descriptionController, maxLines: 3),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saveResource,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                columns: const [
                  DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Language', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('State', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Link', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
                rows: _resources.map((resource) {
                  return DataRow(
                    cells: [
                      DataCell(Text(resource['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(resource['subjects'] ?? '')),
                      DataCell(Text(resource['class'] ?? '')),
                      DataCell(Text(resource['language'] ?? '')),
                      DataCell(Text(resource['state'] ?? '')),
                      DataCell(
                        resource['data'] != null
                            ? TextButton(
                                onPressed: () => _launchURL(resource['data']),
                                child: const Text('Open', style: TextStyle(color: Color(0xFF4F46E5))),
                              )
                            : const Text('—'),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF4F46E5)),
                            onPressed: () => _editResource(resource),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteResource(resource['id']),
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