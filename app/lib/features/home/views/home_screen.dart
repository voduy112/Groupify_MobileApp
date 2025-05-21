import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Carousel_view.dart';
import '../../authentication/providers/auth_provider.dart';
import '../widgets/list_document_item.dart';
import '../../../core/widgets/title_app.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          MyCarouselView(),
          SizedBox(height: 10),
          TitleApp(title: 'Documents', context: context),
          ListDocumentItem(),
          Center(
            child: ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: () {},
              child: Text(
                'More',
              ),
            ),
          ),
          TitleApp(title: 'Groups', context: context),
          ListDocumentItem(),
          SizedBox(height: 10),
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
