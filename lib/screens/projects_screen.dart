import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

/// Project showcase — a portfolio gallery, not a social feed.
/// Students submit what they built (optionally tied to a course) so
/// others can browse for inspiration and build a visible track record.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  static const _categories = ['All', 'Robotics', 'AI & ML', 'PLC & SCADA', 'IoT & Sensors'];

  String _selectedCategory = 'All';
  List<StudentProject> _projects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final projects = await ProjectService.getProjects(category: _selectedCategory);
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Projects load error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load projects. Pull down to retry.';
        _loading = false;
      });
    }
  }

  void _onCategoryTap(String cat) {
    setState(() => _selectedCategory = cat);
    _loadProjects();
  }

  Future<void> _openSubmitSheet() async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SubmitProjectSheet(),
    );
    if (submitted == true) _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Projects', style: AppText.display(size: 17))),
                  GestureDetector(
                    onTap: _openSubmitSheet,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final active = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategoryTap(cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? AppColors.blue.withOpacity(0.18) : AppColors.panel,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? AppColors.blue : AppColors.line),
                      ),
                      child: Text(
                        cat,
                        style: AppText.body(size: 12.5, weight: FontWeight.w600, color: active ? AppColors.text0 : AppColors.text1),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: AppText.muted()),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadProjects, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_projects.isEmpty) {
      return Center(child: Text('No projects yet. Submit the first one!', style: AppText.muted()));
    }
    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: _projects.length,
        itemBuilder: (context, i) {
          final p = _projects[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ProjectDetailScreen(project: p))),
            child: Container(
              decoration: panelDecoration(radius: 16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: p.imageBase64 != null
                        ? Image.memory(base64Decode(p.imageBase64!), width: double.infinity, fit: BoxFit.cover)
                        : Container(
                      color: AppColors.panelHi,
                      child: const Icon(Icons.memory_rounded, color: AppColors.text2, size: 30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title, style: AppText.body(size: 12.5, weight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text('by ${p.authorName}', style: AppText.muted(size: 10.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProjectDetailScreen extends StatelessWidget {
  final StudentProject project;
  const _ProjectDetailScreen({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Project', style: AppText.display(size: 17)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  if (project.imageBase64 != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(base64Decode(project.imageBase64!), width: double.infinity, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.panelHi,
                        child: Text(
                          project.authorName.isNotEmpty ? project.authorName[0].toUpperCase() : '?',
                          style: AppText.body(size: 13, weight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project.authorName, style: AppText.body(size: 13, weight: FontWeight.w600)),
                          Text(project.category, style: AppText.muted(size: 11.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(project.title, style: AppText.display(size: 18)),
                  const SizedBox(height: 8),
                  Text(project.description, style: AppText.body(size: 13.5)),
                  if (project.courseContext != null && project.courseContext!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: panelDecoration(radius: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 16, color: AppColors.blueHi),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Built after: ${project.courseContext}', style: AppText.body(size: 12.5, weight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitProjectSheet extends StatefulWidget {
  const _SubmitProjectSheet();

  @override
  State<_SubmitProjectSheet> createState() => _SubmitProjectSheetState();
}

class _SubmitProjectSheetState extends State<_SubmitProjectSheet> {
  static const _categories = ['Robotics', 'AI & ML', 'PLC & SCADA', 'IoT & Sensors'];
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _courseController = TextEditingController();
  String _category = _categories.first;
  File? _pickedImage;
  bool _posting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1080);
    if (file != null) setState(() => _pickedImage = File(file.path));
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty) return;
    setState(() => _posting = true);
    String? imageBase64;
    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }
    try {
      await ProjectService.submitProject(
        category: _category,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        courseContext: _courseController.text.trim().isEmpty ? null : _courseController.text.trim(),
        imageBase64: imageBase64,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Project submit error: $e');
      setState(() => _posting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit. Try again.')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Submit a Project', style: AppText.display(size: 16)),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final active = cat == _category;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? AppColors.blue.withOpacity(0.18) : AppColors.panel,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: active ? AppColors.blue : AppColors.line),
                        ),
                        child: Text(
                          cat,
                          style: AppText.body(size: 12, weight: FontWeight.w600, color: active ? AppColors.text0 : AppColors.text1),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              _field(_titleController, 'Project title', maxLines: 1),
              const SizedBox(height: 10),
              _field(_descController, 'What did you build? How does it work?', maxLines: 3),
              const SizedBox(height: 10),
              _field(_courseController, 'Built after which course? (optional)', maxLines: 1),
              const SizedBox(height: 12),
              if (_pickedImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_pickedImage!, height: 140, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image_outlined, size: 16, color: AppColors.text1),
                          const SizedBox(width: 6),
                          Text('Add Photo', style: AppText.body(size: 12, weight: FontWeight.w600, color: AppColors.text1)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _posting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _posting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: panelDecoration(radius: 14),
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppText.body(size: 13.5),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          hintText: hint,
          hintStyle: AppText.muted(),
        ),
      ),
    );
  }
}