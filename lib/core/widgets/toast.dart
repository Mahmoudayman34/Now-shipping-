// import 'package:flutter/material.dart';

// enum ToastType {
//   default_,
//   info,
//   success,
//   warning,
//   error,
// }

// class Toast extends StatelessWidget {
//   final String message;
//   final VoidCallback? onUndo;
//   final VoidCallback? onDismiss;
//   final ToastType type;

//   const Toast({
//     super.key,
//     required this.message,
//     this.onUndo,
//     this.onDismiss,
//     this.type = ToastType.default_,
//   });

//   // Get the background color based on type
//   Color _getBackgroundColor() {
//     switch (type) {
//       case ToastType.default_:
//         return Colors.white;
//       case ToastType.info:
//         return Colors.blue;
//       case ToastType.success:
//         return Colors.green;
//       case ToastType.warning:
//         return const Color(0xFFE67E22); // Orange
//       case ToastType.error:
//         return const Color(0xFFE74C3C); // Red
//     }
//   }

//   // Get the text color based on type
//   Color _getTextColor() {
//     return type == ToastType.default_ ? Colors.black87 : Colors.white;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: _getBackgroundColor(),
//         borderRadius: BorderRadius.circular(4.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4.0,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: _getTextColor(),
//                 ),
//               ),
//             ),
//             if (onUndo != null)
//               TextButton(
//                 onPressed: onUndo,
//                 child: Text(
//                   'Undo',
//                   style: TextStyle(
//                     color: _getTextColor(),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             const SizedBox(width: 8.0),
//             InkWell(
//               onTap: onDismiss,
//               child: Icon(
//                 Icons.close,
//                 color: _getTextColor(),
//                 size: 20.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Helper class to show the Toast - making all methods static
// class ToastService {
//   static void show(
//     BuildContext context,
//     String message, {
//     ToastType type = ToastType.default_,
//     Duration duration = const Duration(seconds: 4),
//     VoidCallback? onUndo,
//   }) {
//     final scaffold = ScaffoldMessenger.of(context);
    
//     scaffold.hideCurrentSnackBar();
    
//     scaffold.showSnackBar(
//       SnackBar(
//         content: Toast(
//           message: message,
//           type: type,
//           onUndo: onUndo,
//           onDismiss: () {
//             scaffold.hideCurrentSnackBar();
//           },
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         padding: EdgeInsets.zero,
//         duration: duration,
//       ),
//     );
//   }
// }
