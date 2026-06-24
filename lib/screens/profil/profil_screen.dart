import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

// ══════════════════════════════════════════════════════════
//  PROFIL SCREEN — F9
// ══════════════════════════════════════════════════════════
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profil',
              onPressed: () => setState(() => _editMode = true),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: user == null
              ? const Center(child: CircularProgressIndicator())
              : _editMode
                  ? _EditProfilForm(
                      user: user,
                      onCancel: () => setState(() => _editMode = false),
                      onSaved: () => setState(() => _editMode = false),
                    )
                  : _ProfilView(user: user),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  TAMPILAN PROFIL (READ)
// ──────────────────────────────────────────────────────────
class _ProfilView extends StatelessWidget {
  final UserModel user;
  const _ProfilView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        const CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.storefront, size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(user.nama, style: AppTextStyles.heading1),
        const SizedBox(height: 4),
        Text(user.namaWarung,
            style: AppTextStyles.body
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(user.email, style: AppTextStyles.caption),
        const SizedBox(height: 24),

        // Info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(icon: Icons.person_outline, label: 'Nama', value: user.nama),
                const Divider(height: 20),
                _InfoRow(
                    icon: Icons.store_outlined,
                    label: 'Nama Warung',
                    value: user.namaWarung),
                const Divider(height: 20),
                _InfoRow(
                    icon: Icons.email_outlined, label: 'Email', value: user.email),
                const Divider(height: 20),
                _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'No. Telepon',
                    value: user.telepon.isEmpty ? '-' : user.telepon),
                const Divider(height: 20),
                _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Role',
                    value: user.role == 'owner' ? 'Pemilik Warung' : user.role),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Logout
        ElevatedButton.icon(
          onPressed: () => _konfirmasiLogout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
          ),
        ),
      ],
    );
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
//  FORM EDIT PROFIL
// ──────────────────────────────────────────────────────────
class _EditProfilForm extends StatefulWidget {
  final UserModel user;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  const _EditProfilForm({
    required this.user,
    required this.onCancel,
    required this.onSaved,
  });

  @override
  State<_EditProfilForm> createState() => _EditProfilFormState();
}

class _EditProfilFormState extends State<_EditProfilForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _namaWarungCtrl;
  late final TextEditingController _teleponCtrl;

  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.user.nama);
    _namaWarungCtrl = TextEditingController(text: widget.user.namaWarung);
    _teleponCtrl = TextEditingController(text: widget.user.telepon);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _namaWarungCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = widget.user.copyWith(
        nama: _namaCtrl.text.trim(),
        namaWarung: _namaWarungCtrl.text.trim(),
        telepon: _teleponCtrl.text.trim(),
      );

      await AuthService().updateProfil(updatedUser);
      await context.read<AuthProvider>().refreshUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui ✓'),
          backgroundColor: AppColors.primary,
        ),
      );
      widget.onSaved();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan: ${e.toString()}';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.storefront, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),

          // Form fields
          const Text('Nama Lengkap', style: AppTextStyles.caption),
          const SizedBox(height: 6),
          TextFormField(
            controller: _namaCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'Nama lengkap Anda',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 16),

          const Text('Nama Warung', style: AppTextStyles.caption),
          const SizedBox(height: 6),
          TextFormField(
            controller: _namaWarungCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.store_outlined),
              hintText: 'Nama warung Anda',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nama warung wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 16),

          const Text('No. Telepon', style: AppTextStyles.caption),
          const SizedBox(height: 6),
          TextFormField(
            controller: _teleponCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: 'Contoh: 08123456789',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),

          // Email (read-only)
          const Text('Email (tidak dapat diubah)', style: AppTextStyles.caption),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: widget.user.email,
            enabled: false,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
            ),
            style: AppTextStyles.body.copyWith(color: AppColors.neutralGrey),
          ),
          const SizedBox(height: 24),

          // Error
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],

          // Tombol simpan
          ElevatedButton(
            onPressed: _saving ? null : _simpan,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Simpan Perubahan'),
          ),
          const SizedBox(height: 12),

          // Tombol batal
          OutlinedButton(
            onPressed: _saving ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutralGrey,
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}
