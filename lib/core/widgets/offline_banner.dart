import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/connectivity_provider.dart';

/// A professional banner widget that displays connectivity status
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _onlineBannerTimer;
  bool? _previousConnectionState;
  bool _showOnlineBanner = false;
  bool _isOfflineBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom (off-screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _onlineBannerTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _showOnlineBannerTemporarily() {
    setState(() {
      _showOnlineBanner = true;
    });
    _animationController.forward();
    
    // Auto-dismiss after 1 second
    _onlineBannerTimer?.cancel();
    _onlineBannerTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showOnlineBanner = false;
            });
          }
        });
      }
    });
  }

  void _dismissOfflineBanner() {
    setState(() {
      _isOfflineBannerDismissed = true;
    });
    _animationController.reverse();
  }

  Widget _buildOfflineBanner() {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 212, 0, 0), // Red background
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'You are currently offline',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _dismissOfflineBanner,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineBanner() {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E), // Green background
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Back online',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);
    
    return connectivityAsync.when(
      data: (isConnected) {
        // Detect when connection state changes from offline to online
        if (_previousConnectionState == false && isConnected) {
          // Connection restored - show online banner
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showOnlineBannerTemporarily();
          });
        }
        
        // Reset dismissed state when connection state changes
        if (_previousConnectionState != isConnected) {
          _isOfflineBannerDismissed = false;
        }
        
        _previousConnectionState = isConnected;
        
        if (_showOnlineBanner) {
          return _buildOnlineBanner();
        }
        
        if (isConnected) {
          return const SizedBox.shrink();
        } else {
          // Only show offline banner if not dismissed
          if (!_isOfflineBannerDismissed) {
            _animationController.forward();
            return _buildOfflineBanner();
          } else {
            return const SizedBox.shrink();
          }
        }
      },
      loading: () {
        _animationController.reverse();
        return const SizedBox.shrink();
      },
      error: (_, __) {
        _previousConnectionState = false;
        _animationController.forward();
        return _buildOfflineBanner();
      },
    );
  }
}

