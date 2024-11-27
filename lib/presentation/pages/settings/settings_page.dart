import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/pages/settings/theme_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Appearance',
              children: [
                _buildSettingTile(
                  icon: Icons.palette_rounded,
                  title: 'Theme',
                  subtitle: 'Customize app appearance',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemeSettingsPage(),
                      ),
                    );
                  },
                ),
                _buildSettingTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            _buildSection(
              title: 'Notifications',
              children: [
                _buildSettingTile(
                  icon: Icons.notifications_rounded,
                  title: 'Push Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.accent,
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.schedule_rounded,
                  title: 'Quiet Hours',
                  subtitle: '10:00 PM - 7:00 AM',
                  onTap: () {},
                ),
              ],
            ),
            _buildSection(
              title: 'Security',
              children: [
                _buildSettingTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Lock',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: AppColors.accent,
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.lock_rounded,
                  title: 'Change Password',
                  onTap: () {},
                ),
              ],
            ),
            _buildSection(
              title: 'Data',
              children: [
                _buildSettingTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup Data',
                  subtitle: 'Last backup: 2 days ago',
                  onTap: () {},
                ),
                _buildSettingTile(
                  icon: Icons.delete_rounded,
                  title: 'Clear Data',
                  textColor: AppColors.error,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
} 