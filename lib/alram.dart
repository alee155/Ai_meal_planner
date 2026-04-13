import 'package:flutter/material.dart';
import 'notification_service.dart';

class TimePickerScreen extends StatefulWidget {
  const TimePickerScreen({super.key});

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {
  TimeOfDay? selectedTime;
  late final TextEditingController _titleController;
  late final TextEditingController _instructionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: NotificationService.defaultTitle,
    );
    _instructionController = TextEditingController(
      text: NotificationService.defaultInstruction,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alarm Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Alarm name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Meal instruction',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              selectedTime == null
                  ? "No time selected"
                  : "Selected: ${selectedTime!.format(context)}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: const Text("Pick Time"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedTime != null) {
                  try {
                    await NotificationService.scheduleReminder(
                      hour: selectedTime!.hour,
                      minute: selectedTime!.minute,
                      title: _titleController.text,
                      instruction: _instructionController.text,
                    );

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Reminder set successfully"),
                      ),
                    );
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to set reminder: $error")),
                    );
                  }
                }
              },
              child: const Text("Set Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}
