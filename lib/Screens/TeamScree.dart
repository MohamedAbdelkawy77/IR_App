import 'package:flutter/material.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  // FIXED: Make it static const to avoid runtime type errors
  static const List<Map<String, String>> teamMembers = [
    {
      "name": "Mohamed Abdelkawy",
      "role": "Flutter & Blockchain Developer",
    },
    {
      "name": "Mahmoud Emad Nouh",
      "role": "Fullstack Developer",
    },
    {
      "name": "Mohamed Mohsen",
      "role": "Senior AI Engineer",
    },
    {
      "name": "Mohamed Hisham",
      "role": "Back-end .NET Developer",
    },
    {
      "name": "Fahd Mohamed",
      "role": "Back-end .NET Developer",
    },
    {
      "name": "Akmal Emad",
      "role": "Front-end Developer",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Our Lovely Team",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFa18cd1),
              Color(0xFFfbc2eb),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Meet the wonderful hearts behind this project",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade900,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: teamMembers.length,
                  itemBuilder: (context, index) {
                    final member = teamMembers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TweenAnimationBuilder(
                        duration: Duration(milliseconds: 600 + index * 120),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (_, double value, __) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 40 * (1 - value)),
                              child: _buildTeamCard(
                                name: member["name"]!,
                                role: member["role"]!,
                                index: index,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard({
    required String name,
    required String role,
    required int index,
  }) {
    final gradients = [
      [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
      [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
      [Color(0xFFfad0c4), Color(0xFFffd1ff)],
      [Color(0xFFffecd2), Color(0xFFfcb69f)],
      [Color(0xFFff9a9e), Color(0xFFfad0c4)],
      [Color(0xFFd299c2), Color(0xFFfef9d7)],
    ];

    final gradientColors = gradients[index % gradients.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradientColors),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(
                      name
                          .split(' ')
                          .map((e) => e[0])
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: gradientColors[0],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ),
                ),
         
              ],
            ),
          ),
        ),
      ),
    );
  }
}
