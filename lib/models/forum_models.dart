/// A single community post — text + optional image, tied to a category.
class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String category;
  final String text;
  final String? imageBase64;
  final int likesCount;
  final int commentsCount;
  final String createdAt;

  const ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.category,
    required this.text,
    this.imageBase64,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory ForumPost.fromMap(String id, Map<String, dynamic> data) {
    return ForumPost(
      id: id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      category: data['category'] ?? 'General',
      text: data['text'] ?? '',
      imageBase64: data['imageBase64'],
      likesCount: (data['likesCount'] ?? 0) as int,
      commentsCount: (data['commentsCount'] ?? 0) as int,
      createdAt: data['createdAt'] ?? '',
    );
  }
}

/// A single comment on a post.
class ForumComment {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final String createdAt;

  const ForumComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory ForumComment.fromMap(String id, Map<String, dynamic> data) {
    return ForumComment(
      id: id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? '',
    );
  }
}