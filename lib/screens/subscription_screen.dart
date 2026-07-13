import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';
import '../services/firestore_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'monthly';
  bool _processing = false;
  bool _loadingStatus = true;
  bool _alreadySubscribed = false;
  String? _currentPlan;
  String? _expiryDate;

  @override
  void initState() {
    super.initState();
    PaymentService.init();
    _loadStatus();
  }

  @override
  void dispose() {
    PaymentService.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final status = await FirestoreService.getSubscriptionStatus();
    if (!mounted) return;
    setState(() {
      _alreadySubscribed = status['active'] == true;
      _currentPlan = status['plan'];
      _expiryDate = status['expiry'];
      _loadingStatus = false;
    });
  }

  Future<void> _subscribe() async {
    setState(() => _processing = true);
    await PaymentService.startCheckout(
      plan: _selectedPlan,
      onSuccess: (plan) {
        setState(() => _processing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subscribed successfully! Enjoy premium courses')),
          );
          _loadStatus();
        }
      },
      onError: (error) {
        setState(() => _processing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                _backButton(context),
                Expanded(child: Text('Premium', textAlign: TextAlign.center, style: AppText.display(size: 17))),
                const SizedBox(width: 38),
              ],
            ),
            const SizedBox(height: 20),

            if (_loadingStatus)
              const Center(child: CircularProgressIndicator())
            else if (_alreadySubscribed) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(colors: [AppColors.blue, AppColors.purple]),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    Text('You are a Premium Member!', style: AppText.display(size: 17, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      '${_currentPlan == 'yearly' ? 'Yearly' : 'Monthly'} plan Renews on ${_formatDate(_expiryDate)}',
                      style: AppText.body(size: 12.5, color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 48),
              const SizedBox(height: 12),
              Text('Unlock Premium Courses', style: AppText.display(size: 19), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                'Get full access to advanced courses, exclusive content, and more.',
                textAlign: TextAlign.center,
                style: AppText.muted(size: 13),
              ),
              const SizedBox(height: 24),

              _planCard(
                plan: 'monthly',
                title: 'Monthly',
                price: '₹99',
                subtitle: 'per month',
              ),
              const SizedBox(height: 12),
              _planCard(
                plan: 'yearly',
                title: 'Yearly',
                price: '₹799',
                subtitle: 'per year save 33%',
                badge: 'BEST VALUE',
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _processing ? null : _subscribe,
                  child: _processing
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Subscribe Now', style: AppText.body(size: 14, weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This is a test payment (Razorpay test mode). No real money will be charged.',
                textAlign: TextAlign.center,
                style: AppText.muted(size: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _planCard({
    required String plan,
    required String title,
    required String price,
    required String subtitle,
    String? badge,
  }) {
    final selected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.blue : AppColors.line, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? AppColors.blue : AppColors.text2,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(title, style: AppText.body(size: 14.5, weight: FontWeight.w700)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
                        child: Text(badge, style: AppText.body(size: 9.5, weight: FontWeight.w700, color: AppColors.gold)),
                      ),
                    ],
                  ]),
                  Text(subtitle, style: AppText.muted(size: 12)),
                ],
              ),
            ),
            Text(price, style: AppText.display(size: 18)),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text1),
        ),
      );
}
