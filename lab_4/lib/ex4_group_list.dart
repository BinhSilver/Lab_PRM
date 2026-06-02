import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Ex4GroupList(),
  ));
}

class Member {
  final String name;
  final Color avatarColor;

  const Member({required this.name, required this.avatarColor});

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class TeamGroup {
  final String teamName;
  final List<Member> members;

  const TeamGroup({required this.teamName, required this.members});
}

class Ex4GroupList extends StatelessWidget {
  const Ex4GroupList({super.key});

  static final List<TeamGroup> _groups = [
    TeamGroup(teamName: 'Team A', members: [
      Member(name: 'Klay Lewis', avatarColor: Color(0xFFE91E8C)),
      Member(name: 'Ehsan Woodard', avatarColor: Color(0xFF9C27B0)),
      Member(name: 'River Bains', avatarColor: Color(0xFF9E9E9E)),
    ]),
    TeamGroup(teamName: 'Team B', members: [
      Member(name: 'Toyah Downs', avatarColor: Color(0xFFE53935)),
      Member(name: 'Tyla Kane', avatarColor: Color(0xFF00BFA5)),
    ]),
    TeamGroup(teamName: 'Team C', members: [
      Member(name: 'Marcus Romero', avatarColor: Color(0xFFFF9800)),
      Member(name: 'Farrah Parkes', avatarColor: Color(0xFF7B1FA2)),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    // Build flat list of widgets
    final List<Widget> items = [];
    for (final group in _groups) {
      // Group header
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            group.teamName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      );

      // Members
      for (int i = 0; i < group.members.length; i++) {
        final member = group.members[i];
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: member.avatarColor,
                  child: Text(
                    member.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(fontSize: 15),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: () {},
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Group List View Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(children: items),
    );
  }
}
