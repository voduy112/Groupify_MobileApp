import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DocumentListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 18,
                    width: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupGridShimmer extends StatelessWidget {
  const GroupGridShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3 * 160, // 3 hàng, mỗi item cao 160
      child: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(), // Không cho scroll riêng grid này
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cột
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 170 / 160, // width/height của item
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar shimmer
                Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(top: 16, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                // Name shimmer
                Container(
                  height: 18,
                  width: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                // Subject shimmer
                Container(
                  height: 14,
                  width: 50,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GroupListShimmer extends StatelessWidget {
  const GroupListShimmer({Key? key, this.itemCount = 6}) : super(key: key);

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
