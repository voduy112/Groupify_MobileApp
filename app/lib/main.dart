import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thông tin người dùng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Thông tin người dùng'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> users = [
    {
      "_id": "6821ba4799c95c51f054d5b7",
      "username": "VÕ ĐỨC DUY",
      "email": "duy@gmail.com",
      "phoneNumber": "0794252222",
      "profilePicture": "default.jpg",
      "bio": "",
      "createdAt": "2025-05-12T07:50:31.449+00:00",
      "updatedAt": "2025-05-12T07:50:31.449+00:00"
    },
    {
      "_id": "6821ba4799c95c51f054d5b8",
      "username": "NGUYỄN TRÚC SƯƠNG",
      "email": "suong@gmail.com",
      "phoneNumber": "0909123456",
      "profilePicture": "default.jpg",
      "bio": "Yêu thích sách.",
      "createdAt": "2025-05-10T09:30:00.000+00:00",
      "updatedAt": "2025-05-12T09:00:00.000+00:00"
    },
  ];

  int selectedUserIndex = 0;

  final fieldLabels = {
    "_id": "ID",
    "username": "Tên người dùng",
    "email": "Email",
    "phoneNumber": "Số điện thoại",
    "bio": "Tiểu sử",
    "createdAt": "Tạo lúc",
    "updatedAt": "Cập nhật lúc"
  };

  IconData getIconForKey(String key) {
    switch (key) {
      case "email":
        return Icons.email;
      case "phoneNumber":
        return Icons.phone;
      case "bio":
        return Icons.info_outline;
      case "createdAt":
        return Icons.calendar_today;
      case "updatedAt":
        return Icons.update;
      case "_id":
        return Icons.perm_identity;
      default:
        return Icons.info;
    }
  }

  String formatDate(String input) {
    try {
      final date = DateTime.parse(input);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return input;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = users[selectedUserIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/${user["profilePicture"]}'),
          ),
          const SizedBox(height: 8),
          Text(
            user['username'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: user.entries.map((entry) {
                          final key = entry.key;
                          if (key == "profilePicture" || key == "username") {
                            return const SizedBox.shrink();
                          }
                          final label = fieldLabels[key] ?? key;
                          String value = entry.value.toString();
                          if (value.isEmpty) value = "Chưa cập nhật";
                          if (key == "createdAt" || key == "updatedAt") {
                            value = formatDate(value);
                          }

                          return Column(
                            children: [
                              ListTile(
                                leading: Icon(getIconForKey(key),
                                    color: Colors.deepPurple),
                                title: Text(label),
                                subtitle: Text(value),
                              ),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(thickness: 1.5),
                ),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      final isSelected = index == selectedUserIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedUserIndex = index;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey.shade400,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    AssetImage('assets/${u["profilePicture"]}'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 80,
                              child: Text(
                                u["username"],
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
