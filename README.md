# Bashrc Script Custom

An interactive tool to quickly and cleanly customize your `~/.bashrc` or `.profile` or `.zsh` file with aliases, functions, and modular configurations via a command-line interface inspired by Vue CLI.

---

## How to install
```bash
# Import de ta clé publique
curl -fsSL https://moonlight58.github.io/moon-apt-repo/public.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/moon-apt-repo.gpg

# Ajout du dépôt
echo "deb [arch=amd64] https://moonlight58.github.io/moon-apt-repo stable main" | sudo tee /etc/apt/sources.list.d/moon-apt-repo.list

# Mise à jour
sudo apt update
sudo apt install bashrc-script-custom
```

## How to use
```bash
bashrc-script-install
```
And boom, it's done :O

## Authors

- [moonlight58](https://github.com/moonlight58)

---

## License

MIT