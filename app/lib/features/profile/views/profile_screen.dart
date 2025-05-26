import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/title_app.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(user?.profilePicture ?? ''),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 24),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? '',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(user?.phoneNumber ?? '',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                            onPressed: () {},
                            child: const Text('Chỉnh sửa profile'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                            ),
                            onPressed: () async {
                              await context
                                  .read<AuthProvider>()
                                  .logout(context);
                              if (context.read<AuthProvider>().user == null) {
                                context.go('/login');
                              }
                            },
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Document title
            TitleApp(title: 'Documents', context: context),
            const Divider(thickness: 1),

            // Document list
            const SizedBox(height: 8),
            _DocumentItem(
              imageUrl:
                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png',
              title: 'Cấu Trúc Dữ Liệu',
            ),
            const SizedBox(height: 16),
            _DocumentItem(
              imageUrl: null,
              title: 'Mạng Máy Tính',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget cho từng document
class _DocumentItem extends StatelessWidget {
  final String? imageUrl;
  final String title;

  const _DocumentItem({this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ảnh hoặc placeholder
        Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.image, size: 48, color: Colors.black),
        ),
        const SizedBox(width: 18),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
