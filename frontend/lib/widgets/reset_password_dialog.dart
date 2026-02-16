import 'package:flutter/material.dart';
import 'dart:math';

import '../services/api_service.dart';

class ResetPasswordDialog extends StatefulWidget {
  final int userId;
  final String userName; // New property

  const ResetPasswordDialog({super.key, required this.userId, required this.userName});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  late TextEditingController _passwordController;
  bool _obscureText = true;
  bool _isGenerating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _generatePassword();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String _generateRandomPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        12,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _generatePassword() async {
    setState(() {
      _isGenerating = true;
    });
    final newPassword = _generateRandomPassword();
    setState(() {
      _passwordController.text = newPassword;
      _isGenerating = false;
    });
  }

  Future<void> _savePassword() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService.resetUserPassword(
        widget.userId,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pop(true); // Indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароль успешно сброшен.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сброса пароля: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Сброс пароля для ${widget.userName}'), // Use userName in title
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
              'При сбросе пароля будет установлен новый пароль, который нужно будет сообщить пользователю. Продолжить?',
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    IconButton(
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      onPressed: _isGenerating ? null : _generatePassword,
                      tooltip: 'Сгенерировать новый пароль',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cancel
          },
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _savePassword,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Сбросить пароль'),
        ),
      ],
    );
  }
}
