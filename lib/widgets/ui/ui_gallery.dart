import 'package:flutter/material.dart';

import 'ui.dart';

/// Visual catalogue of the Fade component library. NOT wired into routes.
/// To preview, temporarily point `home:` at `const FadeUiGallery()` or push it
/// from a debug menu.
class FadeUiGallery extends StatefulWidget {
  const FadeUiGallery({super.key});

  @override
  State<FadeUiGallery> createState() => _FadeUiGalleryState();
}

class _FadeUiGalleryState extends State<FadeUiGallery> {
  bool _dark = true;
  bool _saving = false;
  final Set<String> _days = {'Tue', 'Wed', 'Thu', 'Fri', 'Sat'};

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? FadeTheme.dark() : FadeTheme.light(),
      child: Builder(
        builder: (context) {
          final c = context.fadeColors;
          return Scaffold(
            appBar: AppBar(
              title: const FadeWordmark(height: 18),
              actions: [
                FadeIconButton(
                  icon: _dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  tooltip: _dark ? 'Light mode' : 'Dark mode',
                  onPressed: () => setState(() => _dark = !_dark),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: FadeSpace.s48),
              children: [
                const FadeSectionHeader(title: 'Brand'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: FadeSpace.gutter),
                  child: Row(
                    children: [
                      FadeAppBadge(size: 56),
                      SizedBox(width: FadeSpace.s12),
                      FadeAppBadge(size: 56, inverted: true),
                      SizedBox(width: FadeSpace.s16),
                      FadeLogomark(height: 40),
                    ],
                  ),
                ),
                const FadeSectionHeader(title: 'Type'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FadeSpace.gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your chair. Your book.',
                        style: FadeType.h1.copyWith(color: c.textPrimary),
                      ),
                      Text(
                        'Section title',
                        style: FadeType.h2.copyWith(color: c.textPrimary),
                      ),
                      Text(
                        'Card title',
                        style: FadeType.h3.copyWith(color: c.textPrimary),
                      ),
                      Text(
                        'Row title',
                        style: FadeType.title.copyWith(color: c.textPrimary),
                      ),
                      Text(
                        'Body copy for barbers, clear and direct.',
                        style: FadeType.body.copyWith(color: c.textPrimary),
                      ),
                      Text(
                        'Supporting copy',
                        style: FadeType.bodySm.copyWith(color: c.textSecondary),
                      ),
                      Text(
                        'THIS WEEK',
                        style: FadeType.overline.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                      Text(
                        '\$1,240.00',
                        style: FadeType.moneyLg.copyWith(color: c.textPrimary),
                      ),
                    ],
                  ),
                ),
                const FadeSectionHeader(title: 'Buttons'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FadeSpace.gutter,
                  ),
                  child: Column(
                    children: [
                      FadeButton.primary(
                        label: 'Save hours',
                        expand: true,
                        loading: _saving,
                        onPressed: () async {
                          setState(() => _saving = true);
                          await Future<void>.delayed(
                            const Duration(seconds: 2),
                          );
                          if (mounted) setState(() => _saving = false);
                        },
                      ),
                      const SizedBox(height: FadeSpace.s8),
                      FadeButton.secondary(
                        label: 'Preview booking page',
                        icon: Icons.visibility_outlined,
                        expand: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: FadeSpace.s8),
                      Row(
                        children: [
                          FadeButton.ghost(
                            label: 'Skip for now',
                            onPressed: () {},
                          ),
                          const Spacer(),
                          const FadeButton.primary(
                            label: 'Disabled',
                            onPressed: null,
                            size: FadeButtonSize.medium,
                          ),
                        ],
                      ),
                      const SizedBox(height: FadeSpace.s8),
                      FadeButton.destructive(
                        label: 'Cancel appointment',
                        expand: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const FadeSectionHeader(title: 'Inputs'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: FadeSpace.gutter),
                  child: Column(
                    children: [
                      FadeTextField(
                        label: 'Business name',
                        hint: 'e.g. Southside Cuts',
                      ),
                      SizedBox(height: FadeSpace.s16),
                      FadeTextField(
                        label: 'Price',
                        prefixText: '\$ ',
                        hint: '40',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: FadeSpace.s16),
                      FadeTextField(
                        label: 'Instagram',
                        optional: true,
                        hint: '@yourhandle',
                        helper: 'Shown on your booking page.',
                      ),
                      SizedBox(height: FadeSpace.s16),
                      FadeTextField(
                        label: 'Email',
                        errorText:
                            "That email doesn't look right. Check for typos.",
                      ),
                      SizedBox(height: FadeSpace.s16),
                      FadeSearchField(hint: 'Search clients'),
                    ],
                  ),
                ),
                const FadeSectionHeader(title: 'Chips & tags'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FadeSpace.gutter,
                  ),
                  child: Wrap(
                    spacing: FadeSpace.s8,
                    runSpacing: FadeSpace.s8,
                    children: [
                      for (final d in const [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ])
                        FadeChip(
                          label: d,
                          selected: _days.contains(d),
                          onSelected: (v) => setState(
                            () => v ? _days.add(d) : _days.remove(d),
                          ),
                        ),
                      const FadeTag(
                        label: 'Confirmed',
                        tone: FadeTone.success,
                        dot: true,
                      ),
                      const FadeTag(
                        label: 'Deposit paid',
                        tone: FadeTone.accent,
                      ),
                      const FadeTag(
                        label: 'Pending',
                        tone: FadeTone.warning,
                        dot: true,
                      ),
                      const FadeTag(label: 'No-show', tone: FadeTone.danger),
                      const FadeTag(label: 'New client', tone: FadeTone.info),
                      const FadeTag(label: 'Walk-in'),
                    ],
                  ),
                ),
                const FadeSectionHeader(
                  title: 'Cards & rows',
                  actionLabel: 'See all',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FadeSpace.gutter,
                  ),
                  child: Column(
                    children: [
                      FadeCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            FadeListRow(
                              leading: const FadeAvatar(name: 'Marcus T.'),
                              title: 'Marcus T.',
                              subtitle: 'Skin fade · 10:00 AM',
                              trailing: const FadeTag(
                                label: 'Confirmed',
                                tone: FadeTone.success,
                                dot: true,
                              ),
                              divider: true,
                              onTap: () {},
                            ),
                            FadeListRow(
                              leadingIcon: Icons.content_cut_rounded,
                              title: 'Taper + beard',
                              subtitle: '60 min',
                              value: '\$55',
                              divider: true,
                              onTap: () {},
                            ),
                            FadeListRow(
                              leadingIcon: Icons.delete_outline_rounded,
                              title: 'Delete service',
                              destructive: true,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: FadeSpace.s12),
                      FadeCard(
                        tone: FadeCardTone.accent,
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_outlined,
                              color: c.accentText,
                            ),
                            const SizedBox(width: FadeSpace.s12),
                            Expanded(
                              child: Text(
                                'Connect payouts to start taking card payments.',
                                style: FadeType.bodySm.copyWith(
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: FadeSpace.s12),
                      FadeCard(
                        tone: FadeCardTone.raised,
                        child: Row(
                          children: [
                            FadeAvatar(
                              name: 'Jordan Reyes',
                              size: FadeAvatarSize.lg,
                              ring: true,
                              statusColor: c.success,
                            ),
                            const SizedBox(width: FadeSpace.s12),
                            Expanded(
                              child: Text('Jordan Reyes', style: FadeType.h3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const FadeSectionHeader(title: 'States'),
                FadeCard(
                  child: FadeEmptyState(
                    compact: true,
                    icon: Icons.event_available_outlined,
                    title: 'No bookings yet',
                    message:
                        'Share your booking link and clients can grab a time in seconds.',
                    actionLabel: 'Copy booking link',
                    onAction: () {},
                  ),
                ),
                const SizedBox(height: FadeSpace.s12),
                FadeCard(child: FadeErrorState(compact: true, onRetry: () {})),
                const SizedBox(height: FadeSpace.s12),
                const FadeCard(
                  padding: EdgeInsets.zero,
                  child: FadeSkeletonList(count: 3),
                ),
                const SizedBox(height: FadeSpace.s24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FadeSpace.gutter,
                  ),
                  child: FadeButton.secondary(
                    label: 'Open bottom sheet',
                    expand: true,
                    onPressed: () => showFadeSheet<void>(
                      context,
                      title: 'Cancel this appointment?',
                      subtitle: 'Sat, Oct 10 · 2:30 PM · Skin fade',
                      child: const Text(
                        "We'll let the client know and refund any deposit.",
                      ),
                      actions: [
                        FadeButton.destructive(
                          label: 'Cancel appointment',
                          onPressed: () => Navigator.pop(context),
                        ),
                        FadeButton.ghost(
                          label: 'Keep it',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
