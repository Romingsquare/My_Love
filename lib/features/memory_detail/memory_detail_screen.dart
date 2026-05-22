// lib/features/memory_detail/memory_detail_screen.dart
//
// Cinematic memory detail view — reveals a preserved emotional artifact.
// Layout uses floating glass panels layered over an atmospheric gradient.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/memory_model.dart';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;

  const MemoryDetailScreen({super.key, required this.memory});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathCtrl;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memory;
    final moodColor = Color(memory.moodColorValue);

    return Scaffold(
      backgroundColor: AppColors.cosmosBlack,
      body: Stack(
        children: [
          _DetailBackground(moodColor: moodColor, breathCtrl: _breathCtrl),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _DetailAppBar(onBack: () => Navigator.pop(context)),
                ),
                SliverToBoxAdapter(child: _StatusTag(moodColor: moodColor)),
                SliverToBoxAdapter(child: _TitleSection(memory: memory)),
                if (memory.imagePath != null)
                  SliverToBoxAdapter(child: _PhotoCard(imagePath: memory.imagePath!)),
                if (memory.quote != null)
                  SliverToBoxAdapter(child: _QuoteCard(quote: memory.quote!)),
                SliverToBoxAdapter(
                  child: _DataNodeSection(memory: memory, moodColor: moodColor),
                ),
                if (memory.tags.isNotEmpty)
                  SliverToBoxAdapter(child: _TagsRow(tags: memory.tags)),
                if (memory.locationName != null)
                  SliverToBoxAdapter(child: _LocationCard(memory: memory)),
                if (memory.weather != null)
                  SliverToBoxAdapter(child: _WeatherCard(weather: memory.weather!)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail Background ───────────────────────────────────────────────────────
class _DetailBackground extends StatelessWidget {
  final Color moodColor;
  final AnimationController breathCtrl;

  const _DetailBackground({required this.moodColor, required this.breathCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breathCtrl,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cosmosBlack,
              Color.lerp(
                AppColors.deepNavy,
                moodColor.withValues(alpha: 0.08),
                breathCtrl.value,
              )!,
              const Color(0xFF061318),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      moodColor.withValues(alpha: 0.06 + 0.04 * breathCtrl.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ─────────────────────────────────────────────────────────────────
class _DetailAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _DetailAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassFill,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.glowGold,
                size: 14,
              ),
            ),
          ),
          const Spacer(),
          Text('CHRONOS ARCHIVE', style: AppTextStyles.appBarTitle),
          const Spacer(),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassFill,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.more_horiz_rounded, color: AppColors.dimGrey, size: 18),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppDurations.quick);
  }
}

// ── Status Tag ──────────────────────────────────────────────────────────────
class _StatusTag extends StatelessWidget {
  final Color moodColor;
  const _StatusTag({required this.moodColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.cosmicTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cosmicTeal.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cosmicTeal,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.6, duration: 1200.ms),
                const SizedBox(width: 8),
                Text('MEMORY RECOVERED', style: AppTextStyles.statusTag),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: AppDurations.standard);
  }
}

// ── Title Section ───────────────────────────────────────────────────────────
class _TitleSection extends StatelessWidget {
  final Memory memory;
  const _TitleSection({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(memory.title, style: AppTextStyles.displaySmall)
              .animate().fadeIn(delay: 150.ms).slideY(begin: 0.15, end: 0),
          if (memory.description != null) ...[
            const SizedBox(height: 16),
            Text(memory.description!, style: AppTextStyles.bodyMedium)
                .animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
          ],
        ],
      ),
    );
  }
}

// ── Photo Card ──────────────────────────────────────────────────────────────
class _PhotoCard extends StatelessWidget {
  final String imagePath;
  const _PhotoCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 40, 16),
      child: Transform.rotate(
        angle: -0.04,
        child: GestureDetector(
          onTap: () => _showFullImage(context),
          child: GlassCard(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05, end: 0);
  }

  void _showFullImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullImageViewer(imagePath: imagePath),
      ),
    );
  }

  Widget _buildImage() {
    // Network image (starts with http/https) - use cached version
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey.withValues(alpha: 0.2),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.grey.withValues(alpha: 0.2),
          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      );
    }
    
    // Asset image (starts with assets/)
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: 1200, // Optimize memory usage
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey.withValues(alpha: 0.2),
            child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
          );
        },
      );
    }
    
    // Local file path
    return Image.file(
      File(imagePath),
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: 1200, // Optimize memory usage
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey.withValues(alpha: 0.2),
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        );
      },
    );
  }
}

// ── Full Image Viewer ───────────────────────────────────────────────────────
class _FullImageViewer extends StatelessWidget {
  final String imagePath;
  const _FullImageViewer({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildFullImage(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullImage() {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.white)),
      );
    }
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.contain);
    }
    return Image.file(File(imagePath), fit: BoxFit.contain);
  }
}

// ── Quote Card ──────────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final String quote;
  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 20, 16),
      child: Transform.rotate(
        angle: 0.025,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote_rounded, color: AppColors.glowGold, size: 14),
                  const SizedBox(width: 6),
                  Text('NOTE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.glowGold)),
                ],
              ),
              const SizedBox(height: 10),
              Text(quote, style: AppTextStyles.quoteText),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 380.ms).slideX(begin: 0.05, end: 0);
  }
}

// ── Data Node Section ───────────────────────────────────────────────────────
class _DataNodeSection extends StatelessWidget {
  final Memory memory;
  final Color moodColor;

  const _DataNodeSection({required this.memory, required this.moodColor});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[memory.date.month - 1]} ${memory.date.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: GlassCard(
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: moodColor.withValues(alpha: 0.1),
                border: Border.all(color: moodColor.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.auto_awesome_outlined, color: moodColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(dateStr, style: AppTextStyles.monoLarge),
            const SizedBox(height: 4),
            Text('PRIMARY DATA NODE', style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 450.ms).scaleXY(begin: 0.96, end: 1.0);
  }
}

// ── Tags Row ─────────────────────────────────────────────────────────────────
class _TagsRow extends StatelessWidget {
  final List<String> tags;
  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: tags.map((t) => _TagChip(label: t)).toList(),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.glowGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glowGold.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(label, style: AppTextStyles.tagChip),
    );
  }
}

// ── Location Card ───────────────────────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  final Memory memory;
  const _LocationCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    final lat = memory.latitude;
    final lon = memory.longitude;
    final coordStr = (lat != null && lon != null)
        ? '${lat.toStringAsFixed(4)}° N, ${lon.toStringAsFixed(4)}° W'
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cosmicTeal.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.location_on_outlined, color: AppColors.cosmicTeal, size: 16),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOCATION DATA', style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.dimGrey, fontSize: 9,
                  )),
                  const SizedBox(height: 3),
                  Text(memory.locationName!, style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softWhite, fontSize: 13,
                  )),
                  if (coordStr != null) ...[
                    const SizedBox(height: 2),
                    Text(coordStr, style: AppTextStyles.coordinateText),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 550.ms);
  }
}

// ── Weather Card ─────────────────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final String weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glowGold.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.wb_sunny_outlined, color: AppColors.warmAmber, size: 16),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ATMOSPHERE', style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.dimGrey, fontSize: 9,
                )),
                const SizedBox(height: 3),
                Text(weather, style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.softWhite, fontSize: 13,
                )),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

// ── Shared Glass Card — public for reuse ─────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;

  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
