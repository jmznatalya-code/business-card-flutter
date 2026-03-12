import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _kGold = Color(0xFFC8A96E);
const _kGoldLight = Color(0xFFF5EDD8);
const _kGoldDim = Color(0xFFE8D5B0);
const _kCream = Color(0xFFFAF9F5);
const _kWhite = Color(0xFFFFFFFF);
const _kInk = Color(0xFF1C1917);
const _kMuted = Color(0xFF78716C);
const _kBorder = Color(0xFFEDE8DF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const BusinessCardApp());
}

// ─── App ─────────────────────────────────────────────────────────────────────

class BusinessCardApp extends StatelessWidget {
  const BusinessCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _kCream,
        colorScheme: ColorScheme.light(
          primary: _kGold,
          onPrimary: _kWhite,
          surface: _kWhite,
          onSurface: _kInk,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _kWhite,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          shadowColor: _kBorder,
          iconTheme: IconThemeData(color: _kInk),
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            color: _kInk,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _kWhite,
          labelStyle: const TextStyle(color: _kMuted, fontSize: 13),
          floatingLabelStyle: const TextStyle(color: _kGold, fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kGold, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
      home: const BusinessCardPage(),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Card {
  String name, occupation, phone, email, address, bio;
  String? imagePath;

  _Card({
    this.name = '',
    this.occupation = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.bio = '',
    this.imagePath,
  });

  static Future<_Card> load() async {
    final p = await SharedPreferences.getInstance();
    return _Card(
      name: p.getString('bc_name') ?? '',
      occupation: p.getString('bc_occupation') ?? '',
      phone: p.getString('bc_phone') ?? '',
      email: p.getString('bc_email') ?? '',
      address: p.getString('bc_address') ?? '',
      bio: p.getString('bc_bio') ?? '',
      imagePath: p.getString('bc_imagePath'),
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('bc_name', name);
    await p.setString('bc_occupation', occupation);
    await p.setString('bc_phone', phone);
    await p.setString('bc_email', email);
    await p.setString('bc_address', address);
    await p.setString('bc_bio', bio);
    if (imagePath != null) await p.setString('bc_imagePath', imagePath!);
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class BusinessCardPage extends StatefulWidget {
  const BusinessCardPage({super.key});

  @override
  State<BusinessCardPage> createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  _Card _data = _Card();
  bool _editing = false;
  bool _loading = true;

  final _nameCtrl = TextEditingController();
  final _occCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _occCtrl, _phoneCtrl, _emailCtrl, _addrCtrl, _bioCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final d = await _Card.load();
    setState(() {
      _data = d;
      _sync();
      _loading = false;
    });
  }

  void _sync() {
    _nameCtrl.text = _data.name;
    _occCtrl.text = _data.occupation;
    _phoneCtrl.text = _data.phone;
    _emailCtrl.text = _data.email;
    _addrCtrl.text = _data.address;
    _bioCtrl.text = _data.bio;
  }

  Future<void> _save() async {
    setState(() {
      _data
        ..name = _nameCtrl.text.trim()
        ..occupation = _occCtrl.text.trim()
        ..phone = _phoneCtrl.text.trim()
        ..email = _emailCtrl.text.trim()
        ..address = _addrCtrl.text.trim()
        ..bio = _bioCtrl.text.trim();
      _editing = false;
    });
    await _data.save();
  }

  void _cancel() {
    _sync();
    setState(() => _editing = false);
  }

  Future<void> _pickPhoto() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 88,
    );
    if (f != null) setState(() => _data.imagePath = f.path);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BUSINESS CARD'),
        centerTitle: true,
        actions: _loading
            ? null
            : [
                if (_editing)
                  TextButton(
                    onPressed: _cancel,
                    child: const Text('Cancel',
                        style: TextStyle(color: _kMuted, fontSize: 14)),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit',
                    onPressed: () => setState(() => _editing = true),
                  ),
              ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _kGold),
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: _editing
                  ? _EditView(
                      key: const ValueKey('edit'),
                      data: _data,
                      nameCtrl: _nameCtrl,
                      occCtrl: _occCtrl,
                      phoneCtrl: _phoneCtrl,
                      emailCtrl: _emailCtrl,
                      addrCtrl: _addrCtrl,
                      bioCtrl: _bioCtrl,
                      onPickPhoto: _pickPhoto,
                      onSave: _save,
                    )
                  : _CardView(
                      key: const ValueKey('view'),
                      data: _data,
                    ),
            ),
    );
  }
}

// ─── Card View ────────────────────────────────────────────────────────────────

class _CardView extends StatelessWidget {
  final _Card data;
  const _CardView({super.key, required this.data});

