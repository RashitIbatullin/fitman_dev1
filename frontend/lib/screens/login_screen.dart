import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+70000000000'; // Тестовые данные
    _passwordController.text = 'admin123';
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем состояние для отображения ошибок
    ref.listen<AsyncValue>(authProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка входа: ${state.error}')));
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в систему'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_gymnastics, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Фитнес-менеджер',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите номер телефона';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите пароль';
                  if (value.length < 6) {
                    return 'Пароль должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (authState.isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Войти', style: TextStyle(fontSize: 16)),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет аккаунта?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Зарегистрируйтесь'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Тестовые пользователи:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  _buildTestUserChip('+70000000000', 'admin123', 'Админ'),
                  _buildTestUserChip(
                    '+70000000001',
                    'instructor123',
                    'Инструктор',
                  ),
                  _buildTestUserChip(
                    '+70000000002',
                    'trainer123',
                    'Тренер',
                  ),
                  _buildTestUserChip(
                    '+70000000003',
                    'manager123',
                    'Менеджер',
                  ),
                  _buildTestUserChip('+70000000004', 'client123', 'Клиент'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestUserChip(String phone, String password, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _phoneController.text = phone;
        _passwordController.text = password;
        _handleLogin();
      },
      backgroundColor: Colors.blue.shade100,
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      print('[LoginScreen] Handling login...');
      ref
          .read(authProvider.notifier)
          .login(_phoneController.text.trim(), _passwordController.text);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
