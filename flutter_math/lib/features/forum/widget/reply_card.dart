import 'package:flutter/material.dart';
// Pastikan path ini sesuai dengan tempat Anda menyimpan reply_model.dart
import 'package:flutter_math/features/forum/model/reply_model.dart';

class ReplyCard extends StatelessWidget {
  final ReplyModel reply;
  final VoidCallback onReplyTap;

  const ReplyCard({
    super.key, 
    required this.reply, 
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // Garis kiri untuk menandakan ini adalah balasan (nested)
        border: Border(
          left: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Pengguna
          Text(
            reply.user.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 4),
          // Isi Balasan
          Text(
            reply.body,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          // Tombol Balas
          GestureDetector(
            onTap: onReplyTap,
            child: const Text(
              "Balas",
              style: TextStyle(
                color: Colors.blue, 
                fontSize: 12, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // RENDER ANAK BALASAN (Recursive Logic)
          // Jika ada balasan di dalam balasan ini, panggil ReplyCard lagi
          if (reply.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: reply.children.map((child) => ReplyCard(
                  reply: child, 
                  onReplyTap: onReplyTap,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}