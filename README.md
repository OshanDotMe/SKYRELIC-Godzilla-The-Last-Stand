# 🦖 Godzilla The Last Stand (by SKYRELIC) 🎮

A fast-paced, action-packed 2D Pixel arcade boss-rush game developed from scratch using the **Godot 4 Engine**. Take control of ultimate powers and battle through waves of heavy military defenses and massive monster bosses! (King kong, Rodan, Mecha Godzilla, and King Ghidorah)

---

## Play the Game
The game is fully published and optimized to play directly in your browser or desktop:
👉 **[Play it now on Itch.io] :(https://skyrelic.itch.io/godzilla-the-last-stand)**

---

## ✨ Technical Highlights & Implementation
This repository showcases the complete core architecture, clean code practices, and system design behind the game:

*   **Cloud-Based Global Leaderboard:** Fully integrated with the **SilentWolf API** to handle real-time high score submissions and asynchronous global rankings securely.
*   **Scalable Enemy Logic & Pattern Design:** Dynamic custom logic for diverse enemy classes—ranging from ground-moving military units with custom detection range behaviors to flying and stationary multi-phase boss targets.
*   **Asynchronous State Optimization:** Optimized heavy combat coroutines using Godot’s asynchronous `await` architecture, cleanly utilizing robust thread/loop wrappers like `Engine.get_main_loop()` to safely prevent runtime engine crashes during rapid state or menu transitions.
*   **Layered Collision Architecture:** Fine-tuned precise `Area2D` collision layer masking to manage clean cross-node damage delivery profiles, allowing multi-hit player blast nodes to interact accurately with nested enemy hitbox frameworks.
*   **Context-Aware Dynamic Aiming:** Engineered a dynamic attack vector system for the player's primary weapon (Atomic Breath). By calculating the vertical delta between the mouse cursor's Y-position and the player node's eye-level coordinates, the system dynamically alters the projectile's trajectory container between a straight-line vector and a floor-sweeping vector.

---



---

## 🔒 Source Code Security Notice
*Please note: For security reasons, the underlying creative artwork folders (`art/`) containing binary textures and sound elements, alongside private SilentWolf cloud infrastructure secret 
keys, are hidden via `.gitignore` to protect intellectual property. The code uploaded here serves purely as a demonstration of technical programming proficiency, system design, and clean 
architectural structuring.*

---
Developed and maintained by **SKYRELIC** (Oshan Adithya). 
