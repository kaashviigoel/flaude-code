import 'package:flutter/material.dart';

void main() {
  runApp(const MausamApp());
}

class MausamApp extends StatelessWidget {
  const MausamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mausam',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Outfit',
        scaffoldBackgroundColor: const Color(0xFFF4F5F2),
      ),
      home: const PersonaSelectionScreen(),
    );
  }
}

class PersonaSelectionScreen extends StatefulWidget {
  const PersonaSelectionScreen({super.key});

  @override
  State<PersonaSelectionScreen> createState() =>
      _PersonaSelectionScreenState();
}

class _PersonaSelectionScreenState
    extends State<PersonaSelectionScreen> {
  String? selectedPersona;

  final List<String> personas = [
    'Health',
    'Fitness',
    'Traveller',
    'Family',
    'Commuter',
    'Gardening',
    'Beach',
    'Events',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MAUSAM',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Weather, made for you.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 54),

              const Text(
                'What matters to you?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Choose what you want Mausam to prioritize.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: GridView.builder(
                  itemCount: personas.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  itemBuilder: (context, index) {
                    final persona = personas[index];
                    final isSelected =
                        selectedPersona == persona;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPersona = persona;
                        });
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFCD00)
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFCD00)
                                : Colors.black12,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          persona,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedPersona == null
                      ? null
                      : () {
                          debugPrint(
                            'Selected persona: $selectedPersona',
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFFCD00),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        Colors.black12,
                    disabledForegroundColor:
                        Colors.black38,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}