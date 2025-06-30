import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/title_app.dart';
import '../../../models/user.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import '../../../features/profile/widgets/list_document_item.dart';
import '../../../core/widgets/custom_appbar.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthProvider>().user;
    final user = widget.user ?? authUser;
    if (user != null) {
      Future.microtask(() {
        Provider.of<DocumentShareProvider>(context, listen: false)
            .fetchDocumentsByUserId(user.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().user;
    final user = widget.user ?? authUser;
    final documentShareProvider = context.watch<DocumentShareProvider>();

    if (user == null) {
      Future.microtask(() => context.go('/login'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Nền gradient xanh có bo góc dưới
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0072ff),
                    Color.fromARGB(255, 92, 184, 241),
                    Color(0xFF81D4FA),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(
                  top: 40, left: 24, right: 24, bottom: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trang cá nhân',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit-profile') {
                            context.go('/profile/edit', extra: user);
                          } else if (value == 'change-password') {
                            context.go('/profile/change-password');
                          } else if (value == 'logout') {
                            await context.read<AuthProvider>().logout(context);
                            if (context.read<AuthProvider>().user == null) {
                              context.go('/login');
                            }
                          }
                        },
                        icon: const Icon(Icons.settings, color: Colors.white),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit-profile',
                            child: Text('Chỉnh sửa hồ sơ'),
                          ),
                          PopupMenuItem(
                            value: 'change-password',
                            child: Text('Đổi mật khẩu'),
                          ),
                          PopupMenuItem(
                            value: 'logout',
                            child: Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(2), // độ dày viền
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Màu viền (ví dụ: trắng)
                        width: 2, // Độ dày viền
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: user.profilePicture != null &&
                              user.profilePicture!.isNotEmpty
                          ? NetworkImage(user.profilePicture!)
                          : null,
                      child: user.profilePicture == null ||
                              user.profilePicture!.isEmpty
                          ? Text(
                              user.username?.isNotEmpty == true
                                  ? user.username![0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.username ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Thông tin cá nhân',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    icon: Icons.phone_android,
                    text: user.phoneNumber ?? 'Chưa có số điện thoại',
                    fontSize: 15,
                    iconColor: Colors.white,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  InfoRow(
                    icon: Icons.email_outlined,
                    text: user.email ?? 'Chưa có email',
                    fontSize: 15,
                    iconColor: Colors.white,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    InfoRow(
                      icon: Icons.info_outline,
                      text: user.bio!,
                      fontSize: 15,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                    ),
                ],
              ),
            ),

            // Phần nội dung tài liệu (màu trắng)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tài liệu của ${user.username}:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  ListDocumentItem(
                    documents:
                        documentShareProvider.userDocuments[user.id!] ?? [],
                    userId: user.id!,
                    currentUserId: authUser?.id ?? '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double fontSize;
  final Color? iconColor;
  final Color? textColor;

  const InfoRow({
    required this.icon,
    required this.text,
    this.fontSize = 15,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor ?? Colors.blueGrey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor ?? Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
