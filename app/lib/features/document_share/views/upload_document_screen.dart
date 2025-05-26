import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadDocumentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text('Tiêu đề', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Mô tả
            Text('Mô tả', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Tên môn
            Text('Tên môn', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 36),

            // Icon + Upload button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file, size: 40),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Text('Upload',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
