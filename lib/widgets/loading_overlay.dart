import 'package:flutter/material.dart';

class CustomLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const CustomLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              // color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
