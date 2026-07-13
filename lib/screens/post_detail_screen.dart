import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/forum_models.dart';
import '../services/forum_service.dart';

class PostDetailScreen extends StatefulWidget {
  final ForumPost post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  List<ForumComment> _comments = [];
  bool _loading = true;
  bool _liked = false;
  int _likesCount = 0;
  final _commentController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _loadComments();
    _checkLiked();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    final comments = await ForumService.getComments(widget.post.id);
    if (!mounted) return;
    setState(() {
      _comments = comments;
      _loading = false;
    });
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

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await ForumService.addComment(widget.post.id, text);
    _commentController.clear();
    await _loadComments();
    if (mounted) setState(() => _sending = false);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
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
                  Text('Post', style: AppText.display(size: 17)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: panelDecoration(radius: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.panelHi,
                              child: Text(
                                post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                                style: AppText.body(size: 14, weight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.authorName, style: AppText.body(size: 13.5, weight: FontWeight.w600)),
                                Text(post.category, style: AppText.muted(size: 11.5)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(post.text, style: AppText.body(size: 14)),
                        if (post.imageBase64 != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(base64Decode(post.imageBase64!), width: double.infinity, fit: BoxFit.cover),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleLike,
                              child: Row(
                                children: [
                                  Icon(
                                    _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: 18,
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
                            Text('${_comments.length}', style: AppText.muted(size: 12.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Comments', style: AppText.body(size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (_loading)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                  else if (_comments.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('No comments yet.', style: AppText.muted()))
                  else
                    ..._comments.map((c) => _commentTile(c)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: panelDecoration(radius: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _commentController,
                        style: AppText.body(size: 13),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add a comment...',
                          hintStyle: AppText.muted(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sending ? null : _sendComment,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
                      child: _sending
                          ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentTile(ForumComment c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: panelDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.panelHi,
            child: Text(c.authorName.isNotEmpty ? c.authorName[0].toUpperCase() : '?', style: AppText.body(size: 11, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.authorName, style: AppText.body(size: 12.5, weight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(c.text, style: AppText.body(size: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}