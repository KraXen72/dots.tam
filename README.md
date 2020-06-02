# dotfiles

![workflow](workflow.gif)

## Workflow

### Pseudo-tiling / manual tiling / programmatic floating

Classical tiling, well, isn't my thing. With programmatic floating, I spend near-zero time positioning my windows. They are always in the same place, so my eyes always know where to go. And my window layout is always well-rounded. There may be times that some screen estate is taken up by unused terminals, but I strongly belive that there is such a thing as an overly large window, and that my browser and terminals are roughly all the ideal size.

Classical tiling is way more flexible, at the cost of frequently having windows at unusable sizes in unusable positions. This requires you to get in there and adjust things. Of course, carefully scripted sets of rules can make tiling highly efficient. But despite the complexity of my current programmatic floating scripts, it started out very lean yet usable.

Those are the ways that I utilize programmatic floating:

* App launching is done through a wrapper script that positions apps in hardcoded presets after launching them.
* Keybinds can re-position any window to any preset position -- this is usually used to "tab" extra applications onto the same grid cell as another window.
* Each workspace possesses different window position presets.

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
