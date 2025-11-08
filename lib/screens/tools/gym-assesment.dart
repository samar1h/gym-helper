import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GymReadinessAssessment extends StatefulWidget {
  const GymReadinessAssessment({super.key});

  @override
  State<GymReadinessAssessment> createState() => _GymReadinessAssessmentState();
}

class _GymReadinessAssessmentState extends State<GymReadinessAssessment> {
  // Page tracking
  int _currentPage = 0;
  
  // Statistics
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightCmController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // State variables
  bool _isMetric = true;
  String _gender = 'male';
  int _currentActivityLevel = 0; // 0=sedentary, 1=lightly, 2=moderately, 3=very, 4=super
  String _gymExperience = 'beginner'; // beginner, intermediate, advanced

  // PAR-Q+ Answers
  final Map<String, bool> _parqAnswers = {
    'heartCondition': false,
    'chestPain': false,
    'recentChestPain': false,
    'dizziness': false,
    'jointProblem': false,
    'bloodPressureMeds': false,
    'pregnant': false,
    'other': false,
  };

  // Health conditions
  final Map<String, bool> _conditions = {
    'diabetes': false,
    'asthma': false,
    'hypertension': false,
    'arthritis': false,
    'injury': false,
  };

  // Controlled conditions
  final Map<String, bool> _conditionControlled = {
    'asthma': false,
    'diabetes': false,
    'hypertension': false,
  };

  // Goals
  final Set<String> _selectedGoals = {};

  // Motivation
  final List<String> _selectedBarriers = [];

  // Time availability
  int _minutesPerDay = 0;
  int _daysPerWeek = 0;

