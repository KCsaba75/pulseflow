import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/subscription_service.dart';
import '../theme.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _subscriptionService = SubscriptionService();
  Offerings? _offerings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await _subscriptionService.getOfferings();
      setState(() {
        _offerings = offerings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _buy(Package package) async {
    final success = await _subscriptionService.purchasePackage(package);
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packages = _offerings?.current?.availablePackages ?? [];

    return Scaffold(
      backgroundColor: PulseFlowColors.deepPurple,
      appBar: AppBar(
        backgroundColor: PulseFlowColors.deepPurple,
        title: const Text('Go Premium', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: PulseFlowColors.paleGold),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: PulseFlowColors.paleGold))
              : _error != null
                  ? Center(
                      child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Unlock unlimited sessions, all presets,\nand every timer length.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 32),
                        for (final package in packages)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ElevatedButton(
                              onPressed: () => _buy(package),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PulseFlowColors.paleGold,
                                foregroundColor: PulseFlowColors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                '${package.storeProduct.title} — ${package.storeProduct.priceString}',
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}
