import 'package:flutter/material.dart';
import '../../systems/daily_reward_manager.dart';

class DailyRewardDialog extends StatefulWidget {
  final VoidCallback onClaimed;

  const DailyRewardDialog({super.key, required this.onClaimed});

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> {
  bool _canClaim = false;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _canClaim = DailyRewardManager.canClaimToday();
    _streak = DailyRewardManager.getCurrentStreak();
  }

  Future<void> _claim() async {
    final reward = await DailyRewardManager.claimReward();
    setState(() {
      _canClaim = false;
      _streak = DailyRewardManager.getCurrentStreak();
    });
    widget.onClaimed();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed ${reward.rewardLabel}! 🎉'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 6),
              const Text(
                'DAILY REWARDS',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Current Streak: $_streak Days 🔥',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),

              // 7-day row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(7, (idx) {
                  final tier = DailyRewardManager.tiers[idx];
                  final isCurrent = (idx == (_streak % 7));
                  final isPassed = (idx < (_streak % 7));

                  return Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.pinkAccent.withOpacity(0.25)
                          : isPassed
                              ? Colors.green.withOpacity(0.15)
                              : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.pinkAccent
                            : isPassed
                                ? Colors.green
                                : Colors.white12,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'D${tier.day}',
                          style: TextStyle(
                            color: isCurrent ? Colors.pinkAccent : Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(tier.iconEmoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          '+${tier.coins}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canClaim ? Colors.pinkAccent : Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _canClaim ? _claim : null,
                child: Text(
                  _canClaim ? 'CLAIM TODAY\'S GIFT! 🎁' : 'ALREADY CLAIMED (COME BACK TOMORROW)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 6),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
