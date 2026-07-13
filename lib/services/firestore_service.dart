import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'auth_service.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- COURSES ----------
  static Future<List<Course>> getCourses() async {
    final snapshot = await _db.collection('courses').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Course(
        id: doc.id,
        title: data['title'] ?? '',
        subtitle: data['subtitle'] ?? '',
        level: data['level'] ?? '',
        category: data['category'] ?? '',
        rating: num.parse(data['rating'].toString()).toDouble(),
        students: data['students'] ?? '',
        progress: num.parse((data['progress'] ?? 0).toString()).toDouble(),
        gradient: [
          Color(int.parse(data['gradientStart'] ?? 'FF1C2B52', radix: 16)),
          Color(int.parse(data['gradientEnd'] ?? 'FF0D1226', radix: 16)),
        ],
        modules: num.parse((data['modules'] ?? 0).toString()).toInt(),
        lessons: num.parse((data['lessons'] ?? 0).toString()).toInt(),
        projects: num.parse((data['projects'] ?? 0).toString()).toInt(),
        isPremium: data['isPremium'] ?? false,
      );
    }).toList();
  }

  static Future<void> seedCourses(List<Map<String, dynamic>> courses) async {
    for (final c in courses) {
      await _db.collection('courses').doc(c['id']).set(c);
    }
  }

  // ---------- QUIZ (per-course, stored under courses/{courseId}/quiz) ----------
  static Future<List<QuizQuestion>> getQuiz(String courseId) async {
    final snapshot = await _db.collection('courses').doc(courseId).collection('quiz').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return QuizQuestion(
        question: data['question'] ?? '',
        options: List<String>.from(data['options'] ?? []),
        answerIndex: data['answerIndex'] ?? 0,
      );
    }).toList();
  }

  static Future<void> seedCourseQuiz(String courseId, List<Map<String, dynamic>> quiz) async {
    for (int i = 0; i < quiz.length; i++) {
      await _db.collection('courses').doc(courseId).collection('quiz').doc('q${i + 1}').set(quiz[i]);
    }
  }

  static Future<void> seedAllCourseQuizzes() async {
    final Map<String, List<Map<String, dynamic>>> allQuizzes = {
      'c1': [
        {'question': 'What is a servo motor primarily used for?', 'options': ['Generating electricity', 'Precise position control', 'Storing data', 'Measuring temperature'], 'answerIndex': 1},
        {'question': 'Which sensor is commonly used to measure distance in robots?', 'options': ['Microphone', 'Barometer', 'Ultrasonic sensor', 'Photoresistor'], 'answerIndex': 2},
        {'question': "What does 'DOF' stand for in robotics?", 'options': ['Direction of Flow', 'Data Output Format', 'Drive Operation Frequency', 'Degrees of Freedom'], 'answerIndex': 3},
        {'question': "Which component usually acts as the 'brain' of a simple robot?", 'options': ['Battery', 'Microcontroller', 'Wheel', 'Chassis'], 'answerIndex': 1},
      ],
      'c2': [
        {'question': 'What does AI stand for?', 'options': ['Automated Interface', 'Analog Input', 'Artificial Intelligence', 'Applied Informatics'], 'answerIndex': 2},
        {'question': 'Which of these is a common example of AI in daily life?', 'options': ['A regular calculator', 'A paper map', 'A wall clock', 'Voice assistants like Siri or Alexa'], 'answerIndex': 3},
        {'question': 'Machine Learning is best described as a subset of...?', 'options': ['Web Development', 'Artificial Intelligence', 'Graphic Design', 'Networking'], 'answerIndex': 1},
        {'question': "What is 'training data' used for in AI?", 'options': ['Storing user passwords', 'Teaching a model to make predictions', 'Rendering graphics', 'Sending emails'], 'answerIndex': 1},
      ],
      'c3': [
        {'question': 'Which of these is a popular library for building Machine Learning models?', 'options': ['Bootstrap', 'Figma', 'TensorFlow', 'WordPress'], 'answerIndex': 2},
        {'question': "What is 'overfitting' in machine learning?", 'options': ['Model trains too quickly', 'Model performs well on training data but poorly on new data', 'Model uses too little memory', 'Model has no data at all'], 'answerIndex': 1},
        {'question': 'Which type of learning uses labeled data?', 'options': ['Unsupervised learning', 'Reinforcement learning', 'No learning', 'Supervised learning'], 'answerIndex': 3},
        {'question': "A 'neural network' is loosely inspired by:", 'options': ['Electrical wiring in buildings', 'Ocean currents', 'The human brain', 'Traffic systems'], 'answerIndex': 2},
      ],
      'c4': [
        {'question': 'What does PLC stand for?', 'options': ['Personal Laptop Computer', 'Primary Line Circuit', 'Programmable Logic Controller', 'Power Load Converter'], 'answerIndex': 2},
        {'question': 'SCADA systems are primarily used for:', 'options': ['Editing photos', 'Monitoring and controlling industrial processes', 'Playing video games', 'Sending text messages'], 'answerIndex': 1},
        {'question': 'Which programming style is most commonly used for PLCs?', 'options': ['Python scripting', 'HTML markup', 'Ladder Logic', 'SQL queries'], 'answerIndex': 2},
        {'question': 'What does HMI stand for?', 'options': ['High Memory Index', 'Hardware Module Integration', 'Home Media Interface', 'Human Machine Interface'], 'answerIndex': 3},
      ],
      'c5': [
        {'question': 'What does IoT stand for?', 'options': ['Input Output Terminal', 'Integrated Output Tech', 'Internet of Things', 'Internet Operating Tool'], 'answerIndex': 2},
        {'question': 'Which protocol is commonly used for lightweight IoT messaging?', 'options': ['FTP', 'MQTT', 'SMTP', 'HTML'], 'answerIndex': 1},
        {'question': 'Which type of sensor is typically used to detect motion?', 'options': ['Barometer', 'Thermometer', 'PIR sensor', 'Speaker'], 'answerIndex': 2},
        {'question': 'Which of these is a popular IoT development board?', 'options': ['MacBook Pro', 'PlayStation', 'Kindle', 'ESP32'], 'answerIndex': 3},
      ],
      'c6': [
        {'question': "What does 'FDM' stand for in 3D printing?", 'options': ['Fast Data Movement', 'Full Design Mode', 'Fused Deposition Modeling', 'Final Draft Model'], 'answerIndex': 2},
        {'question': 'Which file format is most commonly used for 3D printable models?', 'options': ['MP3', 'STL', 'DOCX', 'CSV'], 'answerIndex': 1},
        {'question': 'What material is most commonly used in FDM 3D printers?', 'options': ['Copper wire', 'Glass sheets', 'PLA filament', 'Steel rods'], 'answerIndex': 2},
        {'question': "Why is 'bed adhesion' important in 3D printing?", 'options': ['Makes the printer faster', 'Reduces electricity usage', 'Changes the print color', 'Keeps the print stuck to the bed while printing'], 'answerIndex': 3},
      ],
      'c7': [
        {'question': 'Which programming environment is most commonly used to write Arduino code?', 'options': ['Visual Studio', 'Arduino IDE', 'Xcode', 'Android Studio'], 'answerIndex': 1},
        {'question': 'What does GPIO stand for?', 'options': ['General Purpose Input Output', 'Global Processing Input Ouput', 'Graphics Processing Input Output', 'General Program Input Order'], 'answerIndex': 0},
        {'question': 'Which communication protocol uses just 2 wires (SDA and SCL)?', 'options': ['SPI', 'UART', 'I2C', 'CAN'], 'answerIndex': 2},
        {'question': 'What is the purpose of PWM in embedded systems?', 'options': ['Storing data permanently', 'Simulating analog output using digital pins', 'Connecting to WiFi', 'Compiling code faster'], 'answerIndex': 1},
      ],
      'c8': [
        {'question': 'What is the basic building block of a neural network?', 'options': ['A perceptron/neuron', 'A database table', 'A CSS class', 'A router'], 'answerIndex': 0},
        {'question': "What does 'backpropagation' do in training a neural network?", 'options': ['Deletes unused layers', 'Adjusts weights based on error', 'Compresses the dataset', 'Renders the output'], 'answerIndex': 1},
        {'question': 'Which type of neural network is best suited for image data?', 'options': ['Recurrent Neural Network (RNN)', 'Convolutional Neural Network (CNN)', 'Decision Tree', 'Linear Regression'], 'answerIndex': 1},
        {'question': "What is an 'activation function' used for?", 'options': ['Introducing non-linearity into the network', 'Saving the model to disk', 'Connecting to a database', 'Formatting output text'], 'answerIndex': 0},
      ],
      'c9': [
        {'question': 'What does UAV stand for?', 'options': ['Unified Aerial Vehicle', 'Unmanned Aerial Vehicle', 'Universal Air Vessel', 'Unlimited Altitude Vehicle'], 'answerIndex': 1},
        {'question': 'Which component keeps a drone stable in the air?', 'options': ['Flight controller', 'SD card', 'HDMI port', 'Keyboard'], 'answerIndex': 0},
        {'question': "What does 'yaw' refer to in drone flight?", 'options': ['Forward/backward tilt', 'Left/right tilt', 'Rotation around the vertical axis', 'Battery voltage'], 'answerIndex': 2},
        {'question': 'Which of these is commonly used to program autonomous drone behavior?', 'options': ['MAVLink/PX4', 'CSS', 'Photoshop', 'Excel macros'], 'answerIndex': 0},
      ],
      'c10': [
        {'question': 'What is OpenCV primarily used for?', 'options': ['Computer vision and image processing', 'Web page styling', 'Database management', 'Audio editing'], 'answerIndex': 0},
        {'question': 'Which of these is a basic image operation in OpenCV?', 'options': ['Sending emails', 'Reading and displaying images', 'Compiling C++ code', 'Managing WiFi connections'], 'answerIndex': 1},
        {'question': 'What technique is commonly used to detect edges in an image?', 'options': ['Canny edge detection', 'Password hashing', 'JSON parsing', 'DNS lookup'], 'answerIndex': 0},
        {'question': 'What is a Haar Cascade Classifier commonly used for in OpenCV?', 'options': ['Face detection', 'Sound editing', 'File compression', 'Network routing'], 'answerIndex': 0},
      ],
      'c11': [
        {'question': 'In advanced industrial automation, what does SCADA primarily provide?', 'options': ['Supervisory monitoring and control of processes', 'Video editing tools', 'Web hosting', 'Social media management'], 'answerIndex': 0},
        {'question': 'What is the purpose of redundancy in industrial control systems?', 'options': ['To reduce cost', 'To ensure continued operation if a component fails', 'To slow down processes intentionally', 'To simplify wiring'], 'answerIndex': 1},
        {'question': 'Which protocol is commonly used for industrial device communication?', 'options': ['Modbus', 'HTTP cookies', 'Bluetooth pairing', 'Bitcoin mining'], 'answerIndex': 0},
        {'question': 'What is a key benefit of using HMI in industrial automation?', 'options': ['Letting operators visually monitor and control machines', 'Replacing all sensors', 'Eliminating the need for PLCs', 'Reducing internet usage'], 'answerIndex': 0},
      ],
      'c12': [
        {'question': 'Which microcontroller is commonly used for smart home projects due to built-in WiFi?', 'options': ['ESP32', 'Intel Pentium', 'Raspberry Pi Zero (WiFi-less models)', '8085 microprocessor'], 'answerIndex': 0},
        {'question': 'What component is typically used to control high-voltage home appliances safely from a microcontroller?', 'options': ['Relay module', 'USB cable', 'HDMI splitter', 'SD card'], 'answerIndex': 0},
        {'question': 'Which protocol is popular for lightweight smart home device messaging?', 'options': ['MQTT', 'FTP', 'SMTP', 'Telnet'], 'answerIndex': 0},
        {'question': 'What is a common way to control smart home devices remotely from a phone?', 'options': ['Through a cloud-connected mobile app', 'By physically rewiring the house daily', 'Through a fax machine', 'By mailing a letter'], 'answerIndex': 0},
      ],
    };

    for (final entry in allQuizzes.entries) {
      await seedCourseQuiz(entry.key, entry.value);
    }
  }

  // ---------- USER PROGRESS ----------
  static Future<Map<String, dynamic>> getUserStats() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return {'courses': 0, 'badges': 0, 'points': 0};
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return {'courses': 0, 'badges': 0, 'points': 0};
    final data = doc.data()!;
    return {
      'courses': data['coursesCompleted'] ?? 0,
      'badges': data['badges'] ?? 0,
      'points': data['points'] ?? 0,
    };
  }

  static Future<List<Map<String, dynamic>>> getCertificates() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('certificates')
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  static Future<void> addCertificate(String title, String colorHex) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('certificates')
        .add({
      'title': title,
      'date': DateTime.now().toIso8601String(),
      'color': colorHex,
    });
    await _db.collection('users').doc(uid).set({
      'coursesCompleted': FieldValue.increment(1),
      'points': FieldValue.increment(100),
    }, SetOptions(merge: true));
  }

  // ---------- SAVED COURSES ----------
  static Future<List<String>> getSavedCourseIds() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('saved_courses')
        .get();
    return snapshot.docs.map((d) => d.id).toList();
  }

  static Future<bool> isCourseSaved(String courseId) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('saved_courses')
        .doc(courseId)
        .get();
    return doc.exists;
  }

  static Future<void> toggleSaveCourse(String courseId, bool save) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('saved_courses')
        .doc(courseId);
    if (save) {
      await ref.set({'savedAt': DateTime.now().toIso8601String()});
    } else {
      await ref.delete();
    }
  }

  static Future<List<Course>> getSavedCourses() async {
    final savedIds = await getSavedCourseIds();
    if (savedIds.isEmpty) return [];
    final allCourses = await getCourses();
    return allCourses.where((c) => savedIds.contains(c.id)).toList();
  }

  // ---------- USER SETTINGS ----------
  static Future<bool> getNotificationSetting() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return true;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return true;
    return doc.data()?['notificationsEnabled'] ?? true;
  }

  static Future<void> setNotificationSetting(bool enabled) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'notificationsEnabled': enabled,
    }, SetOptions(merge: true));
  }

  // ---------- PROFILE PHOTO (stored as compressed Base64, no Storage needed) ----------
  static Future<String?> getProfilePhotoBase64() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['photoBase64'];
  }

  static Future<void> setProfilePhotoBase64(String base64Image) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'photoBase64': base64Image,
    }, SetOptions(merge: true));
  }

  static Future<void> removeProfilePhoto() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'photoBase64': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  // ---------- COURSE RATINGS & STUDENT COUNT (real, computed live) ----------
  static Future<void> markEnrolled(String courseId) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final ref = _db.collection('courses').doc(courseId).collection('enrolled_students').doc(uid);
    final existing = await ref.get();
    if (!existing.exists) {
      await ref.set({'enrolledAt': DateTime.now().toIso8601String()});
    }
  }

  static Future<int> getStudentCount(String courseId) async {
    final snapshot = await _db.collection('courses').doc(courseId).collection('enrolled_students').get();
    return snapshot.docs.length;
  }

  static Future<void> rateCourse(String courseId, int rating) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('courses').doc(courseId).collection('ratings').doc(uid).set({
      'rating': rating,
      'ratedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<int?> getUserRating(String courseId) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('courses').doc(courseId).collection('ratings').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['rating'];
  }

  static Future<Map<String, dynamic>> getCourseRatingStats(String courseId) async {
    final snapshot = await _db.collection('courses').doc(courseId).collection('ratings').get();
    if (snapshot.docs.isEmpty) return {'average': 0.0, 'count': 0};
    final ratings = snapshot.docs.map((d) => (d.data()['rating'] ?? 0) as int).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    return {'average': avg, 'count': ratings.length};
  }

  // ---------- SUBSCRIPTION / PREMIUM ----------
  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return {'active': false, 'expiry': null, 'plan': null};
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return {'active': false, 'expiry': null, 'plan': null};
    final data = doc.data()!;
    final expiryStr = data['subscriptionExpiry'];
    bool active = false;
    if (expiryStr != null) {
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        active = true;
      }
    }
    return {
      'active': active,
      'expiry': expiryStr,
      'plan': data['subscriptionPlan'],
    };
  }

  static Future<void> activateSubscription(String plan) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final now = DateTime.now();
    final expiry = plan == 'yearly'
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));
    await _db.collection('users').doc(uid).set({
      'subscriptionActive': true,
      'subscriptionPlan': plan,
      'subscriptionExpiry': expiry.toIso8601String(),
    }, SetOptions(merge: true));
  }

  static Future<void> seedNewCourses() async {
    final newCourses = [
      {
        'id': 'c7',
        'title': 'Arduino & Embedded Systems',
        'subtitle': 'Build real hardware projects from scratch',
        'level': 'Beginner',
        'category': 'Robotics',
        'rating': 4.6,
        'students': '640',
        'progress': 0,
        'gradientStart': 'FF241C52',
        'gradientEnd': 'FF0D1226',
        'modules': 10,
        'lessons': 22,
        'projects': 6,
        'isPremium': false,
      },
      {
        'id': 'c8',
        'title': 'Deep Learning & Neural Networks',
        'subtitle': 'Master CNNs, RNNs, and modern architectures',
        'level': 'Advanced',
        'category': 'AI & ML',
        'rating': 4.8,
        'students': '710',
        'progress': 0,
        'gradientStart': 'FF12294A',
        'gradientEnd': 'FF0D1226',
        'modules': 14,
        'lessons': 32,
        'projects': 8,
        'isPremium': true,
      },
      {
        'id': 'c9',
        'title': 'Drone Technology & UAVs',
        'subtitle': 'Learn flight mechanics and autonomous control',
        'level': 'Intermediate',
        'category': 'Robotics',
        'rating': 4.5,
        'students': '480',
        'progress': 0,
        'gradientStart': 'FF2C1C42',
        'gradientEnd': 'FF0D1226',
        'modules': 9,
        'lessons': 20,
        'projects': 5,
        'isPremium': false,
      },
      {
        'id': 'c10',
        'title': 'Computer Vision with OpenCV',
        'subtitle': 'Detect faces, objects, and motion in real time',
        'level': 'Intermediate',
        'category': 'AI & ML',
        'rating': 4.7,
        'students': '590',
        'progress': 0,
        'gradientStart': 'FF1C3A52',
        'gradientEnd': 'FF0D1226',
        'modules': 11,
        'lessons': 26,
        'projects': 7,
        'isPremium': false,
      },
      {
        'id': 'c11',
        'title': 'Industrial Automation (Advanced)',
        'subtitle': 'Advanced SCADA, redundancy, and safety systems',
        'level': 'Advanced',
        'category': 'PLC & SCADA',
        'rating': 4.6,
        'students': '360',
        'progress': 0,
        'gradientStart': 'FF0F3A3A',
        'gradientEnd': 'FF0D1226',
        'modules': 13,
        'lessons': 28,
        'projects': 6,
        'isPremium': true,
      },
      {
        'id': 'c12',
        'title': 'Smart Home Automation',
        'subtitle': 'Control lights, fans, and sensors from your phone',
        'level': 'Beginner',
        'category': 'IoT & Sensors',
        'rating': 4.6,
        'students': '520',
        'progress': 0,
        'gradientStart': 'FF1C4A2E',
        'gradientEnd': 'FF0D1226',
        'modules': 8,
        'lessons': 18,
        'projects': 5,
        'isPremium': false,
      },
    ];

    for (final course in newCourses) {
      await _db.collection('courses').doc(course['id'] as String).set(course);
    }
  }
}
