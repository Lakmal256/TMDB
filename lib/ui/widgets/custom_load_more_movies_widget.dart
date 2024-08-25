import 'package:flutter/material.dart';

class LoadMoreRow extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const LoadMoreRow({required this.isLoading, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.replay, size: 26, color: Colors.deepPurple),
            Text(
              'Load More',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}