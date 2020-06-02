# dotfiles

![workflow](workflow.gif)

## Workflow

### Pseudo-tiling / manual tiling / programmatic floating

With programmatic floating, I spend near-zero time positioning my windows. Since they are always in the same place, my eyes always know where to go. And my window layout is always well-rounded. Windows are never too small or too large.

Tiling is more flexible, at the cost of frequently having unusable positioned windows, losing you time to get in there and adjust things. Carefully scripted rules can make tiling highly efficient, but despite the complexity of my current programmatic floating scripts, it started out very lean yet usable.

* App launching is done through a wrapper script that positions apps in hardcoded presets after launching them.
* Keybinds can re-position any window to any preset position -- this is usually used to "tab" extra applications onto the same grid cell as another window.
* Each workspace possesses different window position presets. Any time a workspace is switched to, its preset layout is applied to the open windows.

I use a tag system where windows can be in several workspaces at once. They are organised like so:

* **Workspace 1:** 80-column Vim (+ line and sign columns), web browser, weechat, ncmpcpp and ranger terminals
* **Workspace 2:** 2x80-column Vim, web browser
* **Workspace 3:** 2x80-column Vim, weechat, ncmpcpp and ranger terminals

### Per-application run-or-raise binds.

[Alt-tab is slow.](https://vickychijwani.me/blazing-fast-application-switching-in-linux/) Cardinal window switching is slow. Putting apps on dedicated workspaces is slow. 

Each window I use regularly has a dedicated bind that will jump to its workspace, raise and focus it. This takes the least amount of keystrokes of all window-switching solutions. If the window is closed (despite my startup script opening everything), that same bind will run the application and position it suitably.

* `super+w`: weechat/first terminal
* `super+b`: ncmpcpp/second terminal
* `super+t`: ranger/third terminal
* `super+f`: web browser
* `super+c`: vim
* `super+q`: any application that is none of the above

Should multiple instances be open, the bind will merely cycle between them, prioritising instances on the current workspace.

This is achieved using a slightly modified version of [jumpapp](https://github.com/mkropat/jumpapp).

![scrot](https://u.teknik.io/7BKDi.png)
