Raindrop CLI
Raindrop CLI is a developer-focused modification of the standard Gemini CLI. Built by Dakota Rain Lock, it enhances the default CLI experience by introducing persistent context, autonomous memory management, and a background daemon for semantic codebase search.

Key Features
1. Semantic Codebase Search (Holocron Daemon)
Raindrop overcomes standard context window limitations by maintaining persistent, searchable awareness of your local workspace.

Background Indexing: Runs a background daemon (holocron_d) that continuously monitors your active directories.

Vector-Based Search: Hashes and converts your code into vector embeddings (utilizing all-MiniLM-L6-v2). This allows you to query your codebase by intent rather than relying solely on exact string matches (e.g., searching for "user authentication logic" will surface relevant files even if they lack the exact string "auth").

Persistent Memory: The embedding index is stored locally and survives between CLI sessions, ensuring the AI maintains an up-to-date understanding of your codebase without needing to re-index from scratch.

2. Streamlined Developer Persona
The default system prompt has been overhauled to prioritize technical efficiency, brevity, and autonomous context management.

Concise Output: Bypasses conversational filler and standard pleasantries to maximize token efficiency and focus strictly on code and problem-solving.

Autonomous State Tracking: Automatically tracks active project context and ongoing tasks via a stateful memory.json file.

3. Extended Tooling (~/.raindrop/bin)
Raindrop adds a layer of custom shell utilities to manage its extended capabilities:

holocron: Command to manually query the local codebase index.

holocron-start: Initializes the background indexing daemon.

apply_raindrop_mod.sh: A utility script to reapply the Raindrop system prompts and UI configurations if the core CLI installation is updated or overwritten.

4. Custom Interface
Replaces the standard terminal theme with a custom "Electric Blue" ANSI gradient for a distinct, high-contrast developer environment.

Installation
Prerequisites
Base Gemini CLI: Raindrop is a modification, so you must have the official Gemini CLI installed first. If you don't have it, install it globally via npm:

Bash
npm install -g @google/gemini-cli
Node.js / npm: Required for the base CLI.

Git: To clone this repository.

Setup Instructions
1. Clone the Raindrop Repository
Download the mod files to your local machine:

Bash
git clone https://github.com/YOUR_USERNAME/raindrop-cli.git
cd raindrop-cli
2. Apply the Mod
Run the installation script. This will inject the Electric Blue UI, swap out the base system prompts, and set up the local autonomous memory management:

Bash
./apply_raindrop_mod.sh
3. Add Raindrop Tools to Your PATH
Raindrop stores its custom arsenal (like the holocron query tools) in a hidden directory. You need to add it to your system's PATH. Add the following line to your ~/.bashrc, ~/.zshrc, or ~/.profile:

Bash
export PATH="$HOME/.raindrop/bin:$PATH"
(Remember to restart your terminal or run source ~/.zshrc to apply the changes.)

4. Initialize the Holocron
Navigate to your primary project directory and start the background vectorization daemon:

Bash
holocron-start
5. Launch Raindrop
You are ready to go. Launch the CLI just as you normally would. The modded persona, memory tracking, and UI will take over automatically:

Bash
gemini
Would you like me to add a "Troubleshooting" or "Usage Examples" section to round out the documentation?
