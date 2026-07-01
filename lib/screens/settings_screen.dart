import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/subscription_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _subscriptionService = SubscriptionService();

  bool _isPremium = false;
  bool _isLoading = true;
  bool _isRestoring = false;
  bool _notificationsEnabled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await _subscriptionService.init(appUserId: userId);
      final isPremium = await _subscriptionService.isPremium();
      if (mounted) {
        setState(() {
          _isPremium = isPremium;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isRestoring = true);
    try {
      final isPremium = await _subscriptionService.restorePurchases();
      if (mounted) {
        setState(() {
          _isPremium = isPremium;
          _isRestoring = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isPremium ? 'Premium restored.' : 'No active subscription found.'),
          backgroundColor: PulseFlowColors.deepPurple,
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: PulseFlowColors.deepPurple,
      appBar: AppBar(
        backgroundColor: PulseFlowColors.deepPurple,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: PulseFlowColors.paleGold),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PulseFlowColors.paleGold))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _SectionHeader('Account'),
                ListTile(
                  title: const Text('Email', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  subtitle: Text(email, style: const TextStyle(color: Colors.white)),
                ),
                ListTile(
                  title: const Text('Sign out', style: TextStyle(color: PulseFlowColors.paleGold)),
                  leading: const Icon(Icons.logout, color: PulseFlowColors.paleGold),
                  onTap: _signOut,
                ),
                const Divider(color: Colors.white12),
                _SectionHeader('Subscription'),
                ListTile(
                  title: const Text('Status', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  subtitle: Text(
                    _isPremium ? 'Premium' : 'Free',
                    style: TextStyle(
                      color: _isPremium ? PulseFlowColors.paleGold : Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: OutlinedButton(
                    onPressed: _isRestoring ? null : _restorePurchases,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PulseFlowColors.paleGold,
                      side: const BorderSide(color: PulseFlowColors.paleGold),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isRestoring
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: PulseFlowColors.paleGold),
                          )
                        : const Text('Restore Purchases'),
                  ),
                ),
                const Divider(color: Colors.white12),
                _SectionHeader('Notifications'),
                SwitchListTile(
                  title: const Text('Session reminders', style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    'Remind me to start a session',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  value: _notificationsEnabled,
                  activeThumbColor: PulseFlowColors.paleGold,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: PulseFlowColors.paleGold,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
