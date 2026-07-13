import 'package:flutter/material.dart';

/// A single stage in a career roadmap — one course, one skill, one project.
class RoadmapStep {
  final String title;
  final String course;
  final String skill;
  final String project;

  const RoadmapStep({
    required this.title,
    required this.course,
    required this.skill,
    required this.project,
  });
}

/// A full career path for a category (Robotics, AI/ML, IoT, PLC & SCADA).
class CareerRoadmap {
  final String id;
  final String category;
  final IconData icon;
  final Color color;
  final String description;
  final List<RoadmapStep> steps;

  const CareerRoadmap({
    required this.id,
    required this.category,
    required this.icon,
    required this.color,
    required this.description,
    required this.steps,
  });
}