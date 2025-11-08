import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Define your features list
  final List<Map<String, dynamic>> _allFeatures = [
    {
      'name': 'BMI Calculator',
      'description':
          'Check your Body Mass Index to see if you\'re in a healthy weight range.',
      'icon': Icons.monitor_weight,
      'route': '/bmi-calculator',
    },
    {
      'name': 'BMR Calculator',
      'description': 'Find out how many calories your body burns at rest.',
      'icon': Icons.local_fire_department,
      'route': '/bmr-calculator',
    },
    {
      'name': 'Calorie Calculator',
      'description':
          'Complete Fitness Calculator - BMR, TDEE, and Calorie Targets',
      'icon': Icons.calculate,
      'route': '/calorie-calculator',
    },
    {
      'name': 'Protein Calculator',
      'description':
          'Determine your ideal daily protein intake based on your weight and fitness goals.',
      'icon': Icons.fitness_center,
      'route': '/protein-calculator',
    },
    {
      'name': 'Body Fat Calculator',
      'description':
          'Estimate your body fat percentage using simple body measurements.',
      'icon': Icons.straighten,
      'route': '/body-fat-calculator',
    },
    {
      'name': 'Water Intake Calculator',
      'description':
          'Find out how much water you should drink each day to stay properly hydrated.',
      'icon': Icons.water_drop,
      'route': '/water-calculator',
    },
    {
      'name': 'Ideal Weight Calculator',
      'description':
          'Discover a recommended healthy weight range for your height and body type.',
      'icon': Icons.self_improvement,
      'route': '/ideal-weight-calculator',
    },
    {
      'name': 'Should I Start Gym?',
      'description':
          'A Questionnaire that suggests if you should join a gym or not..',
      'icon': Icons.line_weight_sharp,
      'route': '/is-gym-for-me',
    },
    {
      'name': 'Daily Steps Calculator',
      'description':
          'Provides personalized recommendations based on age, activity, lifestyle, etc.',
      'icon': FontAwesome.person_walking_solid,
      'route': '/daily-steps',
    },
    {
      'name': 'VO2 Max Estimator',
      'description':
          'Estimates Max. Ammount of Oxygen Your Body Can Use During Intense Exercises',
      'icon': Icons.favorite,
      'route': '/vo2-max-estimator',
    },
    {
      'name': 'Sleep Calculator',
      'description': 'How much should you sleep?',
      'icon': Icons.nightlight_round,
      'route': '/sleep-calculator',
    },
    {
      'name': 'Macronutrient Calculator',
      'description': 'Break down your daily calories into optimal protein, carbs, and fat ratios for your fitness goals',
      'icon': Icons.restaurant_menu,
      'route': '/macronutrient-calculator',
    },
  ];

  List<Map<String, dynamic>> get _filteredFeatures {
    if (_searchQuery.isEmpty) {
      return _allFeatures;
    }
    return _allFeatures.where((feature) {
      final nameLower = feature['name'].toString().toLowerCase();
      final descLower = feature['description'].toString().toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower) || descLower.contains(queryLower);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search features...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: TextStyle(color: Colors.black87, fontSize: 16),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                "Gym Helper",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
        centerTitle: false,
        actions: [
          if (_isSearching)
            IconButton(
              onPressed: _stopSearch,
              icon: Icon(Icons.close),
              tooltip: "Close Search",
            )
          else
            IconButton(
              onPressed: _startSearch,
              icon: Icon(Icons.search),
              tooltip: "Search",
            ),
          if (!_isSearching)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/settings");
              },
              icon: Icon(Icons.settings),
              tooltip: "Settings",
            ),
          SizedBox(width: 10),
        ],
      ),
      body: _filteredFeatures.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No features found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredFeatures.length,
              itemBuilder: (context, index) {
                final feature = _filteredFeatures[index];
                return featureCard(
                  feature['name'],
                  feature['description'],
                  feature['icon'],
                  feature['route'],
                  context,
                );
              },
            ),
    );
  }

  Widget featureCard(
    String featureName,
    String description,
    IconData icon,
    String routeName,
    BuildContext context,
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      featureName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
