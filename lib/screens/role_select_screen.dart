import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'student_login_screen.dart';
import 'warden_shell.dart';

class RoleSelectScreen extends StatelessWidget {
  static const String routeName = '/role-select';
  static const String wardenPin = '1234';

  const RoleSelectScreen({super.key});

  void _showWardenPinDialog(BuildContext context) {
    final controllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

            void verifyPin() {
              final entered = controllers.map((c) => c.text.trim()).join();
              if (entered == wardenPin) {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pushReplacementNamed(WardenShell.routeName);
              } else {
                setDialogState(() {
                  errorText = 'Invalid PIN. Default PIN is 1234.';
                });
              }
            }

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_outline, color: Color(0xFF0F766E)),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Warden Access',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter 4-digit staff PIN to continue',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 52,
                            height: 54,
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2),
                                ),
                              ),
                              onChanged: (val) {
                                if (errorText != null) {
                                  setDialogState(() => errorText = null);
                                }
                                if (val.isNotEmpty && index < 3) {
                                  focusNodes[index + 1].requestFocus();
                                } else if (val.isEmpty && index > 0) {
                                  focusNodes[index - 1].requestFocus();
                                }
                              },
                              onSubmitted: (_) => verifyPin(),
                            ),
                          );
                        }),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: verifyPin,
                            child: const Text('Verify & Enter', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.apartment,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'GREENVIEW STUDENT RESIDENCY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'HostelMate',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Smart Student & Hostel Assistant',
                          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 36),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'CHOOSE YOUR PORTAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PortalCard(
                          iconBg: const Color(0xFFCCFBF1),
                          icon: Icons.school,
                          iconColor: const Color(0xFF0F766E),
                          eyebrow: 'Continue as Student',
                          eyebrowColor: const Color(0xFF0F766E),
                          title: 'Student Portal',
                          subtitle: 'View mess menu, ask AI assistant, log & track room complaints',
                          trailingIcon: Icons.arrow_forward,
                          onTap: () => Navigator.of(context).pushNamed(StudentLoginScreen.routeName),
                        ),
                        const SizedBox(height: 14),
                        _PortalCard(
                          iconBg: const Color(0xFFF1F5F9),
                          icon: Icons.admin_panel_settings_outlined,
                          iconColor: const Color(0xFF475569),
                          eyebrow: 'Warden / Staff Access',
                          eyebrowColor: const Color(0xFF64748B),
                          title: 'Warden Desk',
                          subtitle: 'Update daily mess menu, notices & resolve complaints (PIN required)',
                          trailingIcon: Icons.lock_outline,
                          onTap: () => _showWardenPinDialog(context),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'GreenView Student Residency • Islamabad',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String eyebrow;
  final Color eyebrowColor;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const _PortalCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.eyebrow,
    required this.eyebrowColor,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: eyebrowColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(trailingIcon, color: const Color(0xFF0F766E), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}