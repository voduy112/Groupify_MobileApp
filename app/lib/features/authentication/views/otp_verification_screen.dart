import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/validate.dart';
import '../../../core/widgets/custom_appbar.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final bool autoResend;
  final void Function()?
      onSuccess; // ✅ Callback sau khi xác thực OTP thành công

  const OTPVerificationScreen({
    Key? key,
    required this.email,
    this.autoResend = false,
    this.onSuccess,
  }) : super(key: key);

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
    final otp = _otpController.text.trim();
    final email = widget.email;
    final success = await context.read<AuthProvider>().verifyOTP(email, otp);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực thành công!')),
      );

      // Nếu có callback thì gọi
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        //Mặc định dùng cho quên mật khẩu
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP không hợp lệ!')),
      );
    }
  }

  void _resendOTP() async {
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
    final defaultPinTheme = PinTheme(
      width: 70,
      height: 70,
      textStyle: const TextStyle(
          fontSize: 30,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      appBar: CustomAppBar(title: 'Xác thực OTP', showBack: false),
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
              Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                validator: Validate.otp,
                onCompleted: (pin) => _secondsRemaining > 0
                    ? _verifyOTP()
                    : ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Thời gian hết, vui lòng gửi lại OTP')),
                      ),
              ),
              const SizedBox(height: 16),
              Text('Thời gian còn lại: ${_formatTime(_secondsRemaining)}',
                  style: const TextStyle(color: Colors.red, fontSize: 20)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _secondsRemaining <= 240 ? _resendOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0072ff),
                  ),
                  child: const Text('Gửi lại OTP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
