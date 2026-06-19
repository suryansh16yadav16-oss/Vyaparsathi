import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../database/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception('External storage not available');
      final backupPath = '${directory.path}/vyparsathi_backup_${DateTime.now().millisecondsSinceEpoch}.db';
      await DatabaseHelper().backupDatabase(backupPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database backed up to $backupPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception('External storage not available');
      // For simplicity, we assume the backup file is named vyparsathi_backup.db in the same directory.
      // In a real app, you'd use file picker.
      final backupFile = File('${directory.path}/vyparsathi_backup.db');
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found. Please place vyparsathi_backup.db in ${directory.path}');
      }
      await DatabaseHelper().restoreDatabase(backupFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database restored successfully. Restart app to apply.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: settingsProvider.isDarkMode,
            onChanged: (_) => settingsProvider.toggleDarkMode(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Database'),
            subtitle: const Text('Export database to external storage'),
            onTap: () => _backupDatabase(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Database'),
            subtitle: const Text('Import database from external storage'),
            onTap: () => _restoreDatabase(context),
          ),
        ],
      ),
    );
  }
}
