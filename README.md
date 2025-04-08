# 🛡️ Top-Down Tank Game

A top-down tank game inspired by *Battle City* (NES), built natively for Apple platforms using Swift, SpriteKit, and SwiftUI.

> ⚙️ Designed as a research project to explore game development on Apple platforms with native tools and frameworks — and to share the journey with other developers.

## 📌 Features

- 🔶 **Written in Swift** with **SpriteKit** for rendering and **SwiftUI** for UI overlays.
- 💻📱 **Supports macOS and iOS** — tvOS support is under consideration.
- 🧩 **Component-based gameplay architecture** — a lightweight micro-engine wraps `SKScene`, resembling an ECS (Entity-Component-System) approach.
- 🧠 **Procedurally generated levels** powered by the **Wave Function Collapse** algorithm.
- 🎮 Gameplay and aesthetics are **inspired by the classic Battle City** game for the NES.

## 🧪 Purpose

This is a research and exploration project aimed at:
- Understanding the feasibility and limitations of native game development tools on Apple platforms.
- Experimenting with gameplay architecture patterns and procedural generation.
- Sharing experiences, lessons learned, and code with fellow developers and game enthusiasts.

## 🔭 Roadmap / Future Plans

- 📋 Expand the in-game menu with **options and settings** (e.g., sound, controls, difficulty).
- 🎨 Upgrade or replace in-game art to improve visual appeal.
- 🧠 Enhance NPC behavior and AI logic.
- 🌳 Add environmental and visual decorations to enrich game scenes.
- 🛡️ Introduce different types of NPCs with varied behavior.
- 🧱 Expand the set of level building blocks for greater gameplay variety.
- 🎮 Add support for **gamepad controllers** across all platforms.

## 🚧 Project Status

> This project is still in early development. It is playable but experimental and subject to frequent changes. Contributions, feedback, and collaboration ideas are welcome!

## 📸 Screenshots

> _Coming soon..._

## 📦 Development Configuration

- Xcode 15 or later
- macOS 15 or iOS 18
- Swift 5.9

## 🧠 Procedural Generation

Levels in this game are procedurally generated using the **Wave Function Collapse (WFC)** algorithm.

To better understand and refine this technique, a separate application was developed as a dedicated research project: 

🔗 **[Wave Function Collapse](https://github.com/SergeyChelak/WaveFunctionCollapse)**  
> A standalone macOS application that implements the WFC algorithm in Swift.  
> It was created specifically as a research tool to support procedural level generation for this tank game.

This tool helped to experiment with rule sets, visualize constraints, and test the behavior of WFC outside of the game context, making it easier to iterate and improve the algorithm before integrating it into the gameplay system.

## 🤝 Contributing

Pull requests, issue reports, and general feedback are very welcome! Whether you're interested in game architecture, procedural generation, or just love tanks — feel free to jump in.

## 📝 License

This project is open source. License TBA.

---

🧠 Made with curiosity and ❤️ by a fellow game developer exploring native Apple tools.
