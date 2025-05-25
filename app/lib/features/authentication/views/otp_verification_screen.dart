import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validate.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final bool autoResend;
  const OTPVerificationScreen(
      {Key? key, required this.email, this.autoResend = false})
      : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _secondsRemaining = 300; // 5 phút

  @override
  void initState() {
    super.initState();
    _startTimer();
    if (widget.autoResend) {
      Future.delayed(Duration.zero, () => _resendOTP());
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _verifyOTP() async {
    // TODO: Gọi API xác thực OTP ở đây
    final otp = _otpController.text.trim();
    final email = widget.email;
    // Gửi email và otp lên server để xác thực
    // Hiển thị thông báo thành công/thất bại
    final success = await context.read<AuthProvider>().verifyOTP(email, otp);
    print("success: $success");
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực thành công!')),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP không hợp lệ!')),
      );
    }
  }

  void _resendOTP() async {
    // TODO: Gọi API gửi lại OTP ở đây
    // Sau khi gửi lại thành công, reset lại thời gian đếm ngược
    setState(() {
      _secondsRemaining = 300;
    });
    _startTimer();
    final success = await context.read<AuthProvider>().resendOTP(widget.email);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại mã OTP!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi lại OTP thất bại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nhập mã OTP đã gửi tới email:',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(widget.email,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã OTP',
                  border: OutlineInputBorder(),
                ),
                validator: Validate.otp,
                maxLength: 6,
              ),
              const SizedBox(height: 16),
              Text('Thời gian còn lại: ${_formatTime(_secondsRemaining)}',
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _secondsRemaining > 0 ? _verifyOTP : null,
                  child: const Text('Xác nhận'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _secondsRemaining <= 240 ? _resendOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Gửi lại OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
