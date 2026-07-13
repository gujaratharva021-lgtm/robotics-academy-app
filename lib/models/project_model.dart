/// A student-submitted project — showcases what they built, optionally
/// tied to the course that inspired it. Portfolio-style, no likes/comments
/// (the point is showcasing + inspiration, not social engagement).
class StudentProject {
  final String id;
  final String authorId;
  final String authorName;
  final String category;
  final String title;
  final String description;
  final String? courseContext; // e.g. "Built after: Robotics Basics"
  final String? imageBase64;
  final String createdAt;

  const StudentProject({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.category,
    required this.title,
    required this.description,
    this.courseContext,
    this.imageBase64,
    required this.createdAt,
  });

  factory StudentProject.fromMap(String id, Map<String, dynamic> data) {
    return StudentProject(
      id: id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      category: data['category'] ?? 'General',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      courseContext: data['courseContext'],
      imageBase64: data['imageBase64'],
      createdAt: data['createdAt'] ?? '',
    );
  }
}