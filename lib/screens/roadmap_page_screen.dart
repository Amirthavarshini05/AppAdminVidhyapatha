import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RoadmapPageScreen extends StatefulWidget {
  const RoadmapPageScreen({super.key});

  @override
  State<RoadmapPageScreen> createState() => _RoadmapPageScreenState();
}

class _RoadmapPageScreenState extends State<RoadmapPageScreen> {
  Map<String, List<RoadmapNode>> _roadmap = {
    'Beginner': [],
    'Intermediate': [],
    'Advanced': [],
  };

  RoadmapNode? _editingNode;
  String? _editingLevel;

  // New node form controllers
  final _newTitleController = TextEditingController();
  final _newShortDescController = TextEditingController();
  final _newDescController = TextEditingController();
  final _newDocController = TextEditingController();
  final _newVideoController = TextEditingController();

  // Edit node form controllers
  final _editTitleController = TextEditingController();
  final _editShortDescController = TextEditingController();
  final _editDescController = TextEditingController();
  final _editDocController = TextEditingController();
  final _editVideoController = TextEditingController();

  @override
  void dispose() {
    _newTitleController.dispose();
    _newShortDescController.dispose();
    _newDescController.dispose();
    _newDocController.dispose();
    _newVideoController.dispose();
    _editTitleController.dispose();
    _editShortDescController.dispose();
    _editDescController.dispose();
    _editDocController.dispose();
    _editVideoController.dispose();
    super.dispose();
  }

  void _addNode(String level) {
    if (_newTitleController.text.isEmpty || _newDescController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Description are required')),
      );
      return;
    }

    setState(() {
      _roadmap[level]!.add(RoadmapNode(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _newTitleController.text,
        shortDesc: _newShortDescController.text,
        desc: _newDescController.text,
        doc: _newDocController.text,
        video: _newVideoController.text,
      ));

      // Clear form
      _newTitleController.clear();
      _newShortDescController.clear();
      _newDescController.clear();
      _newDocController.clear();
      _newVideoController.clear();
    });
  }

  void _startEditNode(String level, RoadmapNode node) {
    setState(() {
      _editingNode = node;
      _editingLevel = level;
      _editTitleController.text = node.title;
      _editShortDescController.text = node.shortDesc;
      _editDescController.text = node.desc;
      _editDocController.text = node.doc;
      _editVideoController.text = node.video;
    });
  }

  void _updateNode() {
    if (_editingNode == null || _editingLevel == null) return;

    setState(() {
      final index = _roadmap[_editingLevel]!
          .indexWhere((n) => n.id == _editingNode!.id);
      if (index != -1) {
        _roadmap[_editingLevel]![index] = RoadmapNode(
          id: _editingNode!.id,
          title: _editTitleController.text,
          shortDesc: _editShortDescController.text,
          desc: _editDescController.text,
          doc: _editDocController.text,
          video: _editVideoController.text,
        );
      }
      _editingNode = null;
      _editingLevel = null;
      _editTitleController.clear();
      _editShortDescController.clear();
      _editDescController.clear();
      _editDocController.clear();
      _editVideoController.clear();
    });
  }

  void _deleteNode(String level, int id) {
    setState(() {
      _roadmap[level]!.removeWhere((n) => n.id == id);
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Career Roadmap',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Levels
              ..._roadmap.keys.map((level) => _buildLevel(level)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevel(String level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          level,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),

        // Nodes
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _roadmap[level]!
              .map((node) => _buildNodeCard(level, node))
              .toList(),
        ),

        const SizedBox(height: 16),

        // Add Node Form
        _buildAddNodeForm(level),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNodeCard(String level, RoadmapNode node) {
    final isEditing = _editingNode?.id == node.id;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isEditing ? _buildEditForm() : _buildNodeView(level, node),
    );
  }

  Widget _buildNodeView(String level, RoadmapNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          node.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
        ),
        if (node.shortDesc.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            node.shortDesc,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          node.desc,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        if (node.doc.isNotEmpty) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _launchURL(node.doc),
            child: const Text(
              'Documentation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
        if (node.video.isNotEmpty) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _launchURL(node.video),
            child: const Text(
              'Video',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _startEditNode(level, node),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Edit', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _deleteNode(level, node.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Delete', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _editTitleController,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _editShortDescController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Short Description',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _editDescController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Description',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _editDocController,
          decoration: const InputDecoration(
            hintText: 'Documentation Link',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _editVideoController,
          decoration: const InputDecoration(
            hintText: 'Video Link',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: _updateNode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Save'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _editingNode = null;
                  _editingLevel = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[500],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddNodeForm(String level) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TextField(
            controller: _newTitleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newShortDescController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Short Description',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newDescController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Description',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newDocController,
            decoration: const InputDecoration(
              hintText: 'Documentation Link',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newVideoController,
            decoration: const InputDecoration(
              hintText: 'Video Link',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _addNode(level),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Text('Add $level Step'),
          ),
        ],
      ),
    );
  }
}

class RoadmapNode {
  final int id;
  final String title;
  final String shortDesc;
  final String desc;
  final String doc;
  final String video;

  RoadmapNode({
    required this.id,
    required this.title,
    required this.shortDesc,
    required this.desc,
    required this.doc,
    required this.video,
  });
}