import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  final String subtitle;
  final String level;
  final String category;
  final double rating;
  final String students;
  final double progress; // 0-100
  final List<Color> gradient;
  final int modules;
  final int lessons;
  final int projects;
  final bool isPremium;

  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.category,
    required this.rating,
    required this.students,
    required this.progress,
    required this.gradient,
    required this.modules,
    required this.lessons,
    required this.projects,
    this.isPremium = false,
  });
}

class CourseCategory {
  final String name;
  final IconData icon;
  final Color color;
  const CourseCategory({required this.name, required this.icon, required this.color});
}

class Certificate {
  final String title;
  final String date;
  final Color color;
  const Certificate({required this.title, required this.date, required this.color});
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;
  const QuizQuestion({required this.question, required this.options, required this.answerIndex});
}

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}
