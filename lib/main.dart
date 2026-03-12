import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BusinessCardApp());
}

// ─── App Root ────────────────────────────────────────────────────────────────

class BusinessCardApp extends StatelessWidget {
  const BusinessCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: Color(0x1A000000),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),
      ),
      home: const BusinessCardPage(),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class CardData {
  String name;
  String occupation;
  String phone;
  String email;
  String address;
  String bio;
  String? imagePath;

  CardData({
    this.name = '',
    this.occupation = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.bio = '',
    this.imagePath,
  });

  static Future<CardData> load() async {
    final prefs = await SharedPreferences.getInstance();
    return CardData(
      name: prefs.getString('bc_name') ?? '',
      occupation: prefs.getString('bc_occupation') ?? '',
      phone: prefs.getString('bc_phone') ?? '',
      email: prefs.getString('bc_email') ?? '',
      address: prefs.getString('bc_address') ?? '',
      bio: prefs.getString('bc_bio') ?? '',
      imagePath: prefs.getString('bc_imagePath'),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bc_name', name);
    await prefs.setString('bc_occupation', occupation);
    await prefs.setString('bc_phone', phone);
    await prefs.setString('bc_email', email);
    await prefs.setString('bc_address', address);
    await prefs.setString('bc_bio', bio);
    if (imagePath != null) {
      await prefs.setString('bc_imagePath', imagePath!);
    }
  }
}

// ─── Page ────────────────────────────────────────────────────────────────────

class BusinessCardPage extends StatefulWidget {
  const BusinessCardPage({super.key});

  @override
  State<BusinessCardPage> createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage>
    with SingleTickerProviderStateMixin {
  CardData _data = CardData();
  bool _isEditing = false;
  bool _isLoading = true;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _bioCtrl;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _occupationCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _bioCtrl = TextEditingController();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);

    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _occupationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await CardData.load();
    setState(() {
      _data = data;
      _syncControllers();
      _isLoading = false;
    });
    _animCtrl.forward();
  }

  void _syncControllers() {
    _nameCtrl.text = _data.name;
    _occupationCtrl.text = _data.occupation;
    _phoneCtrl.text = _data.phone;
    _emailCtrl.text = _data.email;
    _addressCtrl.text = _data.address;
    _bioCtrl.text = _data.bio;
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  Future<void> _saveEdits() async {
    setState(() {
      _data.name = _nameCtrl.text.trim();
      _data.occupation = _occupationCtrl.text.trim();
      _data.phone = _phoneCtrl.text.trim();
      _data.email = _emailCtrl.text.trim();
      _data.address = _addressCtrl.text.trim();
      _data.bio = _bioCtrl.text.trim();
      _isEditing = false;
    });
    await _data.save();
  }

  void _cancelEditing() {
    _syncControllers();
    setState(() => _isEditing = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 90,
    );
    if (file != null) {
      setState(() => _data.imagePath = file.path);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Card'),
        actions: _isLoading
            ? null
            : [
                if (_isEditing) ...[
                  TextButton(
                    onPressed: _cancelEditing,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _saveEdits,
                    icon: const Icon(Icons.check_rounded,
                        size: 18, color: Color(0xFF2563EB)),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                    onPressed: _startEditing,
                  ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: _isEditing ? _buildEditView() : _buildCardView(),
            ),
    );
  }

  // ── Card View ──────────────────────────────────────────────────────────────

  Widget _buildCardView() {
    final bool hasAnyContact =
        _data.phone.isNotEmpty || _data.email.isNotEmpty || _data.address.isNotEmpty;
    final bool isEmpty = _data.name.isEmpty &&
        _data.occupation.isEmpty &&
        !hasAnyContact &&
        _data.bio.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        children: [
          // ── Main Card ──────────────────────────────────────────────────────
          _CardSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: photo + name/occupation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PhotoWidget(
                      imagePath: _data.imagePath,
                      size: 88,
                      editable: false,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _data.name.isEmpty ? 'Your Name' : _data.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _data.name.isEmpty
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF0F172A),
                                letterSpacing: -0.4,
                                height: 1.2,
                              ),
                            ),
                            if (_data.occupation.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _data.occupation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Contact info
                if (hasAnyContact) ...[
                  const SizedBox(height: 20),
                  const _Divider(),
                  const SizedBox(height: 16),
                  if (_data.phone.isNotEmpty)
                    _InfoRow(icon: Icons.phone_outlined, text: _data.phone),
                  if (_data.email.isNotEmpty)
                    _InfoRow(icon: Icons.mail_outline_rounded, text: _data.email),
                  if (_data.address.isNotEmpty)
                    _InfoRow(
                        icon: Icons.location_on_outlined, text: _data.address),
                ],

                // Bio
                if (_data.bio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _Divider(),
                  const SizedBox(height: 16),
                  Text(
                    _data.bio,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.65,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Empty state hint ───────────────────────────────────────────────
          if (isEmpty) ...[
            const SizedBox(height: 16),
            _CardSurface(
              color: const Color(0xFFEFF6FF),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_note_rounded,
                        color: Color(0xFF2563EB), size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Tap the edit icon above to fill in your business card details.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3B82F6),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Edit View ──────────────────────────────────────────────────────────────

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo picker
          Center(
            child: _PhotoWidget(
              imagePath: _data.imagePath,
              size: 120,
              editable: true,
              onTap: _pickImage,
            ),
          ),
          const SizedBox(height: 28),

          // Fields card
          _CardSurface(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                _Field(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                _Field(
                  controller: _occupationCtrl,
                  label: 'Occupation / Title',
                  icon: Icons.work_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                _Field(
                  controller: _phoneCtrl,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _Field(
                  controller: _emailCtrl,
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                _Field(
                  controller: _addressCtrl,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                _Field(
                  controller: _bioCtrl,
                  label: 'Bio',
                  icon: Icons.notes_rounded,
                  maxLines: 5,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saveEdits,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Card',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _CardSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  const _CardSurface({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PhotoWidget extends StatelessWidget {
  final String? imagePath;
  final double size;
  final bool editable;
  final VoidCallback? onTap;

  const _PhotoWidget({
    required this.imagePath,
    required this.size,
    required this.editable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        imagePath != null && File(imagePath!).existsSync();

    Widget photo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: editable
            ? Border.all(color: const Color(0xFF2563EB), width: 2)
            : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(File(imagePath!), fit: BoxFit.cover)
          : Icon(
              Icons.person_rounded,
              size: size * 0.5,
              color: const Color(0xFFCBD5E1),
            ),
    );

    if (!editable) return photo;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          photo,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.28,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.88),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    hasImage ? 'Change' : 'Add Photo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool isLast;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: isLast ? 0 : 0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }
}
