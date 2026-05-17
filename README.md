### For IBM Bob Hackathon 2026
•Team: Kusyuk
•Team Member:Muhammad Ku Sukry Muhammad Mustafa

---

# PromptDojo: The Architect's Awakening

### Turn Your Vibe-Coding into Cost-Effective Architecture.

`PromptDojo` is a gamified visual novel and simulator designed to train developers in efficient, cost-effective prompt engineering. It tackles the costly enterprise problem of developers wasting LLM API quota through unstructured "vibe-coding" by teaching them to draft architectural blueprints and apply constraints before prompting.

This project was built during the IBM BOB Hackathon, demonstrating how an intelligent development partner like IBM Bob can help builders at any skill level deliver solutions with greater efficiency, turning ideas into impact faster.

## 🚀 The Core Concept: Vibe-Coding vs. Architecture

Developers often interact with AI agents using vague commands like "Build me an app." This leads to massive context window hallucinations, multiple re-rolls, and a staggering waste of expensive API compute (Resource Units and Tokens).

`PromptDojo` transforms this into a game:

* **Vibe-Coding:** A chaotic process that burns your **Mana Reserves (API Quota)** rapidly on wild guesses.
* **Architecture:** A strategic approach where you first craft **Master Blueprints (PRDs)** and attach relevant context, which anchors the AI's magic, uses minimal mana, and produces clean, correct code in a single attempt.

The goal is not to create a finished product, but to simulate the **prompts vs. quota limit** reality of production LLM integration.

### Business Value

In an enterprise environment, unoptimized prompting scales terribly. `PromptDojo` acts as an interactive onboarding tool to train teams on responsible and efficient AI usage, leading to direct and measurable cost savings.

## 🛠️ Actual Development Journey

This section outlines the steps taken from concept to the final, working MVP. We reconciled the initial `development-plan.md` with the completed items in `todo.md` to show the final execution pathway.

### MVP Scope Completed

1. **Project Initialization & Architecture:**
* [X] Established a new Flutter project (`prompt_dojo`) optimized for a mobile-first UI but deployable via Flutter Web.
* [X] Set up a Clean Architecture directory structure (`lib/features`, `lib/core`, `lib/shared`).
* [X] Integrated **Riverpod** for robust state management.
* [X] Scaffolding for key game-feel libraries (`animated_text_kit`, `audioplayers`, `flutter_dotenv`).


2. **State Management:**
* [X] Created the core game state notifier using Riverpod to track `manaReserves` (initialized at 1000), `hasBlueprint`, `contextCost`, and `currentStoryNode`.


3. **Core UI & Animations:**
* [X] Implemented the main mobile-style game scaffold.
* [X] Created the **Dynamic Mana Bar** using `TweenAnimationBuilder` to smoothly animate Mana depletion.
* [X] Built the **Typewriter Dialogue Box** with the `animated_text_kit` package.
* [X] Developed the **Interaction Area** that toggles between story choices and a multiline prompt text field.


4. **Game Logic:**
* [X] Built a local state management algorithm to handle in-game branching, dialogue tree navigation, and local mana penalties (e.g., penalty for skipping a blueprint, `contextCost` for a data-dump).


5. **watsonx.ai Integration:**
* [X] Created the necessary REST API services and placeholder classes in `core/` to securely manage the project ID, endpoints, and IAM authentication, ensuring no API keys were committed to the repository.
* [X] Generated a few-shot evaluation **System Prompt** for the `granite-4-h-small` model to score and provide character-specific feedback on player prompts.



### Technical Stack

* **Frontend:** Flutter (compiled to Flutter Web).
* **State Management:** Riverpod.
* **AI Inference:** IBM watsonx.ai (`granite-4-h-small` model).
* **UI/UX/Animations:** Standard Flutter Widgets (`AnimatedContainer`, `TweenAnimationBuilder`), `animated_text_kit`, `audioplayers`.
* **Build Partner:** IBM Bob IDE.

## 🧠 How IBM Bob Empowered This Project

This project was built with IBM Bob IDE as an essential and intelligent coding partner. Bob was not just a tool, but a true collaborator, accelerating development by:

