import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

final List<Course> kCourses = [
  Course(
    id: 'c1',
    title: 'Robotics Basics',
    subtitle: 'Introduction to Robotics & Automation',
    level: 'Beginner',
    category: 'Robotics',
    rating: 4.8,
    students: '1.2k',
    progress: 68,
    gradient: const [Color(0xFF1C2B52), Color(0xFF0D1226)],
    modules: 12,
    lessons: 24,
    projects: 8,
  ),
  Course(
    id: 'c2',
    title: 'AI for Everyone',
    subtitle: 'Beginner friendly introduction to AI concepts',
    level: 'Beginner',
    category: 'AI & ML',
    rating: 4.8,
    students: '1.2k',
    progress: 0,
    gradient: const [Color(0xFF2A1C52), Color(0xFF0D1226)],
    modules: 10,
    lessons: 20,
    projects: 5,
  ),
  Course(
    id: 'c3',
    title: 'Machine Learning',
    subtitle: 'From basics to advanced, hands-on models',
    level: 'Intermediate',
    category: 'AI & ML',
    rating: 4.7,
    students: '980',
    progress: 0,
    gradient: const [Color(0xFF122A4A), Color(0xFF0D1226)],
    modules: 14,
    lessons: 30,
    projects: 9,
  ),
  Course(
    id: 'c4',
    title: 'PLC & SCADA Basics',
    subtitle: 'Industrial automation fundamentals',
    level: 'Intermediate',
    category: 'PLC & SCADA',
    rating: 4.6,
    students: '620',
    progress: 0,
    gradient: const [Color(0xFF123A3A), Color(0xFF0D1226)],
    modules: 9,
    lessons: 18,
    projects: 4,
  ),
  Course(
    id: 'c5',
    title: 'IoT & Smart Sensors',
    subtitle: 'Build connected sensor networks',
    level: 'Intermediate',
    category: 'IoT & Sensors',
    rating: 4.7,
    students: '810',
    progress: 0,
    gradient: const [Color(0xFF3A1C3A), Color(0xFF0D1226)],
    modules: 8,
    lessons: 16,
    projects: 6,
  ),
  Course(
    id: 'c6',
    title: '3D Printing Fundamentals',
    subtitle: 'Design & print your own robot parts',
    level: 'Beginner',
    category: '3D Printing',
    rating: 4.5,
    students: '540',
    progress: 0,
    gradient: const [Color(0xFF3A2A12), Color(0xFF0D1226)],
    modules: 7,
    lessons: 14,
    projects: 3,
  ),
];

final List<CourseCategory> kCategories = [
  const CourseCategory(name: 'Robotics', icon: Icons.precision_manufacturing_outlined, color: AppColors.purple),
  const CourseCategory(name: 'AI & ML', icon: Icons.smart_toy_outlined, color: AppColors.blue),
  const CourseCategory(name: 'PLC & SCADA', icon: Icons.memory_outlined, color: AppColors.cyan),
  const CourseCategory(name: 'IoT & Sensors', icon: Icons.sensors_outlined, color: AppColors.green),
];

final List<Certificate> kCertificates = [
  const Certificate(title: 'Robotics Basics', date: '20 May 2024', color: AppColors.purple),
  const Certificate(title: 'AI for Everyone', date: '10 May 2024', color: AppColors.blue),
  const Certificate(title: 'PLC & SCADA Basics', date: '05 May 2024', color: AppColors.cyan),
];

final List<QuizQuestion> kQuiz = [
  const QuizQuestion(
    question: 'What does "IoT" stand for?',
    options: ['Internet of Things', 'Input Output Terminal', 'Integrated Output Tech', 'Internet Operating Tool'],
    answerIndex: 0,
  ),
  const QuizQuestion(
    question: 'Which sensor is commonly used to detect obstacles in a line-follower robot?',
    options: ['Gyroscope', 'IR Sensor', 'Barometer', 'Microphone'],
    answerIndex: 1,
  ),
  const QuizQuestion(
    question: 'In robotics, what does a PLC primarily control?',
    options: ['Web servers', 'Industrial machinery & processes', 'Mobile apps', 'Video rendering'],
    answerIndex: 1,
  ),
  const QuizQuestion(
    question: 'Which of these is a Python library used for Machine Learning?',
    options: ['React', 'TensorFlow', 'Bootstrap', 'Figma'],
    answerIndex: 1,
  ),
];
