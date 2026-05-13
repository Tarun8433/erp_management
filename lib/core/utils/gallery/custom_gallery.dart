import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:erp_management/core/constants/app_colors.dart';

class CustomGalleryPage extends StatefulWidget {
  const CustomGalleryPage({super.key});

  @override
  State<CustomGalleryPage> createState() => _CustomGalleryPageState();
}

class _CustomGalleryPageState extends State<CustomGalleryPage>
    with WidgetsBindingObserver {
  List<AssetEntity> _assets = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchAssets();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchAssets();
    }
  }

  Future<void> _fetchAssets() async {
    // Request permission
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    // Check for both full access (isAuth) and limited access (hasAccess)
    // On Android 13+, users can grant limited photo access
    if (!ps.hasAccess) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
      return;
    }

    // Fetch albums (we just want the "Recent" or all photos for now)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _isLoading = false;
        });
      }
      return;
    }

    // Get assets from the first album (usually "Recent")
    // Paging: load first 80 images
    final List<AssetEntity> recentAssets = await albums[0].getAssetListPaged(
      page: 0,
      size: 80,
    );

    if (mounted) {
      setState(() {
        _assets = recentAssets;
        _hasPermission = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gallery',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(
              color: Get.isDarkMode ? Colors.white : Colors.black,
              height: 1,
            ),
            // Body
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Permission denied.\nPlease enable access in settings.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Get.isDarkMode ? Colors.white70 : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => PhotoManager.openSetting(),
              child: const Text('Open Settings'),
            ),
            TextButton(onPressed: _fetchAssets, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_assets.isEmpty) {
      return Center(
        child: Text(
          'No photos found',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Get.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return _AssetThumbnail(
          asset: asset,
          onTap: () async {
            final f = await asset.file;
            if (f != null && context.mounted) {
              Navigator.of(context).pop(f);
            }
          },
        );
      },
    );
  }
}

class _AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onTap;

  const _AssetThumbnail({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Uint8List?>(
        future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          return Container(color: Colors.grey[900]);
        },
      ),
    );
  }
}

// Helper to open the gallery easily
class CustomGalleryService {
  static Future<File?> open(BuildContext context) async {
    return await showModalBottomSheet<File>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomGalleryPage(),
    );
  }
}
