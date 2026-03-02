import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';

/// Show this dialog after a trip is completed.
/// Returns true if the rating was submitted successfully.
Future<bool?> showRatingDialog(BuildContext context, int bookingId) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RatingDialog(bookingId: bookingId),
  );
}

class _RatingDialog extends StatefulWidget {
  final int bookingId;
  const _RatingDialog({required this.bookingId});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _stars = 0;
  final _commentCtrl = TextEditingController();
  bool _loading = false;
  bool _done = false;

  static const _gold = Color(0xFFD4AF37);
  static const _navy = Color(0xFF0B3254);

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) return;
    setState(() => _loading = true);
    try {
      await ApiService.rateTrip(
        bookingId: widget.bookingId,
        rating: _stars,
        comment: _commentCtrl.text.trim(),
      );
      setState(() {
        _done = true;
        _loading = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not submit rating. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final t = context.read<LocaleProvider>().t;
    return Dialog(
      backgroundColor: _navy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _done ? _buildThanks(t) : _buildForm(t, locale),
      ),
    );
  }

  Widget _buildThanks(String Function(String) t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: _gold, size: 64),
        const SizedBox(height: 16),
        Text(t('rate_thanks'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildForm(String Function(String) t, String locale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFD4AF3720),
          child: Icon(Icons.star_rate_rounded, color: _gold, size: 36),
        ),
        const SizedBox(height: 14),
        Text(t('rate_title'),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Booking #${widget.bookingId}',
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 20),
        // Stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < _stars;
            return GestureDetector(
              onTap: () => setState(() => _stars = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _gold,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        // Comment field
        TextField(
          controller: _commentCtrl,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: t('rate_placeholder'),
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(t('cancel')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _stars > 0 && !_loading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: _navy,
                  disabledBackgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t('rate_submit'), style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
