import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/celebration_particles.dart';
import 'success_badge.dart';

/// Centerpiece Hero Shuffle area:
/// Large centered rounded tile, floating gold crown on a breathing pedestal,
/// celebratory sparkles and burst, prominent title, and subtitle.
class HeroShuffleCard extends StatefulWidget {
  const HeroShuffleCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.statusText = 'Shuffle Complete!',
    this.isShuffling = false,
    this.iconSpinController,
  });

  final String title;
  final String subtitle;
  final String statusText;
  final bool isShuffling;
  final AnimationController? iconSpinController;

  @override
  State<HeroShuffleCard> createState() => _HeroShuffleCardState();
}

class _HeroShuffleCardState extends State<HeroShuffleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HeroShuffleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isShuffling && !widget.isShuffling) {
      setState(() {
        _showCelebration = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Hero Icon Stack (Pedestal, Glow, Sparkles, Tile, Crown) ──
        CelebrationParticles(
          isPlaying: _showCelebration,
          child: SizedBox(
            width: 220,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Pedestal with Breathing Depth
                Positioned(
                  bottom: 12,
                  child: AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final floatVal =
                          reduceMotion ? 0.5 : _floatController.value;
                      final pedestalSpread = 6.0 + (floatVal * 4.0);

                      return Container(
                        width: 140,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.elliptical(140, 32),
                          ),
                          color: isDark
                              ? const Color(0xFF1F2922)
                              : PremiumDesignTokens.pedestal,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? PremiumDesignTokens.mossDark
                                      : const Color(0xFF2E583F))
                                  .withValues(alpha: 0.12 + (floatVal * 0.05)),
                              blurRadius: 24 + (floatVal * 8),
                              spreadRadius: pedestalSpread,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 2. Subtle Celebratory Sparkles / Decorative Accents
                Positioned(
                  top: 26,
                  left: 24,
                  child: _buildSparkleDot(
                    size: 7,
                    color: PremiumDesignTokens.gold.withValues(alpha: 0.8),
                  ),
                ),
                Positioned(
                  top: 48,
                  left: 14,
                  child: _buildSparkleStar(
                    size: 14,
                    color: PremiumDesignTokens.gold.withValues(alpha: 0.65),
                  ),
                ),
                Positioned(
                  top: 22,
                  right: 32,
                  child: _buildSparkleStar(
                    size: 16,
                    color: PremiumDesignTokens.gold.withValues(alpha: 0.85),
                  ),
                ),
                Positioned(
                  top: 56,
                  right: 18,
                  child: _buildSparkleDot(
                    size: 6,
                    color: PremiumDesignTokens.sageMedium.withValues(alpha: 0.7),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  right: 36,
                  child: _buildSparkleDot(
                    size: 5,
                    color: PremiumDesignTokens.peachAccent.withValues(alpha: 0.65),
                  ),
                ),
                Positioned(
                  bottom: 22,
                  left: 32,
                  child: _buildSparkleDot(
                    size: 6,
                    color: PremiumDesignTokens.sageMedium.withValues(alpha: 0.6),
                  ),
                ),

                // 3. Rounded Brand Shuffle Tile
                Positioned(
                  bottom: 20,
                  child: AnimatedBuilder(
                    animation: widget.iconSpinController ?? _floatController,
                    builder: (context, child) {
                      double rotation = 0;
                      double scale = 1.0;

                      if (widget.iconSpinController != null &&
                          widget.isShuffling) {
                        final val = widget.iconSpinController!.value;
                        rotation = val * 4 * pi;
                        scale = 1.0 + sin(val * 3 * pi) * 0.12;
                      }

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateZ(rotation)
                          ..scaleByDouble(scale, scale, 1.0, 1.0),
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E3A2B), // Forest Moss
                                Color(0xFF2C553C), // Muted Olive
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                PremiumDesignTokens.radiusHero),
                            border: Border.all(
                              color: const Color(0xFF497558),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: PremiumDesignTokens.mossDark
                                    .withValues(alpha: 0.35),
                                blurRadius: widget.isShuffling ? 32 : 24,
                                spreadRadius: widget.isShuffling ? 6 : 2,
                                offset: const Offset(0, 8),
                              ),
                              const BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shuffle_rounded,
                              size: 46,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 4. Floating Gold Crown Mark
                Positioned(
                  top: 6,
                  child: AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final floatY = reduceMotion
                          ? 0.0
                          : sin(_floatController.value * 2 * pi) * 3.5;

                      return Transform.translate(
                        offset: Offset(0, floatY),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF332710)
                                : const Color(0xFFFBF2DC),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PremiumDesignTokens.gold,
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: PremiumDesignTokens.gold
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            size: 18,
                            color: PremiumDesignTokens.gold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Large Title Block ──
        AnimatedSwitcher(
          duration: PremiumDesignTokens.durationTransition,
          switchInCurve: PremiumDesignTokens.easeOutCubic,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            widget.title,
            key: ValueKey('hero_title_${widget.title}'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 27,
              letterSpacing: -0.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // ── Subtitle Block ──
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),

        const SizedBox(height: 16),

        // ── Success Confirmation Pill ──
        AnimatedSwitcher(
          duration: PremiumDesignTokens.durationEntrance,
          switchInCurve: PremiumDesignTokens.easeOutCubic,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: widget.isShuffling
              ? Container(
                  key: const ValueKey('hero_shuffling_pill'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF222F26)
                        : PremiumDesignTokens.sageLight,
                    borderRadius: BorderRadius.circular(
                        PremiumDesignTokens.radiusPill),
                    border: Border.all(
                      color: PremiumDesignTokens.sageBorder,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PremiumDesignTokens.sageText,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Randomizing with Fisher-Yates...',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: PremiumDesignTokens.sageText,
                        ),
                      ),
                    ],
                  ),
                )
              : SuccessBadge(
                  key: const ValueKey('hero_success_pill'),
                  label: widget.statusText,
                ),
        ),
      ],
    );
  }

  Widget _buildSparkleDot({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSparkleStar({required double size, required Color color}) {
    return Icon(
      Icons.auto_awesome,
      size: size,
      color: color,
    );
  }
}
