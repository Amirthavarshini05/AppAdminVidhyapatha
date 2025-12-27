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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Examinations Admin',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage competitive & entrance examinations',
                      style: TextStyle(
                        fontSize: 14,
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
                    label: const Text('Add Exam'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
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
                _editingId != null ? 'Edit Examination' : 'Add Examination',
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
              _buildTextField('Exam Name', _nameController, 'Eg: Joint Entrance Examination Main'),
              _buildTextField('Short Name', _shortNameController, 'Eg: JEE Main'),
              _buildTextField('Provider', _providerController, 'Eg: NTA'),
              _buildTextField('Qualification Level', _qualLevelController, 'Eg: 12th'),
              _buildTextField('Domain', _allowedDomainsController, 'Eg: Engineering, Medical'),
              _buildTextField('Minimum Age', _minAgeController, 'Eg: 18', isNumber: true),
              _buildTextField('Maximum Age', _maxAgeController, 'Eg: 30', isNumber: true),
              _buildTextField('Website', _websiteController, 'Eg: https://jeemain.nta.nic.in'),
              _buildTextField('Exam Date', _examDateController, '', isDate: true),
              _buildTextField('Application Start', _applicationStartController, '', isDate: true),
              _buildTextField('Application End', _applicationEndController, '', isDate: true),
              _buildTextField('Fees (₹)', _feesController, 'Eg: 1000'),
              _buildTextField('Tags', _tagsController, 'Eg: Engineering, Medical, Govt'),
              _buildDifficultyDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Description', _descriptionController, 'Brief overview of the examination', maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField('Exam Pattern', _patternController, 'Eg: MCQ, duration, marking scheme', maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField('Syllabus', _syllabusController, 'Eg: Physics, Chemistry, Maths...', maxLines: 4),
          const SizedBox(height: 16),
          _buildTextField('Region', _regionController, 'Eg: Tamil Nadu'),
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
                onPressed: _saveExam,
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
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _difficulty.isEmpty ? null : _difficulty,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
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
                  DataColumn(label: Text('Exam Name', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Pattern', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Fees', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Tags', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
                rows: _exams.map((exam) {
                  return DataRow(
                    cells: [
                      DataCell(Text(exam['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(exam['pattern'] ?? '')),
                      DataCell(Text(exam['fees'] ?? '')),
                      DataCell(_buildDifficultyBadge(exam['difficulty'] ?? '')),
                      DataCell(Text(exam['tags'] is List ? (exam['tags'] as List).join(', ') : '')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF4F46E5)),
                            onPressed: () => _editExam(exam),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExam(exam['id']),
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

  Widget _buildDifficultyBadge(String difficulty) {
    Color bgColor;
    Color textColor;

    switch (difficulty) {
      case 'Hard':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        break;
      case 'Medium':
        bgColor = Colors.amber[100]!;
        textColor = Colors.amber[700]!;
        break;
      default:
        bgColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}