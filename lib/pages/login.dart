import 'package:flutter/material.dart';
import 'package:school_forum/api/local_storage.dart';
import 'package:school_forum/api/user.dart';
import 'package:school_forum/main.dart';
import 'package:school_forum/api/supabase.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    LocalStorage.isLoggedIn().then((isLoggedIn) {
      if (isLoggedIn) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.session != null && response.user != null) {
        await LocalStorage.saveLoginInfo(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken ?? '',
          user: UserModel.fromJson(response.user!.toJson()),
        );
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo or Title
                    const Icon(
                      Icons.school,
                      size: 80,
                      color: Color(0xFF00D4AA),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '赞噢校园集市',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '欢迎回来',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: '邮箱',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00D4AA),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入邮箱';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return '请输入有效的邮箱地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: '密码',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey[400],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00D4AA),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        if (value.length < 6) {
                          return '密码至少6位字符';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D4AA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          disabledBackgroundColor: Colors.grey[600],
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  '登录',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('忘记密码功能待实现')),
                        );
                      },
                      child: const Text(
                        '忘记密码？',
                        style: TextStyle(color: Color(0xFF00D4AA)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '没有账号？',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('注册功能待实现')),
                            );
                          },
                          child: const Text(
                            '立即注册',
                            style: TextStyle(
                              color: Color(0xFF00D4AA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
