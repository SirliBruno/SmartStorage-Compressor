import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/video_asset.dart';

/// Interactive vertical split-screen video comparison widget.
/// Renders two synchronized hardware-accelerated video players with zero extra CPU overhead
/// via real-time GPU surface clipping (ClipRect).
class VideoComparisonSlider extends StatefulWidget {
  final String originalPath;
  final String compressedPath;
  final VideoAsset originalAsset;
  final double initialSplitPercent;

  const VideoComparisonSlider({
    super.key,
    required this.originalPath,
    required this.compressedPath,
    required this.originalAsset,
    this.initialSplitPercent = 0.5,
  });

  @override
  State<VideoComparisonSlider> createState() => _VideoComparisonSliderState();
}

class _VideoComparisonSliderState extends State<VideoComparisonSlider> {
  VideoPlayerController? _originalController;
  VideoPlayerController? _compressedController;

  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;

  double _splitPercent = 0.5; // 0.0 to 1.0
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _splitPercent = widget.initialSplitPercent.clamp(0.05, 0.95);
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final originalFile = File(widget.originalPath.isNotEmpty ? widget.originalPath : widget.originalAsset.path);
      final compressedFile = File(widget.compressedPath);

      if (!await compressedFile.exists()) {
        throw Exception('Compressed video file does not exist at ${widget.compressedPath}');
      }

      _originalController = VideoPlayerController.file(originalFile);
      _compressedController = VideoPlayerController.file(compressedFile);

      await Future.wait([
        _originalController!.initialize(),
        _compressedController!.initialize(),
      ]);

      // Mute compressed video to prevent dual-audio phase cancellation/echo
      await _compressedController!.setVolume(0.0);

      // Safe common duration is the minimum of both to prevent seek overruns
      final origDur = _originalController!.value.duration;
      final compDur = _compressedController!.value.duration;
      _totalDuration = origDur < compDur ? origDur : compDur;

      if (_totalDuration == Duration.zero) {
        _totalDuration = widget.originalAsset.duration;
      }

      _originalController!.addListener(_onPlaybackUpdate);

      // Start periodic synchronization watchdog (150ms drift tolerance)
      _syncTimer = Timer.periodic(const Duration(milliseconds: 300), (_) => _syncWatchdog());

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Failed initializing comparison video controllers: $e', e, stack);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onPlaybackUpdate() {
    if (!mounted || _originalController == null) return;
    final current = _originalController!.value.position;
    final isPlaying = _originalController!.value.isPlaying;

    if (_isPlaying != isPlaying || (_position.inSeconds != current.inSeconds)) {
      setState(() {
        _isPlaying = isPlaying;
        _position = current;
      });
    }

    // Auto-pause at end of playback
    if (current >= _totalDuration && _isPlaying) {
      _togglePlayPause();
    }
  }

  /// Watchdog that aligns both video players if hardware frame drift exceeds 150ms.
  void _syncWatchdog() {
    if (!mounted || !_isInitialized || !_isPlaying) return;
    final pos1 = _originalController?.value.position;
    final pos2 = _compressedController?.value.position;

    if (pos1 != null && pos2 != null) {
      final driftMs = (pos1.inMilliseconds - pos2.inMilliseconds).abs();
      if (driftMs > 150) {
        _compressedController?.seekTo(pos1);
      }
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _originalController == null || _compressedController == null) return;

    setState(() {
      if (_isPlaying) {
        _originalController!.pause();
        _compressedController!.pause();
        _isPlaying = false;
      } else {
        if (_position >= _totalDuration) {
          _originalController!.seekTo(Duration.zero);
          _compressedController!.seekTo(Duration.zero);
        }
        _originalController!.play();
        _compressedController!.play();
        _isPlaying = true;
      }
    });
  }

  void _onSeek(double valueMs) {
    if (!_isInitialized || _originalController == null || _compressedController == null) return;
    final target = Duration(milliseconds: valueMs.toInt());
    final safeTarget = target > _totalDuration ? _totalDuration : target;

    _originalController!.seekTo(safeTarget);
    _compressedController!.seekTo(safeTarget);

    setState(() {
      _position = safeTarget;
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _originalController?.removeListener(_onPlaybackUpdate);
    _originalController?.dispose();
    _compressedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.accentCyan),
              SizedBox(height: 16),
              Text(
                'Loading comparison preview...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 44),
              const SizedBox(height: 12),
              const Text(
                'Unable to load comparison video.',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: _initializeControllers,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retryPermission),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Video Viewport with Split-Screen Slider
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 340,
            width: double.infinity,
            color: Colors.black,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final splitX = width * _splitPercent;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Layer 1: Original Video (Full Background)
                    if (_originalController != null && _originalController!.value.isInitialized)
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _originalController!.value.size.width,
                            height: _originalController!.value.size.height,
                            child: VideoPlayer(_originalController!),
                          ),
                        ),
                      ),

                    // Layer 2: Compressed Video (Clipped to right of split line)
                    if (_compressedController != null && _compressedController!.value.isInitialized)
                      ClipRect(
                        clipper: _VerticalSplitClipper(splitX: splitX),
                        child: SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: _compressedController!.value.size.width,
                              height: _compressedController!.value.size.height,
                              child: VideoPlayer(_compressedController!),
                            ),
                          ),
                        ),
                      ),

                    // Layer 3: Vertical Divider Line & Draggable Touch Handle
                    Positioned(
                      left: splitX - 24, // 48pt wide hit test area
                      top: 0,
                      bottom: 0,
                      width: 48,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            final newX = (splitX + details.delta.dx).clamp(24.0, width - 24.0);
                            _splitPercent = (newX / width).clamp(0.05, 0.95);
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Divider bar
                            Container(
                              width: 2.5,
                              color: AppColors.accentCyan,
                            ),
                            // Handle Thumb
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.accentCyan, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.compare_arrows_rounded,
                                color: AppColors.accentCyan,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Layer 4: Floating Badges (Original & Compressed)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildLabelBadge(l10n.original, isOriginal: true),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildLabelBadge(l10n.compressed, isOriginal: false),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Playback Controls Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Play/Pause Button
              IconButton(
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: AppColors.accentCyan,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 8),

              // Time Position / Total Duration
              Text(
                _formatDuration(_position),
                style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
              ),

              // Scrubber Seekbar
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: AppColors.accentCyan,
                    inactiveTrackColor: AppColors.surfaceElevated,
                    thumbColor: AppColors.accentCyan,
                  ),
                  child: Slider(
                    value: _position.inMilliseconds
                        .toDouble()
                        .clamp(0.0, _totalDuration.inMilliseconds.toDouble()),
                    max: _totalDuration.inMilliseconds.toDouble() > 0
                        ? _totalDuration.inMilliseconds.toDouble()
                        : 1.0,
                    onChanged: _onSeek,
                  ),
                ),
              ),

              Text(
                _formatDuration(_totalDuration),
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabelBadge(String text, {required bool isOriginal}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOriginal ? AppColors.border : AppColors.accentCyan.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isOriginal ? AppColors.textPrimary : AppColors.accentCyan,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

/// Custom clipper that clips anything to the right of [splitX].
class _VerticalSplitClipper extends CustomClipper<Rect> {
  final double splitX;

  const _VerticalSplitClipper({required this.splitX});

  @override
  Rect getClip(Size size) {
    // Shows the region from splitX to the right edge of viewport
    return Rect.fromLTRB(splitX, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant _VerticalSplitClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}
