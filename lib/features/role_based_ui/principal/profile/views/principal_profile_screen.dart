import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../core/services/api/endpoints.dart';
import '../../../../../routes/app_routes.dart';
import '../controllers/principal_profile_controller.dart';

class PrincipalProfileScreen extends StatelessWidget {
  const PrincipalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PrincipalProfileController());
    return _ProfileView(c: c);
  }
}

class _ProfileView extends StatelessWidget {
  final PrincipalProfileController c;
  const _ProfileView({required this.c});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _HeroHeader(c: c, canPop: canPop),
                const SizedBox(height: 56),
                _NameSection(c: c),
                const SizedBox(height: 20),
                _ContactRowSlot(c: c),
                _ContentBody(c: c),
                const SizedBox(height: 110),
              ],
            ),
          ),
          Positioned(
            bottom: 90,
            left: 24,
            right: 24,
            child: _FabArea(c: c),
          ),
        ],
      ),
    );
  }
}

// ── Slot widgets (each owns its Obx — no nesting) ────────────────────────────

class _ContactRowSlot extends StatelessWidget {
  final PrincipalProfileController c;
  const _ContactRowSlot({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => c.isEditMode.value
        ? const SizedBox(height: 16)
        : Column(
            children: [
              _QuickContactRow(c: c),
              const SizedBox(height: 24),
            ],
          ));
  }
}

class _ContentBody extends StatelessWidget {
  final PrincipalProfileController c;
  const _ContentBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value && c.profile.value == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return c.isEditMode.value ? _EditBody(c: c) : _ViewBody(c: c);
    });
  }
}

class _FabArea extends StatelessWidget {
  final PrincipalProfileController c;
  const _FabArea({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => c.isEditMode.value
        ? _EditActionBar(c: c)
        : _EditFab(c: c));
  }
}

// ── Hero header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final PrincipalProfileController c;
  final bool canPop;
  const _HeroHeader({required this.c, required this.canPop});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primaryDark =
        Color.lerp(scheme.primary, Colors.black, 0.28) ?? scheme.primary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 230,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryDark, scheme.primary],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40, right: -40,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20, left: -30,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              if (canPop)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 20),
                              onPressed: () => Get.back(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: -52, left: 0, right: 0,
          child: Center(child: _Avatar(c: c, scheme: scheme)),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final PrincipalProfileController c;
  final ColorScheme scheme;
  const _Avatar({required this.c, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logoUrl = c.displayBranchLogo.value;
      final hasUrl = logoUrl.isNotEmpty;
      final fullUrl = hasUrl
          ? (logoUrl.startsWith('http')
              ? logoUrl
              : '${Endpoints.baseUrl}/$logoUrl')
          : '';
      return Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: hasUrl
              ? Image.network(fullUrl, fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => _fallback(scheme))
              : _fallback(scheme),
        ),
      );
    });
  }

  Widget _fallback(ColorScheme s) => Container(
        color: s.primaryContainer,
        child: Icon(Icons.person_rounded, size: 52, color: s.onPrimaryContainer),
      );
}

// ── Name / role / branch ──────────────────────────────────────────────────────

class _NameSection extends StatelessWidget {
  final PrincipalProfileController c;
  const _NameSection({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                c.displayName.value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (c.displayRole.value.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    c.displayRole.value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (c.displayBranch.value.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        c.displayBranch.value,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ));
  }
}

// ── Quick contact icons (view mode only) ──────────────────────────────────────

class _QuickContactRow extends StatelessWidget {
  final PrincipalProfileController c;
  const _QuickContactRow({required this.c});

  void _copy(String text, String message) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Opens the address on Google Maps inside the in-app WebView.
  void _openLocation(String address) {
    if (address.trim().isEmpty) return;
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    Get.toNamed(
      AppRoutes.webView,
      arguments: {'title': 'Location', 'url': url},
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final items = <_QItem>[
        if (c.displayPhone.value.isNotEmpty)
          _QItem(Icons.phone_rounded, 'Call',
              () => _copy(c.displayPhone.value, 'Phone number copied')),
        if (c.displayEmail.value.isNotEmpty)
          _QItem(Icons.email_rounded, 'Email',
              () => _copy(c.displayEmail.value, 'Email copied')),
        if ((c.profile.value?.address ?? '').isNotEmpty)
          _QItem(Icons.location_on_rounded, 'Location',
              () => _openLocation(c.profile.value?.address ?? '')),
        _QItem(
          Icons.share_rounded,
          'Share',
          () => _copy(
            '${c.displayName.value}\n${c.displayPhone.value}\n${c.displayEmail.value}',
            'Profile details copied',
          ),
        ),
      ];
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: item.onTap,
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: scheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(item.icon,
                          color: scheme.onPrimaryContainer, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(item.label,
                    style: textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          )).toList(),
        ),
      );
    });
  }
}

class _QItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QItem(this.icon, this.label, this.onTap);
}

// ── View body ─────────────────────────────────────────────────────────────────