1. **Literate Coding:** Bob took high-level functional descriptions written in natural language comments and instantly generated the correct, compilable Flutter widget boilerplate, complete with correct state management hooks for Riverpod. This radically reduced the time spent on manual coding.
2. **Architectural Integrity:** Bob ensured that the Clean Architecture project structure and directory patterns were strictly followed across all feature and core directories.
3. **State Management scaffolding:** Bob generated the entire foundational Riverpod state notifier class based on a single functional description, saving hours of boilerplate and state immutability setup.

### Specific Examples of Bob in Action (from Session Logs)

Our session log `bob_task_may-16-2026_3-20-22-pm.md` provides direct proof of this collaboration. Here are key examples of how we used Bob:

#### Example 1: Project Initialization and Architecture

We started the project with a complex request to set up the entire foundation.

> **User Prompt (from Log):** `Help me initialize a new Flutter project named "PromptDojo". [...] We MUST adhere to the following [...] Clean Architecture [...] State Management: Riverpod [...] create a baseline state notifier using Riverpod to track [...] manaReserves [...] Please generate the pubspec.yaml, basic folder structure, and a functional main.dart...`

**IBM Bob Response:** Instantly generated a `pubspec.yaml` with the exact dependencies (`flutter_riverpod`, `animated_text_kit`, etc.) and a complete `main.dart` that scaffolded the `ProviderScope` and Clean Architecture directory structure. This reduced a 30-minute boilerplate task to less than a minute.

#### Example 2: Core State Management

> **User Prompt (from Log):** `Create the foundational Riverpod state notifier for the PromptDojo game. Name the notifier ManaStateNotifier... initialize manaReserves at 1000, hasBlueprint to false... The state class should be immutable.`

**IBM Bob Response:** Bob generated a perfectly structured `game_state.dart` with an immutable `ManaState` class and a `ManaStateNotifier` that handled the complex task of properly initializing and managing the local game state, including the placeholder methods for later integration.

#### Example 3: system Prompt Engineering for watsonx.ai

The user used Bob to generate not just code, but the sophisticated prompt necessary for the AI's internal logic.

> **User Prompt (from Log):** `Help me generate the system prompt for watsonx.ai to evaluate a player's prompt in the PromptDojo simulator. The AI must act as "Archmage Bob"... and score prompts from 1-10... It must strictly output JSON.`

**IBM Bob Response:** Bob provided the detailed, few-shot evaluation prompt, including specific examples of "vague, chaotic vibe-coding" versus "well-structured, constrained Architect-level prompting." This ensured that the granite model would return consistent, well-formatted JSON scores and character feedback directly to the game's state manager.

## 🎥 Demo

You can play the hosted MVP demo of `PromptDojo` directly in your browser without any installation:
** https://promptdojo-hackathon.netlify.app/ **


## Demo Limitation 

Since the demo relied on IBM Watsonx Ai's Watsonx Hackathon Sandbox, the session is shorter. PrompDojo will generate a generic feedback and manual evaluation if the the session expired or not available.

To test locally:

flutter run \
  --dart-define=WATSONX_API_KEY=your_sandbox_key_here \
  --dart-define=WATSONX_PROJECT_ID=your_project_id_here \
  --dart-define=WATSONX_ENDPOINT=https://us-south.ml.cloud.ibm.com \
  --dart-define=WATSONX_MODEL_ID=ibm/granite-4-h-small


## 🛣️ Future Roadmap

While the local game state management provided a zero-latency, bulletproof demo for this hackathon, we have a clear vision for the V2 enterprise architecture:

* **watsonx Orchestrate Integration:** We will migrate all game state tracking and logic from the client to a centralized **IBM watsonx Orchestrate** agent. Orchestrate will manage developer mana Organization-wide. If a developer continuously drains their API quota through inefficient prompting, the Orchestrate agent can automatically trigger and assign a mandatory prompt-engineering training module within the company's HR system.
* **Expand Gameplay:** We will include more agentic coding aspect on the gameplay such as SKILLS, MCP etc.