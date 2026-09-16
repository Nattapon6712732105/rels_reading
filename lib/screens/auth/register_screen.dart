import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/storage/local_novel_storage.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'widgets/pdpa_consent_sheet.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _otpSent = false;
  bool _consentAccepted = false;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _checkInitialConsent();
  }

  Future<void> _checkInitialConsent() async {
    final accepted = await LocalNovelStorage.isConsentAccepted();
    if (mounted) {
      setState(() {
        _consentAccepted = accepted;
      });
    }
  }

  Future<bool> _ensureConsent() async {
    if (_consentAccepted) return true;

    final accepted = await PdpaConsentSheet.show(
      context,
      onAccepted: () {
        if (mounted) setState(() => _consentAccepted = true);
      },
    );

    if (accepted && mounted) {
      setState(() => _consentAccepted = true);
      return true;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณายินยอมตามกฎหมาย PDPA และลิขสิทธิ์ก่อนลงทะเบียน'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
    return false;
  }


  @override
  void dispose() {
    _countdownTimer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownSeconds = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาระบุอีเมลที่ถูกต้องก่อนขอรหัส OTP'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(email);

    if (mounted) {
      if (success) {
        setState(() {
          _otpSent = true;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.otpSuccessMessage ?? 'ส่งรหัส OTP 6 หลักไปยังอีเมลแล้ว'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'ขอรหัส OTP ไม่สำเร็จ'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    final consentOk = await _ensureConsent();
    if (!consentOk || !mounted) return;

    if (!_formKey.currentState!.validate()) return;

    if (!_otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากด "ขอรับรหัส OTP" เพื่อยืนยันอีเมลก่อนลงทะเบียน'),
          backgroundColor: AppTheme.secondary,
        ),
      );
      return;
    }

    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกรหัส OTP ให้ครบ 6 หลัก'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _emailController.text.trim(),
      _usernameController.text.trim(),
      _passwordController.text,
      otp,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('สมัครสมาชิกสำเร็จ! ยินดีต้อนรับ ${auth.user?.username ?? ""}'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        size: 40,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'สร้างบัญชีใหม่',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ยืนยันตัวตนด้วย Email OTP เพื่อความปลอดภัยของบัญชีคุณ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (auth.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppTheme.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้ (Username)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'กรุณาระบุชื่อผู้ใช้';
                      if (v.trim().length < 3) return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email with Send OTP Button
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'อีเมล',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: TextButton.icon(
                          onPressed: auth.isSendingOtp || _countdownSeconds > 0 ? null : _handleSendOtp,
                          icon: auth.isSendingOtp
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _otpSent ? Icons.refresh_rounded : Icons.send_rounded,
                                  size: 16,
                                ),
                          label: Text(
                            _countdownSeconds > 0
                                ? 'รอ (${_countdownSeconds}s)'
                                : (_otpSent ? 'ขอใหม่อีกครั้ง' : 'ขอรหัส OTP'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'กรุณาระบุอีเมล';
                      if (!v.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // OTP Field Section
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: _otpSent ? const EdgeInsets.all(16) : EdgeInsets.zero,
                    decoration: _otpSent
                        ? BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_otpSent) ...[
                          Row(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, size: 18, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ส่งรหัส OTP 6 หลักไปที่ ${_emailController.text.trim()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 6,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'รหัส OTP 6 หลัก',
                            hintText: '000000',
                            prefixIcon: const Icon(Icons.vpn_key_outlined),
                            counterText: '',
                            filled: _otpSent,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          validator: (v) {
                            if (!_otpSent) return null;
                            if (v == null || v.trim().isEmpty) return 'กรุณากรอกรหัส OTP 6 หลัก';
                            if (v.trim().length != 6) return 'รหัส OTP ต้องมี 6 หลัก';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'กรุณาระบุรหัสผ่าน';
                      if (v.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // PDPA & Copyright Consent Checkbox
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _consentAccepted
                          ? AppTheme.primary.withOpacity(0.06)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _consentAccepted
                            ? AppTheme.primary.withOpacity(0.3)
                            : Theme.of(context).dividerColor.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _consentAccepted,
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) async {
                              if (val == true) {
                                await _ensureConsent();
                              } else {
                                setState(() => _consentAccepted = false);
                                await LocalNovelStorage.setConsentAccepted(false);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'ฉันได้อ่านและยินยอมตาม ',
                                style: TextStyle(fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () => PdpaConsentSheet.show(
                                  context,
                                  onAccepted: () {
                                    if (mounted) setState(() => _consentAccepted = true);
                                  },
                                ),
                                child: const Text(
                                  'นโยบายคุ้มครองข้อมูลส่วนบุคคล (PDPA)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const Text(' และ ', style: TextStyle(fontSize: 12)),
                              GestureDetector(
                                onTap: () => PdpaConsentSheet.show(
                                  context,
                                  onAccepted: () {
                                    if (mounted) setState(() => _consentAccepted = true);
                                  },
                                ),
                                child: const Text(
                                  'ข้อกำหนดลิขสิทธิ์เนื้อหา',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRegister,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('ลงทะเบียนและเข้าสู่ระบบ'),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('มีบัญชีอยู่แล้ว? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'เข้าสู่ระบบที่นี่',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
