import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ExaminationScreen extends StatefulWidget {
  const ExaminationScreen({super.key});

  @override
  State<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen> {
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = true;
  bool _showForm = false;
  int? _editingId;

  // Form controllers
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _providerController = TextEditingController();
  final _qualLevelController = TextEditingController();
  final _allowedDomainsController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _examDateController = TextEditingController();
  final _applicationStartController = TextEditingController();
  final _applicationEndController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _patternController = TextEditingController();
  final _feesController = TextEditingController();
  final _syllabusController = TextEditingController();
  final _tagsController = TextEditingController();
  final _regionController = TextEditingController();

  String _difficulty = '';

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _providerController.dispose();
    _qualLevelController.dispose();
    _allowedDomainsController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _websiteController.dispose();
    _examDateController.dispose();
    _applicationStartController.dispose();
    _applicationEndController.dispose();
    _descriptionController.dispose();
    _patternController.dispose();
    _feesController.dispose();
    _syllabusController.dispose();
    _tagsController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _fetchExams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await SupabaseService.client
          .from('examinations')
          .select()
          .order('id');

      setState(() {
        _exams = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exams: $e')),
        );
      }
    }
  }

  Future<void> _saveExam() async {
    final currentUser = SupabaseService.getCurrentUser();
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Not authenticated! Please sign in again.')),
      );
      return;
    }

    final payload = {
      'name': _nameController.text.isNotEmpty ? _nameController.text : null,
      'short_name': _shortNameController.text.isNotEmpty ? _shortNameController.text : null,
      'provider': _providerController.text.isNotEmpty ? _providerController.text : null,
      'qual_level': _qualLevelController.text.isNotEmpty ? _qualLevelController.text : null,
      'allowed_domains': _allowedDomainsController.text.isNotEmpty
          ? _allowedDomainsController.text.split(',').map((e) => e.trim()).toList()
          : [],
      'min_age': _minAgeController.text.isNotEmpty ? int.tryParse(_minAgeController.text) : null,
      'max_age': _maxAgeController.text.isNotEmpty ? int.tryParse(_maxAgeController.text) : null,
      'website': _websiteController.text.isNotEmpty ? _websiteController.text : null,
      'exam_date': _examDateController.text.isNotEmpty ? _examDateController.text : null,
      'application_start': _applicationStartController.text.isNotEmpty ? _applicationStartController.text : null,
      'application_end': _applicationEndController.text.isNotEmpty ? _applicationEndController.text : null,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'pattern': _patternController.text.isNotEmpty ? _patternController.text : null,
      'fees': _feesController.text.isNotEmpty ? _feesController.text : null,
      'syllabus': _syllabusController.text.isNotEmpty ? _syllabusController.text : null,
      'difficulty': _difficulty.isNotEmpty ? _difficulty : null,
      'tags': _tagsController.text.isNotEmpty
          ? _tagsController.text.split(',').map((e) => e.trim()).toList()
          : [],
      'region': _regionController.text.isNotEmpty ? _regionController.text : null,
    };

    try {
      if (_editingId != null) {
        await SupabaseService.client
            .from('examinations')
            .update(payload)
            .eq('id', _editingId!);
      } else {
        await SupabaseService.client.from('examinations').insert(payload);
      }

      _resetForm();
      _fetchExams();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam saved successfully')),
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

  void _editExam(Map<String, dynamic> exam) {
    setState(() {
      _editingId = exam['id'];
      _showForm = true;
    });

    _nameController.text = exam['name']?.toString() ?? '';
    _shortNameController.text = exam['short_name']?.toString() ?? '';
    _providerController.text = exam['provider']?.toString() ?? '';
    _qualLevelController.text = exam['qual_level']?.toString() ?? '';
    _allowedDomainsController.text = exam['allowed_domains'] is List
        ? (exam['allowed_domains'] as List).join(', ')
        : '';
    _minAgeController.text = exam['min_age']?.toString() ?? '';
    _maxAgeController.text = exam['max_age']?.toString() ?? '';
    _websiteController.text = exam['website']?.toString() ?? '';
    _examDateController.text = exam['exam_date']?.toString() ?? '';
    _applicationStartController.text = exam['application_start']?.toString() ?? '';
    _applicationEndController.text = exam['application_end']?.toString() ?? '';
    _descriptionController.text = exam['description']?.toString() ?? '';
    _patternController.text = exam['pattern']?.toString() ?? '';
    _feesController.text = exam['fees']?.toString() ?? '';
    _syllabusController.text = exam['syllabus']?.toString() ?? '';
    _difficulty = exam['difficulty']?.toString() ?? '';
    _tagsController.text = exam['tags'] is List
        ? (exam['tags'] as List).join(', ')
        : '';
    _regionController.text = exam['region']?.toString() ?? '';
  }

  Future<void> _deleteExam(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Examination'),
        content: const Text('Are you sure you want to delete this examination?'),
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
        await SupabaseService.client.from('examinations').delete().eq('id', id);
        _fetchExams();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Examination deleted')),
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
    _nameController.clear();
    _shortNameController.clear();
    _providerController.clear();
    _qualLevelController.clear();
    _allowedDomainsController.clear();
    _minAgeController.clear();
    _maxAgeController.clear();
    _websiteController.clear();
    _examDateController.clear();
    _applicationStartController.clear();
    _applicationEndController.clear();
    _descriptionController.clear();
    _patternController.clear();
    _feesController.clear();
    _syllabusController.clear();
    _tagsController.clear();
    _regionController.clear();
    setState(() {
      _difficulty = '';
      _editingId = null;
      _showForm = false;
    });
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 Examinations',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage competitive exams',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_showForm) {
                          _resetForm();
                        } else {
                          _showForm = true;
                          _editingId = null;
                        }
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
                      child: _buildExamsList(),
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
                  _editingId != null ? 'Edit Examination' : 'Add New Examination',
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
                children: [
                  _buildTextField('Exam Name', _nameController, 'Eg: Joint Entrance Examination Main'),
                  const SizedBox(height: 16),
                  _buildTextField('Short Name', _shortNameController, 'Eg: JEE Main'),
                  const SizedBox(height: 16),
                  _buildTextField('Provider', _providerController, 'Eg: NTA'),
                  const SizedBox(height: 16),
                  _buildTextField('Qualification Level', _qualLevelController, 'Eg: 12th'),
                  const SizedBox(height: 16),
                  _buildTextField('Domain', _allowedDomainsController, 'Eg: Engineering, Medical (comma separated)'),
                  const SizedBox(height: 16),
                  _buildTextField('Minimum Age', _minAgeController, 'Eg: 18', isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField('Maximum Age', _maxAgeController, 'Eg: 30', isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField('Website', _websiteController, 'Eg: https://jeemain.nta.nic.in'),
                  const SizedBox(height: 16),
                  _buildTextField('Exam Date', _examDateController, 'Select date', isDate: true),
                  const SizedBox(height: 16),
                  _buildTextField('Application Start', _applicationStartController, 'Select date', isDate: true),
                  const SizedBox(height: 16),
                  _buildTextField('Application End', _applicationEndController, 'Select date', isDate: true),
                  const SizedBox(height: 16),
                  _buildTextField('Fees (₹)', _feesController, 'Eg: 1000'),
                  const SizedBox(height: 16),
                  _buildTextField('Tags', _tagsController, 'Eg: Engineering, Medical, Govt (comma separated)'),
                  const SizedBox(height: 16),
                  _buildDifficultyDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField('Description', _descriptionController, 'Brief overview of the examination', maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Exam Pattern', _patternController, 'Eg: MCQ, duration, marking scheme', maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Syllabus', _syllabusController, 'Eg: Physics, Chemistry, Maths...', maxLines: 4),
                  const SizedBox(height: 16),
                  _buildTextField('Region', _regionController, 'Eg: Tamil Nadu'),
                ],
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
                    onPressed: _saveExam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save Examination',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    bool isDate = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onTap: isDate
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    controller.text = date.toIso8601String().split('T')[0];
                  }
                }
              : null,
          readOnly: isDate,
        ),
      ],
    );
  }

  Widget _buildDifficultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _difficulty.isEmpty ? null : _difficulty,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          isExpanded: true,
          hint: const Text('Select difficulty'),
          items: const [
            DropdownMenuItem(value: 'Easy', child: Text('Easy')),
            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
            DropdownMenuItem(value: 'Hard', child: Text('Hard')),
          ],
          onChanged: (value) {
            setState(() {
              _difficulty = value ?? '';
            });
          },
        ),
      ],
    );
  }

  Widget _buildExamsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_exams.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No examinations found',
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
                  'Exam Name',
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
            itemCount: _exams.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final exam = _exams[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  exam['name'] ?? 'Unnamed Exam',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${exam['short_name'] ?? ''} • ${exam['provider'] ?? ''}',
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
                      onPressed: () => _editExam(exam),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                      onPressed: () => _deleteExam(exam['id']),
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