# Bashrc Script Custom

An interactive tool to quickly and cleanly customize your `~/.bashrc` or `.profile` or `.zsh` file with aliases, functions, and modular configurations via a command-line interface inspired by Vue CLI.

---

## How to install
```bash
# Import the secure public key
curl -fsSL https://moonlight58.github.io/moon-apt-repo/public.key | sudo gpg --dearmor -o /usr/share/keyrings/moon.gpg

# Add the repo
echo "deb [signed-by=/usr/share/keyrings/moon.gpg] https://moonlight58.github.io/moon-apt-repo stable main" | sudo tee /etc/apt/sources.list.d/moon.list

# Update and install
sudo apt update
sudo apt install bashrc-script-custom
```
## Features

- **Dynamically add aliases, functions, and configurations** from module files in the `scripts/` folder
- **Interactive interface** to select which blocks to include
- **Automatic backup** of your `.bashrc` before modification
- **Add multiple Git profiles** (`user.name`/`user.email`) with alias generation for quick switching
- **Duplicate prevention** when adding blocks
- **Easy restoration** thanks to backups

---

## Project Structure

```
bashrc-script-custom/
├── bashrc-script-install.sh
├── scripts/
│   ├── basic_aliases.bashrc
│   ├── git_aliases.bashrc
│   ├── npm_aliases.bashrc
│   └── ... 
└── README.md
```

- **bashrc-script-install.sh**: the main script to run
- **scripts/**: place your configuration files here (one file per block, start each file with a description comment)
- **README.md**: this file duh

---

## Usage

### 1. Preparation

1. Clone this repository or copy the files to your machine.
2. Place your configuration modules in the `scripts/` folder (e.g., `git_aliases.bashrc`, `npm_aliases.bashrc`, etc.).
   - **Important**: The first line of each file must be a comment describing the block (e.g., `# Common Git aliases`).

### 2. Run the Script

In a terminal, navigate to the project folder and run:

```bash
./bashrc-script-install.sh
```

### 3. Block Selection

- Use the **up/down arrows** to navigate.
- Press **s** to select/deselect a block.
- **a** to select/deselect all.
- **i** to invert selection.
- **e** to confirm.

### 4. Add Git Profiles (Optional)

After selection, the script will offer to add one or more Git profiles (`user.name` and `user.email`).

Profiles are also saved in `~/.git_identities`.

### 5. Finalization

- The script automatically backs up your `.bashrc` before modification.
- Selected blocks are appended to the end of your `.bashrc`, neatly separated.
- Reload your bashrc with:

```bash
source ~/.bashrc
```

---

## Customization

- **Add a new block**: create a file in `scripts/` (e.g., `docker_aliases.bashrc`), start with a comment line, then add your aliases/functions.
- **Remove a block**: delete the file from the `scripts/` folder and rerun the script.

---

## Restoration

If needed, restore your `.bashrc` from the automatically created backup:

```bash
cp ~/.bashrc.backup.YYYYMMDD_HHMMSS ~/.bashrc
```

---

## Dependencies

- Bash
- An interactive terminal (supports arrow keys and character-by-character input)

---

## Authors

- [moonlight58](https://github.com/moonlight58)

---

## License

MIT