class _ViewBody extends StatelessWidget {
  final PrincipalProfileController c;
  const _ViewBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = c.profile.value;
      return Column(
        children: [
          if (c.errorMessage.value.isNotEmpty)
            _ErrorBanner(message: c.errorMessage.value),
          _ViewSection(
            title: 'Contact',
            icon: Icons.contact_phone_outlined,
            rows: [
              _VRow(Icons.phone_outlined, 'Mobile', c.displayPhone.value),
              _VRow(Icons.email_outlined, 'Email', c.displayEmail.value),
              _VRow(Icons.phone_in_talk_outlined, 'Alt Contact', p?.contactNo),
              _VRow(Icons.person_outline, 'Contact Person', p?.contactPerson),
              _VRow(Icons.location_on_outlined, 'Address', p?.address),
            ],
          ),
          _ViewSection(
            title: 'Personal',
            icon: Icons.badge_outlined,
            rows: [
              _VRow(Icons.wc_outlined, 'Gender', p?.gender),
              _VRow(Icons.cake_outlined, 'Date of Birth',
                  _fmtDate(p?.dob)),
              _VRow(Icons.work_outline, 'Designation', p?.designationName),
              _VRow(Icons.category_outlined, 'Category', p?.category),
              _VRow(Icons.church_outlined, 'Religion', p?.religion),
              _VRow(Icons.blur_circular_outlined, 'Caste', p?.caste),
              _VRow(Icons.location_city_outlined, 'District', p?.district),
              _VRow(Icons.map_outlined, 'Tehsil', p?.tehsil),
              _VRow(Icons.home_outlined, 'Village / Mohalla',
                  p?.villageMohalla),
            ],
          ),
          _ViewSection(
            title: 'Branch / School',
            icon: Icons.school_outlined,
            rows: [
              _VRow(Icons.business_outlined, 'Branch Name',
                  c.displayBranch.value),
              _VRow(Icons.qr_code_outlined, 'Branch Code', p?.branchCode),
              _VRow(Icons.groups_outlined, 'Group', p?.groupName),
              _VRow(Icons.class_outlined, 'Class', p?.className),
            ],
          ),
        ],
      );
    });
  }

  static String? _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _VRow {
  final IconData icon;
  final String label;
  final String? value;
  const _VRow(this.icon, this.label, this.value);
}

class _ViewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_VRow> rows;
  const _ViewSection(
      {required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final visible =
        rows.where((r) => r.value != null && r.value!.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, icon: icon),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          ...visible.asMap().entries.map((e) => Column(
                children: [
                  _ViewTile(row: e.value),
                  if (e.key < visible.length - 1)
                    Divider(
                      height: 1,
                      indent: 52,
                      endIndent: 16,
                      color: scheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                ],
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ViewTile extends StatelessWidget {
  final _VRow row;
  const _ViewTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(row.icon, size: 17, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  row.value!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit body ─────────────────────────────────────────────────────────────────

class _EditBody extends StatelessWidget {
  final PrincipalProfileController c;
  const _EditBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EditSection(
          title: 'Contact',
          icon: Icons.contact_phone_outlined,
          fields: [
            _EField(Icons.phone_outlined, 'Mobile', c.mobile,
                type: TextInputType.phone),
            _EField(Icons.email_outlined, 'Email', c.email,
                type: TextInputType.emailAddress),
            _EField(Icons.phone_in_talk_outlined, 'Alt Contact', c.altContact,
                type: TextInputType.phone),
            _EField(Icons.person_outline, 'Contact Person', c.contactPerson),
            _EField(Icons.location_on_outlined, 'Address', c.address,
                maxLines: 2),
          ],
        ),
        _EditSection(
          title: 'Personal',
          icon: Icons.badge_outlined,
          fields: [
            _EField(Icons.wc_outlined, 'Gender', c.gender),
            _EField(Icons.cake_outlined, 'Date of Birth (DD/MM/YYYY)', c.dob,
                type: TextInputType.datetime),
            _EField(Icons.work_outline, 'Designation', c.designation),
            _EField(Icons.category_outlined, 'Category', c.category),
            _EField(Icons.church_outlined, 'Religion', c.religion),
            _EField(Icons.blur_circular_outlined, 'Caste', c.caste),
            _EField(Icons.location_city_outlined, 'District', c.district),
            _EField(Icons.map_outlined, 'Tehsil', c.tehsil),
            _EField(Icons.home_outlined, 'Village / Mohalla', c.village),
          ],
        ),
        _EditSection(
          title: 'Branch / School',
          icon: Icons.school_outlined,
          fields: [
            _EField(Icons.business_outlined, 'Branch Name', c.branchName),
            _EField(Icons.qr_code_outlined, 'Branch Code', c.branchCode),
            _EField(Icons.groups_outlined, 'Group', c.group),
            _EField(Icons.class_outlined, 'Class', c.className),
          ],
        ),
      ],
    );
  }
}

class _EField {
  final IconData icon;
  final String label;
  final TextEditingController ctrl;
  final TextInputType type;
  final int maxLines;
  const _EField(this.icon, this.label, this.ctrl,
      {this.type = TextInputType.text, this.maxLines = 1});
}

class _EditSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_EField> fields;
  const _EditSection(
      {required this.title, required this.icon, required this.fields});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, icon: icon),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: fields.map((f) => _EditFieldTile(f: f)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditFieldTile extends StatelessWidget {
  final _EField f;
  const _EditFieldTile({required this.f});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(f.icon, size: 17, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: f.ctrl,
              keyboardType: f.type,
              maxLines: f.maxLines,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: f.label,
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                filled: true,
                fillColor: scheme.surfaceContainerLowest,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: scheme.outlineVariant, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared section header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB — view mode ───────────────────────────────────────────────────────────

class _EditFab extends StatelessWidget {
  final PrincipalProfileController c;
  const _EditFab({required this.c});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: FloatingActionButton.extended(
        heroTag: 'edit_profile',
        onPressed: c.enterEditMode,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: Text(
          'Edit Profile',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Action bar — edit mode (Save + Cancel) ────────────────────────────────────

class _EditActionBar extends StatelessWidget {
  final PrincipalProfileController c;
  const _EditActionBar({required this.c});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Obx(() => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    c.isSaving.value ? null : c.cancelEdit,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: scheme.outline),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: scheme.surface,
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(
                  'Cancel',
                  style: textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: c.isSaving.value ? null : c.saveProfile,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: scheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: c.isSaving.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  c.isSaving.value ? 'Saving…' : 'Save Changes',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: scheme.onErrorContainer, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
