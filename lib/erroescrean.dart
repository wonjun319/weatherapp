import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              _buildTitle(context),
              const SizedBox(height: 8),
              _buildMessage(context),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                _buildRetryButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title ?? '오류가 발생했습니다',
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton(
      onPressed: onRetry,
      child: const Text('다시 시도'),
    );
  }
}
