import 'package:flutter/material.dart';
import '../models/roadmap_model.dart';
import '../theme/app_theme.dart';

/// Static roadmap content — mirrors the 4 categories on the Home screen
/// (Robotics, AI & ML, PLC & SCADA, IoT & Sensors) so colors/icons match.
final List<CareerRoadmap> careerRoadmaps = [
  CareerRoadmap(
    id: 'robotics',
    category: 'Robotics',
    icon: Icons.precision_manufacturing_outlined,
    color: AppColors.purple,
    description:
    'From basic electronics to building autonomous robots — a step-by-step path for a Robotics Engineer.',
    steps: const [
      RoadmapStep(
        title: 'Foundation',
        course: 'Basic Electronics & Circuits',
        skill: "Ohm's law, sensors, actuators basics",
        project: 'LED blink + sensor read using Arduino',
      ),
      RoadmapStep(
        title: 'Programming',
        course: 'Python for Robotics / Embedded C',
        skill: 'Control loops, GPIO programming',
        project: 'Obstacle-avoiding robot car',
      ),
      RoadmapStep(
        title: 'Core Robotics',
        course: 'Robotics Fundamentals (kinematics, motors, ROS basics)',
        skill: 'Motor control (servo/stepper), ROS',
        project: 'Robotic arm pick-and-place simulation',
      ),
      RoadmapStep(
        title: 'Advanced',
        course: 'Computer Vision for Robotics',
        skill: 'OpenCV, object detection, path planning',
        project: 'Line-following + object-detecting autonomous bot',
      ),
      RoadmapStep(
        title: 'Specialization',
        course: 'Industrial Robotics / SCADA integration',
        skill: 'PLC basics, industrial automation standards',
        project: 'Portfolio project + GitHub showcase',
      ),
    ],
  ),
  CareerRoadmap(
    id: 'ai_ml',
    category: 'AI & ML',
    icon: Icons.smart_toy_outlined,
    color: AppColors.blue,
    description:
    'From Python basics to deep learning — a step-by-step path for an AI/ML Engineer.',
    steps: const [
      RoadmapStep(
        title: 'Foundation',
        course: 'Python Programming',
        skill: 'Data structures, NumPy, Pandas',
        project: 'Data cleaning & analysis mini-project',
      ),
      RoadmapStep(
        title: 'Math & Stats',
        course: 'Statistics & Linear Algebra for ML',
        skill: 'Probability, matrices, gradient concepts',
        project: 'Simple linear regression from scratch',
      ),
      RoadmapStep(
        title: 'Core ML',
        course: 'Machine Learning Fundamentals',
        skill: 'Scikit-learn, model training/evaluation',
        project: 'Prediction model (e.g. house price predictor)',
      ),
      RoadmapStep(
        title: 'Deep Learning',
        course: 'Neural Networks & Deep Learning',
        skill: 'TensorFlow/PyTorch, CNNs, RNNs',
        project: 'Image classifier or chatbot',
      ),
      RoadmapStep(
        title: 'Specialization',
        course: 'NLP / Computer Vision / Generative AI',
        skill: 'Transformers, LLM basics',
        project: 'Capstone AI project + deploy on portfolio',
      ),
    ],
  ),
  CareerRoadmap(
    id: 'plc_scada',
    category: 'PLC & SCADA',
    icon: Icons.memory_outlined,
    color: AppColors.cyan,
    description:
    'From relay logic to full SCADA dashboards — a step-by-step path for a PLC & SCADA Engineer.',
    steps: const [
      RoadmapStep(
        title: 'Foundation',
        course: 'Electrical & Control Systems Basics',
        skill: 'Relay logic, control panels, wiring diagrams',
        project: 'Simple relay-based control circuit',
      ),
      RoadmapStep(
        title: 'PLC Basics',
        course: 'PLC Programming (Ladder Logic)',
        skill: 'Siemens/Allen-Bradley PLC basics, I/O configuration',
        project: 'Automate a conveyor belt logic (simulation)',
      ),
      RoadmapStep(
        title: 'Advanced PLC',
        course: 'Advanced PLC & Function Block Programming',
        skill: 'Timers, counters, PID control',
        project: 'Traffic light or bottle-filling automation system',
      ),
      RoadmapStep(
        title: 'SCADA Systems',
        course: 'SCADA & HMI Design',
        skill: 'SCADA software (WinCC/Ignition), HMI screens',
        project: 'Design a SCADA dashboard for a simulated plant',
      ),
      RoadmapStep(
        title: 'Specialization',
        course: 'Industrial Automation & Safety Standards',
        skill: 'Modbus/Profibus networking, safety protocols',
        project: 'Complete factory automation mini-project',
      ),
    ],
  ),
  CareerRoadmap(
    id: 'iot',
    category: 'IoT & Sensors',
    icon: Icons.sensors_outlined,
    color: AppColors.green,
    description:
    'From microcontrollers to cloud-connected devices — a step-by-step path for an IoT Engineer.',
    steps: const [
      RoadmapStep(
        title: 'Foundation',
        course: 'Electronics + Microcontrollers (Arduino/ESP32)',
        skill: 'Circuit basics, sensors, wiring',
        project: 'Temperature/humidity monitor with display',
      ),
      RoadmapStep(
        title: 'Connectivity',
        course: 'Networking Basics for IoT',
        skill: 'Wi-Fi/Bluetooth modules, MQTT protocol',
        project: 'Sensor data sent to a mobile app via Wi-Fi',
      ),
      RoadmapStep(
        title: 'Cloud Integration',
        course: 'IoT Cloud Platforms (Firebase/AWS IoT)',
        skill: 'Cloud database, real-time data sync',
        project: 'Home automation system (app-controlled lights/fan)',
      ),
      RoadmapStep(
        title: 'Data & Automation',
        course: 'IoT Data Analytics',
        skill: 'Data visualization, automation rules/triggers',
        project: 'Smart irrigation or energy monitoring system',
      ),
      RoadmapStep(
        title: 'Specialization',
        course: 'Industrial IoT (IIoT) / Security in IoT',
        skill: 'Edge computing, device security basics',
        project: 'End-to-end IoT product + documentation',
      ),
    ],
  ),
];