  // Past experience
  bool _hadBadExperience = false;
  // ignore: unused_field
  String _badExperienceDescription = '';

  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ageController.dispose();
    _heightCmController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double _calculateBMI() {
    if (_heightCmController.text.isEmpty || _weightController.text.isEmpty) {
      return 0;
    }
    double height = double.parse(_heightCmController.text);
    double weight = double.parse(_weightController.text);
    if (!_isMetric) {
      weight = weight * 0.453592;
      double feet = double.parse(_heightFtController.text);
      double inches = double.parse(_heightInController.text);
      height = (feet * 12 + inches) * 2.54;
    }
    return weight / ((height / 100) * (height / 100));
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _nextPage() {
    if (_currentPage < 7) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _submitAssessment() {
    // Calculate readiness score
    int redFlags = 0;
    int yellowFlags = 0;

    // Check PAR-Q answers
    if (_parqAnswers['heartCondition'] == true ||
        _parqAnswers['chestPain'] == true ||
        _parqAnswers['dizziness'] == true) {
      redFlags += 3;
    }

    if (_parqAnswers['recentChestPain'] == true) yellowFlags += 2;
    if (_parqAnswers['jointProblem'] == true) yellowFlags += 1;
    if (_parqAnswers['bloodPressureMeds'] == true) yellowFlags += 1;

    // Check uncontrolled conditions
    if (_conditions['asthma'] == true && _conditionControlled['asthma'] != true) {
      redFlags += 2;
    }
    if (_conditions['diabetes'] == true && _conditionControlled['diabetes'] != true) {
      redFlags += 2;
    }

    // Check for injury
    if (_conditions['injury'] == true) yellowFlags += 2;

    // Check availability and motivation
    if (_minutesPerDay < 15 || _daysPerWeek < 1) yellowFlags += 1;

    // Calculate readiness level
    String readinessLevel;
    if (redFlags > 0) {
      readinessLevel = 'MEDICAL_CLEARANCE_NEEDED';
    } else if (yellowFlags >= 3) {
      readinessLevel = 'MODERATE_CAUTION';
    } else if (yellowFlags > 0) {
      readinessLevel = 'MINOR_CAUTION';
    } else {
      readinessLevel = 'READY';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymReadinessResultPage(
          readinessLevel: readinessLevel,
          redFlags: redFlags,
          yellowFlags: yellowFlags,
          age: int.tryParse(_ageController.text) ?? 0,
          bmi: _calculateBMI(),
          currentActivityLevel: _currentActivityLevel,
          goals: _selectedGoals,
          conditions: _conditions,
          controlledConditions: _conditionControlled,
          minutesPerDay: _minutesPerDay,
          daysPerWeek: _daysPerWeek,
          hadBadExperience: _hadBadExperience,
          gymExperience: _gymExperience,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: Row(
          children: [
            Icon(
              Icons.fitness_center,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Is Gym For Me?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: "Go Back",
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentPage + 1) / 8,
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Text(
                "Step ${_currentPage + 1} of 8",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // Page content
              if (_currentPage == 0) _buildPage0(), // Intro
              if (_currentPage == 1) _buildPage1(), // Stats
              if (_currentPage == 2) _buildPage2(), // Current Activity
              if (_currentPage == 3) _buildPage3(), // PAR-Q Health
              if (_currentPage == 4) _buildPage4(), // Conditions
              if (_currentPage == 5) _buildPage5(), // Goals
              if (_currentPage == 6) _buildPage6(), // Barriers & Time
              if (_currentPage == 7) _buildPage7(), // Experience

              const SizedBox(height: 32),

              // Navigation buttons
              Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back),
                            const SizedBox(width: 8),
                            Text(
                              "Previous",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _currentPage == 7 ? _submitAssessment : _nextPage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 7 ? "Get Results" : "Next",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Icon(_currentPage == 7 ? Icons.check_circle : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome to the Gym Readiness Assessment",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          "This assessment will help determine if you're ready to start a gym or exercise program. We'll ask about your health, current fitness level, and goals.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      "Why take this assessment?",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "• Identify potential health risks before starting exercise\n• Get personalized recommendations\n• Understand when to consult a doctor\n• Learn the best exercise approach for you",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.amber.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_outlined, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      "Important",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Please answer honestly. This assessment is based on the PAR-Q+ (Physical Activity Readiness Questionnaire), the standard pre-exercise screening tool.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Basic Information",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        // Unit toggle
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withAlpha(50),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isMetric = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isMetric
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Metric",
                          style: TextStyle(
                            color: _isMetric ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isMetric = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isMetric
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Imperial",
                          style: TextStyle(
                            color: !_isMetric ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Gender
        Text("Gender", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildChoiceCard('male', 'Male', Icons.male),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceCard('female', 'Female', Icons.female),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Age
        Text("Age", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: "years",
            hintText: "e.g., 25",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.cake),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Height
        Text(
          _isMetric ? "Height (cm)" : "Height",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_isMetric)
          TextFormField(
            controller: _heightCmController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            decoration: InputDecoration(
              labelText: "cm",
              hintText: "e.g., 170",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.height),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightFtController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Feet",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _heightInController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Inches",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),

        // Weight
        Text(
          _isMetric ? "Weight (kg)" : "Weight (lbs)",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: _isMetric ? "kg" : "lbs",
            hintText: _isMetric ? "e.g., 70" : "e.g., 154",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.monitor_weight_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // BMI display
        if (_calculateBMI() > 0)
          Card(
            color: Colors.cyan.withAlpha(30),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "BMI",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "${_calculateBMI().toStringAsFixed(1)} (${_getBMICategory(_calculateBMI())})",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Activity Level",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          "How much planned, structured exercise do you currently do?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ..._buildActivityButtons(),
        const SizedBox(height: 24),

        // Gym experience
        Text(
          "Gym Experience Level",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...[
          ('beginner', 'Beginner', 'Never trained with weights'),
          ('intermediate', 'Intermediate', '1-2 years experience'),
          ('advanced', 'Advanced', '3+ years experience'),
        ].map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _buildRadioCard(e.$1, e.$2, e.$3),
        )),
      ],
    );
  }

  Widget _buildPage3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Screening (PAR-Q+)",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.red.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.warning_outlined, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "If you answer YES to any of these, consult a doctor before exercising.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._buildPARQQuestions(),
      ],
    );
  }

  Widget _buildPage4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Conditions",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          "Do you have any of these conditions?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ..._buildConditionCheckboxes(),
      ],
    );
  }

  Widget _buildPage5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Goals",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          "What do you want to achieve? (Select all that apply)",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ..._buildGoalCheckboxes(),
      ],
    );
  }

  Widget _buildPage6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time & Motivation",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        Text(
          "How much time can you dedicate to exercise?",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setState(() => _minutesPerDay = int.tryParse(value) ?? 0),
                decoration: InputDecoration(
                  labelText: "minutes/day",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setState(() => _daysPerWeek = int.tryParse(value) ?? 0),
                decoration: InputDecoration(
                  labelText: "days/week",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          "Potential Barriers to Exercise",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._buildBarrierCheckboxes(),
      ],
    );
  }

  Widget _buildPage7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Past Experience",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),

