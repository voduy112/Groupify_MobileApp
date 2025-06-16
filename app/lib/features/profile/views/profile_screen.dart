import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/title_app.dart';
import '../../../models/user.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import '../../../features/profile/widgets/list_document_item.dart';

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
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Trang cá nhân'),
        actions: [
          if (user.id == authUser?.id)
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
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit-profile',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Chỉnh sửa profile'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'change-password',
                  child: ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Đổi mật khẩu'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title:
                        Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Khung thông tin
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  padding: const EdgeInsets.only(
                      top: 80, left: 20, right: 20, bottom: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        user.username ?? '',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InfoRow(
                          icon: Icons.phone,
                          text: user.phoneNumber ?? 'Chưa có số điện thoại'),
                      const SizedBox(height: 8),
                      InfoRow(
                          icon: Icons.email_outlined,
                          text: user.email ?? 'Chưa có email'),
                      const SizedBox(height: 8),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        InfoRow(icon: Icons.info_outline, text: user.bio!),
                    ],
                  ),
                ),

                // Avatar cắt ngang
                Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width / 2 - 60,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
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
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            TitleApp(
                title: 'Tài liệu của ' '${user.username}', context: context),
            const Divider(
              endIndent: 16,
              indent: 16,
            ),
            ListDocumentItem(
              documents: documentShareProvider.userDocuments[user.id!] ?? [],
              userId: user.id!,
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
  const InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
