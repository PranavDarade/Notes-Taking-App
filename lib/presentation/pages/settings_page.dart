import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.padding),
        children: [
          // Theme Section
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                context,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(settingsNotifierProvider.notifier).setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              _buildListTile(
                context,
                title: 'Theme Mode',
                subtitle: _getThemeModeText(settings.themeMode),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showThemeModeDialog(context, ref),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Security Section
          _buildSection(
            context,
            title: 'Security',
            children: [
              _buildSwitchTile(
                context,
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face unlock',
                value: settings.biometricEnabled,
                onChanged: (value) {
                  ref.read(settingsNotifierProvider.notifier).setBiometricEnabled(value);
                },
              ),
              _buildSwitchTile(
                context,
                title: 'Lock Sensitive Notes',
                subtitle: 'Require authentication for locked notes',
                value: settings.biometricEnabled,
                onChanged: (value) {
                  // TODO: Implement note locking
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Sync Section
          _buildSection(
            context,
            title: 'Sync & Backup',
            children: [
              _buildSwitchTile(
                context,
                title: 'Auto Sync',
                subtitle: 'Automatically sync notes with cloud',
                value: settings.autoSync,
                onChanged: (value) {
                  ref.read(settingsNotifierProvider.notifier).setAutoSync(value);
                },
              ),
              _buildListTile(
                context,
                title: 'Manual Sync',
                subtitle: 'Sync notes now',
                trailing: const Icon(Icons.sync),
                onTap: () {
                  // TODO: Implement manual sync
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync started')),
                  );
                },
              ),
              _buildListTile(
                context,
                title: 'Export Notes',
                subtitle: 'Export all notes to file',
                trailing: const Icon(Icons.download),
                onTap: () {
                  // TODO: Implement export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export feature coming soon')),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                context,
                title: 'Reminders',
                subtitle: 'Enable note reminders',
                value: settings.reminderEnabled,
                onChanged: (value) {
                  ref.read(settingsNotifierProvider.notifier).setReminderEnabled(value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Account Section
          if (authState.value != null)
            _buildSection(
              context,
              title: 'Account',
              children: [
                _buildListTile(
                  context,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  trailing: const Icon(Icons.logout),
                  onTap: () => _showSignOutDialog(context, ref),
                ),
              ],
            ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSection(
            context,
            title: 'About',
            children: [
              _buildListTile(
                context,
                title: 'App Version',
                subtitle: AppConstants.appVersion,
                trailing: null,
                onTap: null,
              ),
              _buildListTile(
                context,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              _buildListTile(
                context,
                title: 'Terms of Service',
                subtitle: 'View terms of service',
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Open terms of service
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: ref.read(settingsNotifierProvider).themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsNotifierProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: ref.read(settingsNotifierProvider).themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsNotifierProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: ref.read(settingsNotifierProvider).themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsNotifierProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
