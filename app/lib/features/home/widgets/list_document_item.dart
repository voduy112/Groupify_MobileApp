import 'package:flutter/material.dart';

class ListDocumentItem extends StatelessWidget {
  const ListDocumentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://images2.thanhnien.vn/zoom/700_438/528068263637045248/2024/1/26/e093e9cfc9027d6a142358d24d2ee350-65a11ac2af785880-17061562929701875684912-37-0-587-880-crop-1706239860681642023140.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Title document',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    ));
  }
}
