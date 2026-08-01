#!/usr/bin/env bash
# https://github.com/Ao1Pointblank/rofi-search


###configuration

ENGINES_DIR=~/.local/opt/rofi-search-engines/
ENGINE_DEFAULT="Brave"
PRIVATE_MODE_TEXT="Press ENTER to use private browser window, or type query for normal search"

#browser commands
DEFAULT_BROWSER="flatpak run app.zen_browser.zen"
DEFAULT_PRIVATE_BROWSER="flatpak run app.zen_browser.zen --private-window"


###engine select

#generate list with svg icons
ENGINE_SELECT=$(ls "$ENGINES_DIR" | while read -r A; do
    if [[ -f "$ENGINES_DIR/.ICONS/$A.svg" ]]; then
        echo -en "$A\x00icon\x1f$ENGINES_DIR/.ICONS/$A.svg\n"
    else
        echo "$A"
    fi
done | rofi -dmenu -p "Search" -i -selected-row 2 -l "$(ls -1 "$ENGINES_DIR" | wc -l)")

#exit if nothing selected
[[ -z "$ENGINE_SELECT" ]] && exit 0


###logic handler

handle_engine() {
    local engine="$1"
    local query

    case "$engine" in
        "Firefox Bookmarks")
            #ensure delimiter (𝆓) matches the character in firefox_bookmarks.py
            query=$(python3 "$ENGINES_DIR/$engine" | rofi -dmenu -p "Firefox Bookmarks" -i | awk -F"𝆓" '{print $2}')
            [[ -n "$query" ]] && eval "$DEFAULT_BROWSER" "$query"
            ;;

        "Fsearch")
            query=$(rofi -dmenu -p "Fsearch" -i)
            [[ -n "$query" ]] && /usr/bin/fsearch -s "$query"
            ;;

        "Freetube")
            query=$(rofi -dmenu -p "Search Freetube" -i)
            [[ -n "$query" ]] && "$ENGINES_DIR/$engine" --rofi "$query"
            ;;

        "Spellcheck")
            query=$(rofi -dmenu -lines 0 -p 'Search Dictionary')
            [[ -z "$query" ]] && return

            #get suggestions
            word=$(echo "$query" | hunspell -a | awk '/^&/{for(i=5;i<=NF;i++) {gsub(/,$/, "", $i); print $i}}')

            if [[ -z "$word" ]]; then
                dict "$query" | rofi -dmenu -fullscreen -p "Dictionary results for '$query'"
            else
                echo "$word" | rofi -dmenu -p "Spellcheck results for '$query'" | xclip -selection clipboard
            fi
            ;;

        "Calculator")
            rofi -show calc -modi calc -no-show-match -no-sort -terse
            ;;

        *)

            ###default browser search logic (covers Brave, Google, etc.)

            #check if the selected engine file exists, otherwise use default
            local engine_file="$ENGINES_DIR/$engine"
            if [[ ! -f "$engine_file" ]]; then
                engine_file="$ENGINES_DIR/$ENGINE_DEFAULT"
            fi

            local url_base
            url_base=$(cat "$engine_file")

            #private mode Logic
            local mode_choice
            mode_choice=$(echo -e "$PRIVATE_MODE_TEXT" | rofi -l 1 -dmenu -p "$engine Search")

            if [[ "$mode_choice" == "$PRIVATE_MODE_TEXT" ]]; then
                #user wants private mode
                local private_query
                private_query=$(rofi -lines 0 -dmenu -p "Private $engine Search")
                if [[ -n "$private_query" ]]; then
                    eval "${DEFAULT_PRIVATE_BROWSER[@]}" "${url_base}${private_query}"
                fi
            else
                #user wants normal mode
                if [[ -n "$mode_choice" ]]; then
                    eval "${DEFAULT_BROWSER[@]}" "${url_base}${mode_choice}"
                fi
            fi
            ;;
    esac
}

###execute handler
handle_engine "$ENGINE_SELECT"
