# dotfiles

![workflow](workflow.gif)

## Workflow

### Pseudo-tiling / manual tiling

wip

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
