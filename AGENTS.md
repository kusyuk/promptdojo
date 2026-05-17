# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Context
PromptDojo is a gamified visual novel for IBM Bob Hackathon teaching prompt engineering through interactive gameplay. The app uses Flutter for mobile-first development but compiles to **Flutter Web for submission** (not native mobile deployment).

## Critical Architecture Decisions

### State Management & Game Logic
- **Riverpod** is the chosen state management (not Provider, Bloc, or GetX)
- Game state calculations happen **client-side before API calls** to watsonx.ai
- Core state variables: `manaReserves` (int, starts at 1000), `hasBlueprint` (bool), `contextCost` (int), `currentStoryNode` (enum/string)
- Penalty calculation formula: `(10 - api_quality_score) * 40`, multiply by 2 if `hasBlueprint == false`

### API Integration (watsonx.ai)
- Uses IBM watsonx.ai **granite-4-h-small** model (not GPT or other LLMs)
- Requires: Project ID, Dallas Region Endpoint URL, IAM Access Token (from IBM Cloud API Key)
- API must return **strict JSON only**: `{"quality_score": <1-10>, "archmage_feedback": "<string>"}`
- System prompt enforces character-based feedback as "Archmage Bob" with magic/mana metaphors

### UI Implementation Constraints
- **NO Flame game engine** - uses standard Flutter widgets only (AnimatedContainer, TweenAnimationBuilder, SlideTransition, FadeTransition)
- Required packages: `animated_text_kit` (typewriter effect), `audioplayers` (SFX)
- Visual novel layout: Top HUD (mana bar), Center Stage (backgrounds/characters), Bottom Panel (dialogue/input)
- Mobile-first design but must work in web browser for judging

### Asset Requirements
- Sound effects: `/assets/sounds/start.mp3`, `/assets/sounds/wrong.mp3`
- Bob mascot SVG: `/assets/images/bob_mascot.svg`
- Dark programmer-themed backgrounds required

## Testing
- Uses `flutter_test` from SDK (standard Flutter testing)
- Run tests: `flutter test`
- No custom test configuration beyond `flutter_lints: ^6.0.0`

## Build Commands
- Web build (primary target): `flutter build web`
- Run locally: `flutter run -d chrome` or `flutter run -d web-server`
- Lint: Uses `package:flutter_lints/flutter.yaml` (no custom rules)

## Story Flow (Non-Obvious)
The PRD defines exact dialogue nodes and state transitions. When implementing:
- Act 1 forces a bad prompt (tutorial), deducts 800 mana immediately
- Act 2 has 3 decision nodes (planning, context, incantation) - each affects final score
- Act 3 endings trigger at `manaReserves <= 0` (bad) or `> 0` (good)
- All narrative text must match PRD tone: technical metaphors, "Archmage Bob" character voice