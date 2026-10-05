import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../constants/app_colors.dart';

class PdfViewerPage extends StatelessWidget {
  final String? url;
  final String? assetPath;
  final String title;

  const PdfViewerPage({super.key, this.url, this.assetPath, required this.title})
      : assert(url != null || assetPath != null, 'Vous devez fournir soit une URL, soit un assetPath.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: url != null
          ? PdfViewer.uri(
              Uri.parse(url!),
              params: _buildParams(),
            )
          : PdfViewer.asset(
              assetPath!,
              params: _buildParams(),
            ),
    );
  }

  PdfViewerParams _buildParams() {
    return PdfViewerParams(
      backgroundColor: AppColors.background,
      loadingBannerBuilder: (context, bytesLoaded, totalBytes) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text("Chargement du cours...", style: TextStyle(color: AppColors.slate500)),
          ],
        ),
      ),
      errorBannerBuilder: (context, error, stackTrace, documentRef) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 60),
              const SizedBox(height: 16),
              Text(
                "Erreur de chargement : $error",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.slate500, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
