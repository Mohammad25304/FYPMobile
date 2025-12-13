import 'package:flutter/material.dart';

class DetailsViewPage extends StatelessWidget {
  final String title;
  final String keyName;

  const DetailsViewPage({
    super.key,
    required this.title,
    required this.keyName,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController contentController = TextEditingController(
      text: "Content for $title will come from backend.",
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Content",
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {
                // TODO: Add API PUT /details/{key}
                print("Saving: $keyName");
                print("New content: ${contentController.text}");
              },
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