        Text(
          "Have you had negative experiences with gyms or exercise programs?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        ..._buildExperienceButtons(),
      ],
    );
  }

  // Helper widget builders
  List<Widget> _buildActivityButtons() {
    final activities = [
      (0, 'Sedentary', 'Little to no exercise'),
      (1, 'Lightly Active', '1-3 days/week'),
      (2, 'Moderately Active', '3-5 days/week'),
      (3, 'Very Active', '6-7 days/week'),
      (4, 'Super Active', 'Intense training daily'),
    ];
    return activities.map((a) => Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: _buildActivityCard(a.$1, a.$2, a.$3),
    )).toList();
  }

  Widget _buildActivityCard(int value, String label, String desc) {
    return GestureDetector(
      onTap: () => setState(() => _currentActivityLevel = value),
      child: Card(
        elevation: _currentActivityLevel == value ? 4 : 1,
        color: _currentActivityLevel == value
            ? Theme.of(context).primaryColor.withAlpha(100)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _currentActivityLevel == value
                ? Theme.of(context).primaryColor
                : Colors.grey.withAlpha(50),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text(desc, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (_currentActivityLevel == value)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard(String value, String label, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Card(
        elevation: _gender == value ? 8 : 1,
        color: _gender == value ? Theme.of(context).primaryColor.withAlpha(100) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _gender == value
                ? Theme.of(context).primaryColor
                : Colors.grey.withAlpha(50),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: _gender == value ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: _gender == value ? Theme.of(context).primaryColor : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioCard(String value, String label, String desc) {
    return GestureDetector(
      onTap: () => setState(() => _gymExperience = value),
      child: Card(
        elevation: _gymExperience == value ? 4 : 1,
        color: _gymExperience == value ? Theme.of(context).primaryColor.withAlpha(100) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _gymExperience == value ? Theme.of(context).primaryColor : Colors.grey.withAlpha(50),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text(desc, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
              if (_gymExperience == value)
                Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPARQQuestions() {
    final questions = [
      ('heartCondition', 'Has a doctor said you have a heart condition?'),
      ('chestPain', 'Do you feel chest pain during physical activity?'),
      ('recentChestPain', 'Have you had chest pain in the past month (not during activity)?'),
      ('dizziness', 'Do you lose balance or faint due to dizziness?'),
      ('jointProblem', 'Do you have a joint/bone problem made worse by activity?'),
      ('bloodPressureMeds', 'Are you taking medications for blood pressure or heart?'),
      ('pregnant', 'Are you pregnant?'),
    ];
    return questions.map((q) => Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildYesNoQuestion(q.$1, q.$2),
    )).toList();
  }

  Widget _buildYesNoQuestion(String key, String question) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(question, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _parqAnswers[key] = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _parqAnswers[key] == false
                          ? Colors.green.withAlpha(100)
                          : Colors.transparent,
                      border: Border.all(
                        color: _parqAnswers[key] == false ? Colors.green : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: _parqAnswers[key] == false ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _parqAnswers[key] = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _parqAnswers[key] == true
                          ? Colors.red.withAlpha(100)
                          : Colors.transparent,
                      border: Border.all(
                        color: _parqAnswers[key] == true ? Colors.red : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: _parqAnswers[key] == true ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConditionCheckboxes() {
    final conditions = [
      ('diabetes', 'Diabetes'),
      ('asthma', 'Asthma'),
      ('hypertension', 'High Blood Pressure'),
      ('arthritis', 'Arthritis'),
      ('injury', 'Recent Injury/Surgery'),
    ];
    return conditions.map((c) => Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: Text(c.$2),
            value: _conditions[c.$1] ?? false,
            onChanged: (value) {
              setState(() {
                _conditions[c.$1] = value ?? false;
                if (value == false) {
                  _conditionControlled[c.$1] = false;
                }
              });
            },
          ),
          if (_conditions[c.$1] == true && ['diabetes', 'asthma', 'hypertension'].contains(c.$1))
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 8.0),
              child: CheckboxListTile(
                title: Text('Well controlled with medication'),
                value: _conditionControlled[c.$1] ?? false,
                onChanged: (value) => setState(() => _conditionControlled[c.$1] = value ?? false),
              ),
            ),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildGoalCheckboxes() {
    final goals = ['Weight Loss', 'Build Muscle', 'General Health', 'Increase Strength', 'Mental Health'];
    return goals.map((goal) => CheckboxListTile(
      title: Text(goal),
      value: _selectedGoals.contains(goal),
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedGoals.add(goal);
          } else {
            _selectedGoals.remove(goal);
          }
        });
      },
    )).toList();
  }

  List<Widget> _buildBarrierCheckboxes() {
    final barriers = ['Lack of Time', 'No Motivation', 'Expensive', 'Gym Anxiety', 'Health Concerns', 'No Experience'];
    return barriers.map((barrier) => CheckboxListTile(
      title: Text(barrier),
      value: _selectedBarriers.contains(barrier),
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedBarriers.add(barrier);
          } else {
            _selectedBarriers.remove(barrier);
          }
        });
      },
    )).toList();
  }

  List<Widget> _buildExperienceButtons() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text('Yes, I\'ve had negative experiences'),
              value: _hadBadExperience,
              onChanged: (value) => setState(() => _hadBadExperience = value ?? false),
            ),
            if (_hadBadExperience)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextFormField(
                  onChanged: (value) => _badExperienceDescription = value,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Tell us about it (optional)",
                    hintText: "E.g., injury, intimidation, didn't see results...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }
}

// Result Page - Will be implemented next
class GymReadinessResultPage extends StatelessWidget {
  final String readinessLevel;
  final int redFlags;
  final int yellowFlags;
  final int age;
  final double bmi;
  final int currentActivityLevel;
  final Set<String> goals;
  final Map<String, bool> conditions;
  final Map<String, bool> controlledConditions;
  final int minutesPerDay;
  final int daysPerWeek;
  final bool hadBadExperience;
  final String gymExperience;

  const GymReadinessResultPage({
    super.key,
    required this.readinessLevel,
    required this.redFlags,
    required this.yellowFlags,
    required this.age,
    required this.bmi,
    required this.currentActivityLevel,
    required this.goals,
    required this.conditions,
    required this.controlledConditions,
    required this.minutesPerDay,
    required this.daysPerWeek,
    required this.hadBadExperience,
    required this.gymExperience,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Assessment Results"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: "Go Back",
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main result card
              if (readinessLevel == 'READY')
                _buildReadyCard(context)
              else if (readinessLevel == 'MINOR_CAUTION')
                _buildCautionCard(context, 'Minor Precautions Recommended')
              else if (readinessLevel == 'MODERATE_CAUTION')
                _buildCautionCard(context, 'Moderate Precautions Recommended')
              else
                _buildMedicalCard(context),

              const SizedBox(height: 24),

              // Your Assessment Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Assessment Summary",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(context, "Age", "$age years"),
                      _buildSummaryRow(context, "BMI", "${bmi.toStringAsFixed(1)} (${_getBMICategory(bmi)})"),
                      _buildSummaryRow(context, "Current Activity", _getActivityLabel()),
                      _buildSummaryRow(context, "Gym Experience", _getExperienceLabel()),
                      _buildSummaryRow(context, "Available Time", "$minutesPerDay min, $daysPerWeek days/week"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recommendations
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personalized Recommendations",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildRecommendations(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gym Type Suggestions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gym Type Suggestions",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildGymTypeSuggestions(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Important Disclaimer
              Card(
                color: Colors.amber.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            "Important Disclaimer",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This assessment is based on the PAR-Q+ questionnaire. If you answered YES to any health questions, consult your doctor BEFORE starting an exercise program. This app is for educational purposes and should not replace professional medical advice.",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.green.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              "You're Ready!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You appear to be ready to start a gym or exercise program.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Start slowly and build up gradually.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCautionCard(BuildContext context, String title) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.orange.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.warning_outlined, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You may proceed with exercise, but with some precautions.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.red.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.cancel, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              "Medical Clearance Required",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You should consult a doctor BEFORE starting an exercise program.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    List<String> recs = [];

    if (currentActivityLevel == 0) {
      recs.add("Start with low-intensity activities (walking, swimming, light weights)");
    } else {
      recs.add("Progress gradually - increase volume/intensity by 10% per week");
    }

    if (goals.contains('Build Muscle')) {
      recs.add("Prioritize strength training 3-4 days/week with adequate protein");
    }

    if (goals.contains('Weight Loss')) {
      recs.add("Combine cardio (3-4x/week) with strength training (2-3x/week)");
    }

    if (bmi > 30) {
      recs.add("Focus on lower-impact activities (swimming, cycling, elliptical) to protect joints");
    }

    if (conditions['asthma'] == true || conditions['hypertension'] == true) {
      recs.add("Work with a trainer familiar with your condition");
    }

    if (minutesPerDay < 20) {
      recs.add("Even 15 minutes of activity is beneficial - consistency matters more than duration");
    }

    if (hadBadExperience) {
      recs.add("Consider working with a personal trainer to rebuild confidence");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recs.map((rec) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(rec, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildGymTypeSuggestions(BuildContext context) {
    List<MapEntry<String, String>> suggestions = [];

    if (gymExperience == 'beginner') {
      suggestions.add(MapEntry("Personal Trainer", "1-2 sessions to learn proper form"));
    }

    if (minutesPerDay < 30 || hadBadExperience) {
      suggestions.add(MapEntry("Home Workouts", "YouTube, apps, or online programs"));
    }

    if (goals.isEmpty || goals.contains('General Health')) {
      suggestions.add(MapEntry("Commercial Gym", "Full equipment variety, community atmosphere"));
    }

    if (conditions['arthritis'] == true || bmi > 30) {
      suggestions.add(MapEntry("Aquatic Facilities", "Low-impact environment"));
    }

    if (bmi < 25 && goals.contains('Build Muscle')) {
      suggestions.add(MapEntry("Powerlifting/Strength Gym", "Specialized equipment, community"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.key, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(s.value, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  String _getActivityLabel() {
    const labels = ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Super Active'];
    return labels[currentActivityLevel];
  }

  String _getExperienceLabel() {
    switch (gymExperience) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
