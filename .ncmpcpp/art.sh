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

# SCRIPT
#########

kill_previous_instance() {
  script_name=${BASH_SOURCE[0]}
  for pid in $(pidof -x $script_name); do
    if [ $pid != $$ ]; then
        kill -9 $pid
    fi 
  done
}

setup_geometry() {
  ncmpcpp_geometry=$(xdotool search --class "ncmpcpp" getwindowgeometry | \
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

produce_window() {
  setup_geometry
  setup_files
  # Clean up previous cover files
  rm -f /tmp/mpdcover*

  # Scale the image
  foo=$(($side+1))
  convert "$src" -scale "$foo"x"$foo"^ -crop "$side"x"$side" "/tmp/mpdcover.png"

  # Apply corner rounding
  convert -size "$side"x"$side" xc:none -draw "roundrectangle 0,0,\
    $side,$side,$rounding,$rounding" png:- | convert /tmp/mpdcover-0.png \
    -matte - -compose DstIn -composite /tmp/mpdcover-0.png

  # Open Yad window
  yad --no-buttons --skip-taskbar --no-focus --posx=$left --posy=$top --image \
    "/tmp/mpdcover-0.png" --image-on-top --title=mpdcover &

  sleep .2
}

clean_up_windows() {
  while [[ "$(wmctrl -l | grep mpdcover | wc -l)" -gt $1 ]]
  do xdotool search --name mpdcover windowkill; done
}

adjust_window() {
  while true; do
    setup_geometry
    get_current_cover_geometry
    if [[ $top != $cover_top || $left != $cover_left ]]
    then
      xdotool search --name mpdcover windowmove $left $top
    fi
    if [[ $side != $cover_side ]]
    then
      clean_up_windows 0
      produce_window
    fi
    [[  $(wmctrl -lx) != *ncmpcpp* ]] && clean_up_windows 0
    sleep 5;
  done
}

get_current_cover_geometry() {
    cover_geometry=$(xdotool search --name "mpdcover" getwindowgeometry|tr\
      '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ')
    cover_left="$(cut -d' ' -f2 <<< "$cover_geometry")"
    cover_top="$(cut -d' ' -f3 <<< "$cover_geometry")"
    cover_side=$(($(cut -d' ' -f5 <<< "$cover_geometry")-8))
  }

kill_previous_instance
{
  produce_window
  clean_up_windows 1
  adjust_window
} &> /dev/null &
