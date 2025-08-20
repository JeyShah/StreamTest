import 'package:flutter/material.dart';

class VideoConfigDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final String? initialDeviceId;

  const VideoConfigDialog({
    Key? key,
    required this.onSubmit,
    this.initialDeviceId,
  }) : super(key: key);

  @override
  State<VideoConfigDialog> createState() => _VideoConfigDialogState();
}

class _VideoConfigDialogState extends State<VideoConfigDialog> {
  // Controllers & state
  late TextEditingController deviceIdController;
  // final TextEditingController deviceIdController = TextEditingController();
  final TextEditingController channelController = TextEditingController(text: "1");

  int liveStreamEncodingMode = 0;
  int liveStreamResolution = 5;
  int liveStreamKeyframeInterval = 30;
  int liveStreamTargetFrameRate = 25;
  int liveStreamTargetBitRate = 2048;

  int saveStreamEncodingMode = 0;
  int saveStreamResolution = 5;
  int saveStreamKeyframeInterval = 30;
  int saveStreamTargetFrameRate = 25;
  int saveStreamTargetBitRate = 2048;

  bool osdSubtitleOverlay = true;
  bool enableAudioOutput = true;

  @override
  void initState() {
    super.initState();
    deviceIdController = TextEditingController(text: widget.initialDeviceId ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configure Video Parameters"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Device & channel
            TextField(
              controller: deviceIdController,
              decoration: const InputDecoration(labelText: "Device ID"),
            ),
            TextField(
              controller: channelController,
              decoration: const InputDecoration(labelText: "Channel"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),
            const Text("Live Stream Settings", style: TextStyle(fontWeight: FontWeight.bold)),

            _buildDropdown("Encoding Mode", liveStreamEncodingMode, [0, 1, 2], (val) {
              setState(() => liveStreamEncodingMode = val!);
            }),
            _buildDropdown("Resolution", liveStreamResolution, [0, 1, 2, 3, 4, 5, 6], (val) {
              setState(() => liveStreamResolution = val!);
            }),
            _buildNumberField("Keyframe Interval", liveStreamKeyframeInterval, (val) {
              setState(() => liveStreamKeyframeInterval = val);
            }),
            _buildNumberField("Frame Rate", liveStreamTargetFrameRate, (val) {
              setState(() => liveStreamTargetFrameRate = val);
            }),
            _buildNumberField("Bit Rate (kbps)", liveStreamTargetBitRate, (val) {
              setState(() => liveStreamTargetBitRate = val);
            }),

            const SizedBox(height: 16),
            const Text("Save Stream Settings", style: TextStyle(fontWeight: FontWeight.bold)),

            _buildDropdown("Encoding Mode", saveStreamEncodingMode, [0, 1, 2], (val) {
              setState(() => saveStreamEncodingMode = val!);
            }),
            _buildDropdown("Resolution", saveStreamResolution, [0, 1, 2, 3, 4, 5, 6], (val) {
              setState(() => saveStreamResolution = val!);
            }),
            _buildNumberField("Keyframe Interval", saveStreamKeyframeInterval, (val) {
              setState(() => saveStreamKeyframeInterval = val);
            }),
            _buildNumberField("Frame Rate", saveStreamTargetFrameRate, (val) {
              setState(() => saveStreamTargetFrameRate = val);
            }),
            _buildNumberField("Bit Rate (kbps)", saveStreamTargetBitRate, (val) {
              setState(() => saveStreamTargetBitRate = val);
            }),

            const SizedBox(height: 16),
            const Text("Other Settings", style: TextStyle(fontWeight: FontWeight.bold)),

            SwitchListTile(
              title: const Text("OSD Subtitle Overlay"),
              value: osdSubtitleOverlay,
              onChanged: (val) => setState(() => osdSubtitleOverlay = val),
            ),
            SwitchListTile(
              title: const Text("Enable Audio Output"),
              value: enableAudioOutput,
              onChanged: (val) => setState(() => enableAudioOutput = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit({
              "deviceId": deviceIdController.text,
              "channel": int.tryParse(channelController.text) ?? 1,
              "liveStreamEncodingMode": liveStreamEncodingMode,
              "liveStreamResolution": liveStreamResolution,
              "liveStreamKeyframeInterval": liveStreamKeyframeInterval,
              "liveStreamTargetFrameRate": liveStreamTargetFrameRate,
              "liveStreamTargetBitRate": liveStreamTargetBitRate,
              "saveStreamEncodingMode": saveStreamEncodingMode,
              "saveStreamResolution": saveStreamResolution,
              "saveStreamKeyframeInterval": saveStreamKeyframeInterval,
              "saveStreamTargetFrameRate": saveStreamTargetFrameRate,
              "saveStreamTargetBitRate": saveStreamTargetBitRate,
              "osdSubtitleOverlay": osdSubtitleOverlay ? 1 : 0,
              "enableAudioOutput": enableAudioOutput ? 1 : 0,
            });
            
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, int current, List<int> options, ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int>(
      value: current,
      decoration: InputDecoration(labelText: label),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField(String label, int current, ValueChanged<int> onChanged) {
    return TextFormField(
      initialValue: current.toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (val) => onChanged(int.tryParse(val) ?? current),
    );
  }
}

// Usage:
// showDialog(
//   context: context,
//   builder: (_) => VideoConfigDialog(
//     onSubmit: (data) {
//       print("Final config: $data");
//       // call your API here
//     },
//   ),
// );