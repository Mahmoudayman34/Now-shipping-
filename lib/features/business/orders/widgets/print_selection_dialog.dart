import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:now_shipping/config/env.dart';
import 'package:now_shipping/features/auth/services/auth_service.dart';
import '../../../../core/l10n/app_localizations.dart';

class PrintSelectionDialog extends ConsumerStatefulWidget {
  final String orderId;
  final Function(String) onPrintSelected;

  const PrintSelectionDialog({
    super.key,
    required this.orderId,
    required this.onPrintSelected,
  });

  @override
  ConsumerState<PrintSelectionDialog> createState() => _PrintSelectionDialogState();
}

class _PrintSelectionDialogState extends ConsumerState<PrintSelectionDialog> {
  String _selectedSize = 'A4'; // Default selected paper size
  bool _isLoading = false;

  Future<void> _downloadAndOpenPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the auth token
      final authService = ref.read(authServiceProvider);
      final token = await authService.getToken();
      
      if (token == null) {
        _showErrorDialog('Authentication error. Please login again.');
        return;
      }

      // Get base URL from app config
      final baseUrl = AppConfig.apiBaseUrl;
      
      // Construct the URL
      final url = '$baseUrl/business/orders/print-policy/${widget.orderId}/${_selectedSize.toLowerCase()}';
      
      // Make the API request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Get directory to save the PDF
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/airwaybill_${widget.orderId}_${_selectedSize.toLowerCase()}.pdf';
        
        // Write the PDF file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Open the PDF file
        final result = await OpenFile.open(filePath);
        
        if (result.type != ResultType.done) {
          _showErrorDialog('Failed to open PDF: ${result.message}');
          return;
        }
        
        // Call the callback
        widget.onPrintSelected(_selectedSize);
        
        // Close the dialog
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Handle error response
        _showErrorDialog('Failed to download airwaybill. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.print,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).printAirwaybill,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          const SizedBox(height: 16),
          
          // Instruction text
          Text(
            AppLocalizations.of(context).selectPaperSize,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Paper size options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPaperSizeOption(
                context,
                'A4',
              ),
              _buildPaperSizeOption(
                context,
                'A5',
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Print button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _downloadAndOpenPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _getPrintButtonText(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperSizeOption(
    BuildContext context,
    String size,
  ) {
    final bool isSelected = _selectedSize == size;
    
    // Different dimensions for paper size visualization
    final double paperWidth = size == 'A4' ? 50.0 : 42.0;
    final double paperHeight = size == 'A4' ? 70.0 : 59.0;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = size;
        });
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8E1) : const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : const Color(0xFFEEEEEE),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 20,
                  color: isSelected ? const Color(0xFFFF9800) : Colors.grey,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Paper visualization
            Container(
              height: 70,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Paper
                  Container(
                    width: paperWidth,
                    height: paperHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected 
                          ? const Color(0xFFFF9800) 
                          : const Color(0xFFAAAAAA),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  // Lines representing text
                  Positioned(
                    top: paperHeight * 0.2,
                    left: paperWidth * 0.2,
                    right: paperWidth * 0.2,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    top: paperHeight * 0.3,
                    left: paperWidth * 0.2,
                    right: paperWidth * 0.2,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    top: paperHeight * 0.4,
                    left: paperWidth * 0.2,
                    right: paperWidth * 0.2,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  
                  // QR code representation
                  Positioned(
                    bottom: paperHeight * 0.15,
                    right: paperWidth * 0.2,
                    child: Container(
                      width: paperWidth * 0.3,
                      height: paperWidth * 0.3,
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? const Color(0xFFFF9800) 
                          : const Color(0xFFAAAAAA),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Size text
            Text(
              size,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF2F2F2F),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Size description
            Text(
              size == 'A4' ? '210 × 297 mm' : '148 × 210 mm',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrintButtonText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_selectedSize == 'A4') {
      return l10n.printA4;
    } else if (_selectedSize == 'A5') {
      return l10n.printA5;
    } else {
      return 'Print $_selectedSize'; // Fallback for other sizes
    }
  }
} 