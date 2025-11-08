
// New settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_helper/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: 'Go Back',
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section
            _buildSectionHeader(context, 'Appearance', Icons.palette),
            _buildThemeModeSection(context),
            
            const Divider(height: 32),
            
            // Accent Color Section
            _buildSectionHeader(context, 'Accent Color', Icons.format_color_fill),
            _buildAccentColorSection(context),
            
            const Divider(height: 32),
            
            // About Section
            _buildSectionHeader(context, 'About', Icons.info),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Theme Mode Section
  Widget _buildThemeModeSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          children: [
            _buildSettingsTile(
              context: context,
              title: 'Light Theme',
              subtitle: 'Use light theme',
              selected: themeProvider.themeMode == ThemeMode.light,
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              icon: Icons.light_mode,
            ),
            _buildSettingsTile(
              context: context,
              title: 'Dark Theme',
              subtitle: 'Use dark theme',
              selected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              icon: Icons.dark_mode,
            ),
            _buildSettingsTile(
              context: context,
              title: 'System Default',
              subtitle: 'Follow system theme',
              selected: themeProvider.themeMode == ThemeMode.system,
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              icon: Icons.settings_brightness,
            ),
          ],
        );
      },
    );
  }

  // Accent Color Section
  Widget _buildAccentColorSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select your preferred accent color',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: AppTheme.accentColors.length,
                itemBuilder: (context, index) {
                  final color = AppTheme.accentColors[index];
                  final isSelected = themeProvider.accentColor == color;
                  
                  return GestureDetector(
                    onTap: () => themeProvider.setAccentColor(color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                            ? Colors.white 
                            : Colors.transparent,
                          width: isSelected ? 4 : 2,
                        ),
                        boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(150),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                      ),
                      child: isSelected
                        ? Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Settings Tile Widget
  Widget _buildSettingsTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 0,
        color: selected
          ? Theme.of(context).primaryColor.withAlpha(30)
          : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected
              ? Theme.of(context).primaryColor.withAlpha(100)
              : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(
            icon,
            color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyMedium?.color,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: Radio<bool>(
            value: true,
            groupValue: selected,
            onChanged: (_) => onTap(),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  // About Section
  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gym Helper',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Your personal fitness companion with powerful tools for health calculations and fitness tracking.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
