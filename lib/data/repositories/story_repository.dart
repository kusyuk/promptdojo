import '../models/story_node_data.dart';
import '../../domain/entities/story_node.dart';

/// Repository containing all story content from the PRD
///
/// This includes all dialogue, choices, and narrative text
/// for Acts 1-3 of PromptDojo
class StoryRepository {
  /// Get story node data by ID
  static StoryNodeData? getNodeData(StoryNode node) {
    return _storyNodes[node];
  }

  /// All story nodes mapped by ID
  static final Map<StoryNode, StoryNodeData> _storyNodes = {
    // ACT 1: The Reckless Apprentice (Tutorial)
    StoryNode.tutorial: StoryNodeData(
      id: StoryNode.tutorial,
      dialogue:
          'You are a novice coder with a dream: build the ultimate Global Trading App, '
          'get rich, and retire to the Silicon Mountains. Before you sits "The Scrying Terminal"—'
          'an ancient LLM artifact capable of writing reality itself. But magic comes at a cost.\n\n'
          'Approach the terminal and cast your first spell.',
      speaker: 'NARRATOR',
      isArchmageBob: false,
      choices: [],
    ),

    // Planning Phase
    StoryNode.planning: StoryNodeData(
      id: StoryNode.planning,
      dialogue:
          'Before you touch the terminal, you must decide how to begin. '
          'A true Architect never casts blindly.',
      speaker: 'ARCHMAGE BOB',
      isArchmageBob: true,
      choices: [],
    ),

    // Context Phase
    StoryNode.context: StoryNodeData(
      id: StoryNode.context,
      dialogue:
          'Now, you must attach the Scroll of Memory to your spell. '
          'The artifact needs context, but memory is heavy. What will you feed it?',
      speaker: 'ARCHMAGE BOB',
      isArchmageBob: true,
      choices: [],
    ),

    // Incantation Phase
    StoryNode.incantation: StoryNodeData(
      id: StoryNode.incantation,
      dialogue:
          'The moment of truth. Step up to the terminal. '
          'Type your spell to construct the Authentication Portal. '
          'Remember: clarity, constraints, and your role!',
      speaker: 'ARCHMAGE BOB',
      isArchmageBob: true,
      choices: [],
    ),

    // Bad Ending
    StoryNode.badEnding: StoryNodeData(
      id: StoryNode.badEnding,
      dialogue:
          'You have drained the company\'s entire API budget! '
          'The artifact has shut down to protect itself. Your chaotic vibe-coding '
          'has left us with half a broken app and a massive cloud computing bill.\n\n'
          'GAME OVER.\n\n'
          'Mana Wasted: 1000/1000\n'
          'Real-world equivalent: You burned \$500 in API tokens by sending massive '
          'context windows and vague prompts that required 15 re-rolls.\n\n'
          'Lesson: Unoptimized prompting scales terribly in enterprise environments.',
      speaker: 'ARCHMAGE BOB',
      isArchmageBob: true,
      choices: [],
    ),

    // Good Ending
    StoryNode.goodEnding: StoryNodeData(
      id: StoryNode.goodEnding,
      dialogue:
          'Behold! The portal is stable, the code is clean, and your Mana reserves '
          'are still glowing brightly. You didn\'t just write a prompt; you engineered a solution.\n\n'
          'VICTORY! YOU ARE NOW AN ARCHITECT.\n\n'
          'By drafting a PRD, limiting your context window, and writing a highly constrained prompt, '
          'you completed the feature in a single shot. You saved the company thousands of Resource Units.\n\n'
          'Lesson: AI is a tool, but YOU are the architect.',
      speaker: 'ARCHMAGE BOB',
      isArchmageBob: true,
      choices: [],
    ),
  };

  /// Get tutorial introduction dialogue
  static String get tutorialIntro =>
      'You are a novice coder with a dream: build the ultimate Global Trading App, '
      'get rich, and retire to the Silicon Mountains. Before you sits "The Scrying Terminal"—'
      'an ancient LLM artifact capable of writing reality itself. But magic comes at a cost.';

  /// Get tutorial forced prompt
  static String get tutorialForcedPrompt => 'Build me a global trading app.';

  /// Get tutorial aftermath dialogue
  static String get tutorialAftermath =>
      'A Chaos Distortion! The artifact hallucinated a massive, broken codebase. '
      'Your Mana is nearly depleted!';

  /// Get Archmage Bob introduction
  static String get bobIntroduction =>
      'Halt! Cease the incantation!\n\n'
      'Foolish apprentice! You cannot just walk up to the artifact and yell "build me an app"! '
      'You gave it no constraints. It had to guess your architecture, burning your precious Mana '
      'to hallucinate an answer!\n\n'
      'I am Archmage Bob. I am here to teach you the ways of the Architect. '
      'We shall start smaller. Your task: Build a simple "User Authentication Portal". '
      'And this time, we do it my way.';

