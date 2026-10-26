import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/board_photo.dart';
import '../../widgets/ai_flashcards_modal.dart';

class BoardViewerScreen extends ConsumerWidget {
  final String photoId;

  const BoardViewerScreen({super.key, required this.photoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final photosAsync = ref.watch(boardPhotosProvider);
    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6366F1)),
            tooltip: isSi ? 'AI අධ්‍යයන ෆ්ලෑෂ්කාඩ්' : 'AI Flashcards',
            onPressed: () {
              final photos = photosAsync.value ?? [];
              final photo = photos.firstWhere(
                (p) => p.id == photoId,
                orElse: () => photos.first,
              );
              final modules = modulesAsync.value ?? [];
              final mod = modules.firstWhere(
                (m) => m.id == photo.moduleId,
                orElse: () => modules.first,
              );

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AiFlashcardsModal(
                  moduleCode: mod.code,
                  note: photo.note,
                  isSi: isSi,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: isSi ? 'සටහන සංස්කරණය' : 'Edit note',
            onPressed: () => _editNoteDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.alertRed),
            tooltip: isSi ? 'ඉවත් කරන්න' : 'Delete photo',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: photosAsync.when(
        data: (photos) {
          final photo = photos.firstWhere(
            (p) => p.id == photoId,
            orElse: () => throw Exception('Photo not found'),
          );

          final modules = modulesAsync.value ?? [];
          final mod = modules.firstWhere(
            (m) => m.id == photo.moduleId,
            orElse: () => modules.first,
          );

          final file = File(photo.filePath);
          final exists = file.existsSync();

          return Stack(
            children: [
              // Zoomable Image
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: exists
                      ? Image.file(
                          file,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text('Failed to load image', style: TextStyle(color: Colors.white70)),
                          ),
                        )
                      : const Center(
                          child: Text('Image file not found on device', style: TextStyle(color: Colors.white70)),
                        ),
                ),
              ),

              // Bottom Details Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.campusOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mod.code,
                              style: const TextStyle(
                                color: AppColors.deepNavy,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            photo.lectureDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (photo.note != null && photo.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          photo.note!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AiFlashcardsModal(
                              moduleCode: mod.code,
                              note: photo.note,
                              isSi: isSi,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF6366F1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF818CF8), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                isSi ? 'AI අධ්‍යයන ෆ්ලෑෂ්කාඩ් බලන්න' : 'Generate AI Flashcards & Review',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  void _editNoteDialog(BuildContext context, WidgetRef ref) {
    final photos = ref.read(boardPhotosProvider).value ?? [];
    final photo = photos.firstWhere((p) => p.id == photoId);
    final controller = TextEditingController(text: photo.note ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Add note or slide description',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.campusOrange, foregroundColor: AppColors.deepNavy),
            onPressed: () async {
              await ref.read(boardPhotosProvider.notifier).updateNote(photoId, controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Board Photo?'),
        content: const Text('Are you sure you want to permanently delete this photo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final photos = ref.read(boardPhotosProvider).value ?? [];
      final photo = photos.firstWhere((p) => p.id == photoId);
      final file = File(photo.filePath);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      await ref.read(boardPhotosProvider.notifier).deletePhoto(photoId);

      if (context.mounted) {
        context.pop();
      }
    }
  }
}
