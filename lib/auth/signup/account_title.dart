import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const AccountTile({
    required this.name,
    required this.subtitle,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isActive ? Colors.blue : Colors.grey.shade300,
        child: Text(
          name[0],
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isActive
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
    );
  }
}