  /// Get planning phase vibe-coder reaction
  static String get planningVibeCoder =>
      'Arrogance! The artifact will punish your lack of direction.';

  /// Get planning phase architect reaction
  static String get planningArchitect =>
      'Excellent. A well-documented Blueprint anchors the artifact\'s magic, '
      'preventing it from wandering into the shadows of hallucination.';

  /// Get context phase data dumper reaction
  static String get contextDataDumper =>
      'Madness! Forcing the artifact to read 10,000 scrolls for a simple login portal '
      'will drain your life force!';

  /// Get context phase precision caster reaction
  static String get contextPrecision =>
      'Precise. Elegant. You give it exactly what it needs, wasting no Sparks.';

  /// Get context phase amnesiac reaction
  static String get contextAmnesiac =>
      'It is an artifact, not a mind reader! Without context, it will invent its own rules.';

  /// Get incantation phase prompt
  static String get incantationPrompt =>
      'The moment of truth. Step up to the terminal. Type your spell to construct '
      'the Authentication Portal. Remember: clarity, constraints, and your role!';

  /// Get evaluating message
  static String get evaluatingMessage =>
      'Archmage Bob is evaluating your spell...';

  /// Get bad ending stats
  static String getBadEndingStats(
    int manaWasted, {
    bool hasBlueprint = false,
    int contextCost = 0,
  }) =>
      'You have drained the company\'s entire API budget! '
      'The artifact has shut down to protect itself. Your chaotic vibe-coding '
      'has left us with half a broken app and a massive cloud computing bill.\n\n'
      '💀 GAME OVER 💀\n\n'
      'Mana Wasted: $manaWasted/1000\n'
      'Real-world equivalent: You burned \$${(manaWasted * 0.5).toStringAsFixed(0)} '
      'in API tokens.\n\n'
      '📊 What Went Wrong:\n'
      '• Blueprint: ${hasBlueprint ? "Acquired ✓" : "Skipped ✗ (cost you 100 mana)"}\n'
      '• Context: ${_getContextDescription(contextCost)}\n'
      '• Prompt Quality: Poor (high mana cost)\n\n'
      '💡 Lesson: Unoptimized prompting scales terribly in enterprise environments.';

  /// Get good ending stats
  static String getGoodEndingStats(
    int manaRemaining, {
    bool hasBlueprint = false,
    int contextCost = 0,
  }) {
    String opening;
    if (manaRemaining >= 800) {
      opening =
          'Incredible! Your mastery of the scrying arts is unparalleled. '
          'The portal stands perfectly stable, anchored by your impeccable constraints.'
          '\n\n✨ VICTORY! YOU ARE NOW A TRUE ARCHITECT. ✨\n\n';
    } else if (manaRemaining >= 500) {
      opening =
          'Behold! The portal is stable, the code is clean, and your Mana reserves '
          'are still glowing brightly. You didn\'t just write a prompt; you engineered a solution.'
          '\n\n✨ NOT BAD. YOU ARE NOW AN AVERAGE ARCHITECT. ✨\n\n';
    } else if (manaRemaining >= 200) {
      opening =
          'The portal manifests, though the mana air is thin. '
          'The code is functional, but your technique was somewhat taxing on the artifact.'
          '\n\n✨ DISAPPOINTING! YOU ARE NOW A BAD ARCHITECT. ✨\n\n';
    } else {
      opening =
          'A narrow escape! The portal flickers with the last of your mana. '
          'The code is complete, but your reckless casting nearly doomed the project.'
          '\n\nTry harder next time.\n\n';
    }

    return '$opening\n\n'
        'By ${hasBlueprint ? "drafting a PRD" : "working without a plan"}, '
        '${_getContextDescription(contextCost)}, '
        'and writing a ${_getPromptQuality(manaRemaining)} prompt, '
        'you completed the feature.\n\n'
        '📊 Your Journey:\n'
        '• Final Mana: $manaRemaining/1000\n'
        '• Real-world savings: \$${(manaRemaining * 0.5).toStringAsFixed(0)} saved!\n\n'
        '💡 Lesson: AI is a tool, but YOU are the architect.';
  }

  static String _getContextDescription(int contextCost) {
    if (contextCost <= 10) return 'Precise context (optimal)';
    if (contextCost <= 50) return 'Minimal context (decent)';
    if (contextCost <= 150) return 'Comprehensive context (balanced)';
    return 'Excessive context (wasteful)';
  }

  static String _getPromptQuality(int remainingMana) {
    if (remainingMana >= 800) return 'legendary';
    if (remainingMana >= 600) return 'architect-level';
    if (remainingMana >= 400) return 'decent';
    if (remainingMana >= 200) return 'mediocre';
    return 'strained';
  }
}

// Made with Bob
