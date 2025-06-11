import 'package:flutter/material.dart';

class PinLock extends StatefulWidget {
  final Function(String) onComplete;
  final bool isSetupMode;

  const PinLock({
    Key? key,
    required this.onComplete,
    this.isSetupMode = false,
  }) : super(key: key);

  @override
  State<PinLock> createState() => _PinLockState();
}

class _PinLockState extends State<PinLock> {
  final List<String> _pin = [];
  final int _maxLength = 6;

  void _onNumberPressed(String number) {
    if (_pin.length < _maxLength) {
      setState(() {
        _pin.add(number);
      });

      if (_pin.length == _maxLength) {
        widget.onComplete(_pin.join());
        setState(() {
          _pin.clear();
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _maxLength,
                (index) => Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length ? Colors.blue : Colors.grey[300],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 1; i <= 9; i++)
                  _buildNumberButton(i.toString()),
                _buildNumberButton(''),
                _buildNumberButton('0'),
                _buildDeleteButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: number.isEmpty ? null : () => _onNumberPressed(number),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          number,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: _onDeletePressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.red,
        ),
        child: const Icon(
          Icons.backspace,
          color: Colors.white,
        ),
      ),
    );
  }
} 