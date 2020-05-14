#!/bin/bash
# TAM/LPF'S NCMPCPP ALBUM ART (_really_ hacky)

# Dynamically positions the cover image in a Yad window,

# INSTRUCTIONS FOR OPTIMAL USE
# 1. FILL in the settings below.
# 2. SAVE file to ~/.ncmpcpp/art.sh, make it executable (chmod +x art.sh),
# put in ~/.ncmpcpp/config:
# execute_on_song_change="/path/to/this/file"
# 3. IF possible, set your WM to have undecorated Yad widget window
# and have the ncmpcpp window always below the Yad window.
# 4. PUT in ~/.config/gtk-3.0/gtk.css ->
# yad-dialog-window,
# yad-dialog-window decoration,
# yad-dialog-window decoration:backdrop {
#  background-color: [your terminal background color];
#  border: 0;
#  padding: 0;
# }
# 5. PUT in Compton/Picom settings (Picom: ~/.config/picom/picom.conf)
# shadow-exclude = [
#    "name = 'mpdcover'",
# ];

# SETTINGS
music_dir=$HOME/music # mpd music library directory
fallback="$HOME/.ncmpcpp/catnoelle.png" # image used if no cover is found
rounding=15 # Corner rounding
margin_top=55 
margin_bottom=30
margin_right=20
sleep .2 # Consider increasing this if the script glitches on opening

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

main() {
  kill_previous_instance &> /dev/null
  {
    make_cover_window
    sleep .2
    close_cover_windows_down_to 1
    adjust_window
  } &> /dev/null &
}

kill_previous_instance() {
  local script_name=${BASH_SOURCE[0]}
  for pid in $(pidof -x $script_name); do
    if [ $pid != $$ ]; then
        kill -9 $pid
    fi 
  done
}

make_cover_window() {
  get_ncmpcpp_geometry
  setup_files
  clean_up_tmp
  scale_cover
  round_cover_corners
  yad --no-buttons --skip-taskbar --no-focus --posx=$left --posy=$top --image \
    "/tmp/mpdcover-0.png" --image-on-top --title=mpdcover &
}

close_cover_windows_down_to() {
  while [[ $(wmctrl -l | grep mpdcover | wc -l) -gt $1 ]]
  do xdotool search --name mpdcover windowkill; done
}

adjust_window() {
  while sleep 1; do
    get_ncmpcpp_geometry
    get_current_cover_geometry

    if has_ncmpcpp_been_quit; then
      close_cover_windows_down_to 0
      exit
    fi

    if has_ncmpcpp_been_moved; then
      xdotool search --name mpdcover windowmove $left $top
    fi

    if has_ncmpcpp_been_resized; then
      close_cover_windows_down_to 0
      make_cover_window
    fi
  done
}

get_ncmpcpp_geometry() {
  ncmpcpp_geometry=$(xdotool search --name ncmpcpp getwindowgeometry | \
    tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ')
  ncmpcpp_left="$(cut -d' ' -f2 <<< "$ncmpcpp_geometry")"
  ncmpcpp_top="$(cut -d' ' -f3 <<< "$ncmpcpp_geometry")"
  ncmpcpp_width="$(cut -d' ' -f5 <<< "$ncmpcpp_geometry")"
  ncmpcpp_height="$(cut -d' ' -f6 <<< "$ncmpcpp_geometry")"
  side=$(($ncmpcpp_height-$margin_top-$margin_bottom))
  top=$(($ncmpcpp_top+$margin_top))
  left=$(($ncmpcpp_left+$ncmpcpp_width-$side-$margin_right))
}

setup_files() {
  album="$(mpc --format %album% current)"
  file="$(mpc --format %file% current)"
  album_dir="${file%/*}"
  [[ -z "$album_dir" ]] && exit 1
  album_dir="$music_dir/$album_dir"
  covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f \
    \-iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\\(jpe?g\|png\|gif\|bmp\)" \; )"
  src="$(echo -n "$covers" | head -n1)"
  [[ -z "$src" ]] && src=$fallback
}

clean_up_tmp() {
  rm -f /tmp/mpdcover*
}

scale_cover() {
  foo=$(($side+1))
  convert "$src" -scale "$foo"x"$foo"^ -crop "$side"x"$side" "/tmp/mpdcover.png"
}

round_cover_corners() {
  if [[ $rounding -gt 0 ]]; then
    convert -size "$side"x"$side" xc:none -draw "roundrectangle 0,0,\
      $side,$side,$rounding,$rounding" png:- | convert /tmp/mpdcover-0.png \
      -matte - -compose DstIn -composite /tmp/mpdcover-0.png
  fi
}

get_current_cover_geometry() {
  cover_geometry=$(xdotool search --name "mpdcover" getwindowgeometry|tr\
    '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ')
  cover_left="$(cut -d' ' -f2 <<< "$cover_geometry")"
  cover_top="$(cut -d' ' -f3 <<< "$cover_geometry")"
  cover_side=$(($(cut -d' ' -f5 <<< "$cover_geometry")-8))
}

has_ncmpcpp_been_moved() {
  [[ $top != $cover_top || $left != $cover_left ]]
}

has_ncmpcpp_been_resized() {
  [[ $side != $cover_side ]]
}

has_ncmpcpp_been_quit() {
  [[ ! $(wmctrl -lx | awk '{print $5}') =~ ncmpcpp ]]
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
