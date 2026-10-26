import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/models/board_photo.dart';
import '../../widgets/primary_button.dart';

class BoardGalleryScreen extends ConsumerStatefulWidget {
  const BoardGalleryScreen({super.key});

  @override
  ConsumerState<BoardGalleryScreen> createState() => _BoardGalleryScreenState();
}

class _BoardGalleryScreenState extends ConsumerState<BoardGalleryScreen> {
  String? _selectedFolderModuleId; // null = all

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);
    final photosAsync = ref.watch(boardPhotosProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSi ? 'දේශන සටහන් ඡායාරූප' : 'Board Snap gallery',
                        style: TextStyle(
                          fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_rounded, color: AppColors.campusOrange),
                        onPressed: () => context.push('/boards/capture'),
                        tooltip: isSi ? 'ඡායාරූපයක් ගන්න' : 'Capture board',
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isSi
                        ? 'දේශන ශාලාවේ කළු ලෑලි සහ විනිවිදක සටහන් විෂයය අනුව සංවිධානය කර ඇත'
                        : 'Offline lecture photos organized by module folders',
                    style: TextStyle(
                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                      fontSize: 13,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Module Folders Horizontal Strip
            modulesAsync.when(
              data: (modules) {
                final photos = photosAsync.value ?? [];
                return SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: modules.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      if (idx == 0) {
                        final isSel = _selectedFolderModuleId == null;
                        return ChoiceChip(
                          label: Text('${isSi ? "සියල්ල" : "All photos"} (${photos.length})'),
                          selected: isSel,
                          selectedColor: AppColors.campusOrange,
                          labelStyle: TextStyle(
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.deepNavy : (isDark ? AppColors.textDarkHigh : AppColors.ink),
                          ),
                          onSelected: (_) => setState(() => _selectedFolderModuleId = null),
                        );
                      }
                      final mod = modules[idx - 1];
                      final count = photos.where((p) => p.moduleId == mod.id).length;
                      final isSel = _selectedFolderModuleId == mod.id;

                      return ChoiceChip(
                        label: Text('${mod.code} ($count)'),
                        selected: isSel,
                        selectedColor: AppColors.campusOrange,
                        labelStyle: TextStyle(
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? AppColors.deepNavy : (isDark ? AppColors.textDarkHigh : AppColors.ink),
                        ),
                        onSelected: (_) => setState(() => _selectedFolderModuleId = mod.id),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // Grid of Photos
            Expanded(
              child: photosAsync.when(
                data: (allPhotos) {
                  final photos = _selectedFolderModuleId == null
                      ? allPhotos
                      : allPhotos.where((p) => p.moduleId == _selectedFolderModuleId).toList();

                  if (photos.isEmpty) {
                    return _buildEmptyState(isDark, isSi);
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, idx) {
                      final photo = photos[idx];
                      return _buildPhotoCard(photo, isDark, isSi);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),

            // Bottom Capture Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: isSi ? '+ ඡායාරූපයක් ගන්න' : '+ Capture a board',
                icon: Icons.camera_alt_rounded,
                onPressed: () => context.push('/boards/capture'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BoardPhoto photo, bool isDark, bool isSi) {
    final file = File(photo.filePath);
    final exists = file.existsSync();

    return InkWell(
      onTap: () => context.push('/boards/viewer/${photo.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDarkElevated : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: exists
                  ? Image.file(
                      file,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.lectureDate,
                    style: TextStyle(
                      fontFamily: AppTypography.interFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                    ),
                  ),
                  if (photo.note != null && photo.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      photo.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.interFont,
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFE5E9F2),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 36, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSi) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDarkElevated : Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_library_rounded, size: 48, color: AppColors.campusOrange),
            ),
            const SizedBox(height: 16),
            Text(
              isSi ? 'ඡායාරූප හමු නොවීය' : 'No board photos yet',
              style: TextStyle(
                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSi
                  ? 'දේශන අතරතුර කළු ලෑලි සහ විනිවිදක ඡායාරූප ගෙන සුරක්ෂිතව තබා ගන්න.'
                  : 'Capture lecture boards directly from your classes to study later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                fontSize: 13,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
