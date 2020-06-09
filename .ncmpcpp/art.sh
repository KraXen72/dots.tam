#!/bin/bash
# No other shell than bash can be used with ueberzug

# Image will be wrongly positioned, if at all, when using a terminal with scrollbar or menubar.

# Seems to work on: (please report any bugs)
# alacritty
# urxvt
# kitty
# gnome-terminal (cover might display on the wrong terminal instance)

# Doesn't work on:
# konsole

# SETTINGS
music_library=$HOME/music # mpd music library directory
fallback="$HOME/.ncmpcpp/catnoelle.png" # image used if no cover is found

padding_top=3
padding_bottom=1
padding_right=2
reserved_playlist_cols=30

#font_height=16
#font_width=7
# TODO; guess font size more portably

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

main() {
    kill_previous_instance_of_this_script
    find_cover_image
    display_cover_image
    detect_window_resizes
}

kill_previous_instance_of_this_script() {
    script_name=$(basename "$0")
    for pid in $(pidof -x $script_name); do
        if [ $pid != $$ ]; then
            kill -15 $pid
        fi 
    done
}

find_cover_image() {
    album="$(mpc --format %album% current)"
    file="$(mpc --format %file% current)"
    album_dir="${file%/*}"
    [ -z "$album_dir" ] && exit 1
    album_dir="$music_library/$album_dir"
    covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f \
    -iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\\(jpe?g\|png\|gif\|bmp\)" \; )"
    src="$(echo "$covers" | head -n1)"
    [ -z "$src" ] && src=$fallback
}

display_cover_image() {
    unset LINES COLUMNS
    term_lines=$(tput lines)
    term_cols=$(tput cols)

    if [ -z "$font_height" ] || [ -z "$font_height" ]; then
        guess_font_size
    fi

    ueber_height=$(( term_lines - padding_top - padding_bottom ))
    ueber_width=$(( ueber_height * font_height / font_width ))
    ueber_left=$(( term_cols - ueber_width - padding_right ))

    if [ "$ueber_left" -lt "$reserved_playlist_cols" ]; then
        ueber_left=$reserved_playlist_cols
        ueber_width=$(( term_cols - reserved_playlist_cols - padding_right ))
    fi

    send_to_ueberzug \
        action "add" \
        identifier "mpd_cover" \
        path "$src" \
        x "$ueber_left" \
        y "$padding_top" \
        height "$ueber_height" \
        width "$ueber_width" \
        synchronously_draw "True" \
        scaler "forced_cover" \
        scaling_position_x "0.5"
}

detect_window_resizes() {
    {
        trap 'display_cover_image' WINCH
        while :; do sleep .1; done
    } &
}

guess_font_size() {
    term_width=$(wmctrl -lG | awk '$8 == "ncmpcpp" {print $5; exit}')
    term_height=$(wmctrl -lG | awk '$8 == "ncmpcpp" {print $6; exit}')

    approx_font_width=$(( term_width / term_cols ))
    approx_font_height=$(( term_height / term_lines ))

    term_xpadding=$(( ( - approx_font_width * term_cols + term_width ) / 2 ))
    term_ypadding=$(( ( - approx_font_height * term_lines + term_height ) / 2 ))

    font_width=$(( (term_width - 2 * term_xpadding) / term_cols ))
    font_height=$(( (term_height - 2 * term_ypadding) / term_lines ))
}

send_to_ueberzug() {
    old_IFS="$IFS"; IFS="$(printf "\t")"
    echo "$*" > "$FIFO_UEBERZUG"
    IFS=${old_IFS}
}

main >/dev/null 2>&1