  bool get _isEmpty =>
      data.name.isEmpty &&
      data.occupation.isEmpty &&
      data.phone.isEmpty &&
      data.email.isEmpty &&
      data.address.isEmpty &&
      data.bio.isEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        children: [
          // ── Card surface ───────────────────────────────────────────────────
          _Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Photo(path: data.imagePath, size: 84, editable: false),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name.isEmpty ? 'Your Name' : data.name,
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: data.name.isEmpty
                                    ? const Color(0xFFD6CFC7)
                                    : _kInk,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (data.occupation.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                data.occupation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _kGold,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Gold rule
                if (data.phone.isNotEmpty ||
                    data.email.isNotEmpty ||
                    data.address.isNotEmpty ||
                    data.bio.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _GoldRule(),
                  const SizedBox(height: 16),
                ],

                // Contact rows
                if (data.phone.isNotEmpty)
                  _ContactRow(icon: Icons.phone_outlined, text: data.phone),
                if (data.email.isNotEmpty)
                  _ContactRow(icon: Icons.mail_outline, text: data.email),
                if (data.address.isNotEmpty)
                  _ContactRow(
                      icon: Icons.location_on_outlined, text: data.address),

                // Bio
                if (data.bio.isNotEmpty) ...[
                  if (data.phone.isNotEmpty ||
                      data.email.isNotEmpty ||
                      data.address.isNotEmpty)
                    const SizedBox(height: 4),
                  if (data.phone.isNotEmpty ||
                      data.email.isNotEmpty ||
                      data.address.isNotEmpty)
                    const _GoldRule(),
                  const SizedBox(height: 14),
                  Text(
                    data.bio,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _kMuted,
                      height: 1.7,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Empty hint ────────────────────────────────────────────────────
          if (_isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kGoldLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGoldDim),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: _kGold, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap the edit icon in the top-right to fill in your card.',
                      style: TextStyle(
                          fontSize: 13,
                          color: _kGold.withOpacity(0.85),
                          height: 1.4),
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
}

// ─── Edit View ────────────────────────────────────────────────────────────────

class _EditView extends StatelessWidget {
  final _Card data;
  final TextEditingController nameCtrl, occCtrl, phoneCtrl, emailCtrl,
      addrCtrl, bioCtrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onSave;

  const _EditView({
    super.key,
    required this.data,
    required this.nameCtrl,
    required this.occCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.addrCtrl,
    required this.bioCtrl,
    required this.onPickPhoto,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo picker
          Center(child: _Photo(path: data.imagePath, size: 110, editable: true, onTap: onPickPhoto)),
          const SizedBox(height: 28),

          // Form
          _Surface(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              children: [
                _Field(ctrl: nameCtrl, label: 'Full Name', icon: Icons.person_outline, caps: TextCapitalization.words),
                _Field(ctrl: occCtrl, label: 'Occupation / Title', icon: Icons.work_outline, caps: TextCapitalization.words),
                _Field(ctrl: phoneCtrl, label: 'Phone', icon: Icons.phone_outlined, type: TextInputType.phone),
                _Field(ctrl: emailCtrl, label: 'Email', icon: Icons.mail_outline, type: TextInputType.emailAddress),
                _Field(ctrl: addrCtrl, label: 'Address', icon: Icons.location_on_outlined, maxLines: 2),
                _Field(ctrl: bioCtrl, label: 'Bio', icon: Icons.notes_rounded, maxLines: 5),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: _kWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Card',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Photo extends StatelessWidget {
  final String? path;
  final double size;
  final bool editable;
  final VoidCallback? onTap;

  const _Photo({
    required this.path,
    required this.size,
    required this.editable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = path != null && File(path!).existsSync();

    final frame = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _kGoldLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: editable ? _kGold : _kGoldDim,
          width: editable ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(File(path!), fit: BoxFit.cover)
          : Icon(Icons.person_rounded, size: size * 0.48, color: _kGoldDim),
    );

    if (!editable) return frame;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          frame,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.27,
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera_outlined,
                      size: 13, color: _kWhite),
                  const SizedBox(width: 4),
                  Text(
                    hasImage ? 'Change' : 'Add Photo',
                    style: const TextStyle(
                        color: _kWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4),
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

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _kGoldLight,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 15, color: _kGold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13.5, color: _kInk, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldRule extends StatelessWidget {
  const _GoldRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kGoldDim.withOpacity(0),
            _kGoldDim,
            _kGoldDim.withOpacity(0),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType type;
  final TextCapitalization caps;
  final int maxLines;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.caps = TextCapitalization.none,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        textCapitalization: caps,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14.5, color: _kInk),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: _kGold),
        ),
      ),
    );
  }
}
