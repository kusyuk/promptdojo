import '../../domain/entities/story_node.dart';

/// Represents a single story node with dialogue and choices
class StoryNodeData {
  final StoryNode id;
  final String dialogue;
  final String? speaker;
  final List<StoryChoice> choices;
  final bool isArchmageBob;

  const StoryNodeData({
    required this.id,
    required this.dialogue,
    this.speaker,
    this.choices = const [],
    this.isArchmageBob = false,
  });
}

/// Represents a choice the player can make
class StoryChoice {
  final String text;
  final void Function() onSelect;
  final bool isEnabled;
  final String? icon;

  const StoryChoice({
    required this.text,
    required this.onSelect,
    this.isEnabled = true,
    this.icon,
  });
}

// Made with Bob
