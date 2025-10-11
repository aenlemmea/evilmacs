### Evilmacs

My personal fully evil emacs config. Using Lucid GUI-Kit for GNU Emacs.

> [!NOTE]  
> Yes, I am aware that loading evil directly in `early-init.el` is a terrible terrible idea. However I need it. I hate when `init.el` breaks due to a change and I can no longer stay in evil mode. And yes, I am aware I can separate into a file and load it in init.el which does solve my issue but at the cost of a fragmented config file which I do not want.

### Core Goals

- **Delegate configuration to only two files** (`init.el` and `early-init.el`): I do not use emacs for anything besides editing and running a few commands, I do not need multiple files to handle everything separately either. Multiple file based management is good but too high effort to maintain it right.
- **Speed**: Currently with my config, emacs opens fairly quick in both GUI and Terminal mode (Benchmarks TBD) where it is reasonably close to my old vim (NOT neovim) setup without having to make the config terribly unreadable with speed hacks. There is still some delay but it is not super noticiable.

### Packages Used

1. Eglot (Built-in)
2. Company (Built-in)
3. Dired (Built-in)
4. Evil
5. Evil-Collection