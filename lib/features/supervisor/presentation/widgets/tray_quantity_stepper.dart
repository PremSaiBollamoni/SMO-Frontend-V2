import 'package:flutter/material.dart';

class TrayQuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const TrayQuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          IconButton(
            onPressed: value > 1 ? onDecrement : null,
            icon: const Icon(Icons.remove),
            color: value > 1 ? Theme.of(context).primaryColor : Colors.grey,
            splashRadius: 20,
          ),

          // Value display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Increment button
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
            color: Theme.of(context).primaryColor,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
