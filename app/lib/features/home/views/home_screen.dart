import 'package:app/features/document_share/providers/document_share_provider.dart';
import 'package:app/features/home/widgets/list_group_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Carousel_view.dart';
import '../../authentication/providers/auth_provider.dart';
import '../widgets/list_document_item.dart';
import '../../../core/widgets/title_app.dart';
import '../widgets/list_group_item.dart';
import '../../group_study/providers/group_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ'),
      ),
      body: Column(
        children: [
          MyCarouselView(),
          SizedBox(height: 10),
          TitleApp(title: 'Tài liệu', context: context),
          ListDocumentItem(),
          Center(
            child: ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () {
                context.go('/home/show-all-document');
              },
              child: Text(
                'Xem thêm',
              ),
            ),
          ),
          TitleApp(title: 'Nhóm', context: context),
          SizedBox(height: 10),
          ListGroupItem(
            groups: groupProvider.groups.take(5).toList(),
            from: 'home',
          ),
          Center(
            child: ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () {
                context.go('/home/show-all-group');
              },
              child: Text(
                'Xem thêm',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/home/upload-document');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
