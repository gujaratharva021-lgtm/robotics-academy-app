import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/forum_models.dart';
import '../services/forum_service.dart';
import 'post_detail_screen.dart';

/// Community feed — category chips + posts (text/image, likes, comments).
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  static const _categories = ['All', 'Robotics', 'AI & ML', 'PLC & SCADA', 'IoT & Sensors'];

  String _selectedCategory = 'All';
  List<ForumPost> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await ForumService.getPosts(category: _selectedCategory);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Forum load error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load posts. Pull down to retry.';
        _loading = false;
      });
    }
  }

  void _onCategoryTap(String cat) {
    setState(() => _selectedCategory = cat);
    _loadPosts();
  }

  Future<void> _openNewPostSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewPostSheet(),
    );
    if (created == true) _loadPosts();
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
                  Expanded(child: Text('Community', style: AppText.display(size: 17))),
                  GestureDetector(
                    onTap: _openNewPostSheet,
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
            ElevatedButton(onPressed: _loadPosts, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_posts.isEmpty) {
      return Center(child: Text('No posts yet. Be the first to share!', style: AppText.muted()));
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: _posts.length,
        itemBuilder: (context, i) => _PostCard(
          post: _posts[i],
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: _posts[i])));
            _loadPosts();
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final ForumPost post;
  final VoidCallback onTap;
  const _PostCard({required this.post, required this.onTap});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    final liked = await ForumService.isLikedByMe(widget.post.id);
    if (!mounted) return;
    setState(() => _liked = liked);
  }

  Future<void> _toggleLike() async {
    final newLiked = !_liked;
    setState(() {
      _liked = newLiked;
      _likesCount += newLiked ? 1 : -1;
    });
    await ForumService.toggleLike(widget.post.id, newLiked);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: panelDecoration(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.panelHi,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                    style: AppText.body(size: 13, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: AppText.body(size: 13, weight: FontWeight.w600)),
                      Text(post.category, style: AppText.muted(size: 11.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.text, style: AppText.body(size: 13.5), maxLines: 4, overflow: TextOverflow.ellipsis),
            if (post.imageBase64 != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(base64Decode(post.imageBase64!), height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 17,
                        color: _liked ? AppColors.red : AppColors.text1,
                      ),
                      const SizedBox(width: 5),
                      Text('$_likesCount', style: AppText.muted(size: 12.5)),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.text1),
                const SizedBox(width: 5),
                Text('${post.commentsCount}', style: AppText.muted(size: 12.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewPostSheet extends StatefulWidget {
  const _NewPostSheet();

  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  static const _categories = ['Robotics', 'AI & ML', 'PLC & SCADA', 'IoT & Sensors'];
  final _textController = TextEditingController();
  String _category = _categories.first;
  File? _pickedImage;
  bool _posting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // imageQuality + maxWidth keep the base64 string small enough for a
    // Firestore document field (1MB doc limit) — same idea as profile photos.
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1080);
    if (file != null) setState(() => _pickedImage = File(file.path));
  }

  Future<void> _submit() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _posting = true);
    String? imageBase64;
    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }
    try {
      await ForumService.createPost(
        category: _category,
        text: _textController.text.trim(),
        imageBase64: imageBase64,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Forum post error: $e');
      setState(() => _posting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not post. Try again.')));
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Post', style: AppText.display(size: 16)),
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
            Container(
              decoration: panelDecoration(radius: 14),
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                style: AppText.body(size: 13.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: "What's on your mind?",
                  hintStyle: AppText.muted(),
                ),
              ),
            ),
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
                        Text('Add Image', style: AppText.body(size: 12, weight: FontWeight.w600, color: AppColors.text1)),
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
                      : const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}