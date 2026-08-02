#!/usr/bin/env bash
# https://github.com/Ao1Pointblank/rofi-search


###configuration

ENGINES_DIR=~/.local/opt/rofi-search-engines/
ENGINE_DEFAULT="Brave"
PRIVATE_MODE_TEXT="Press ENTER to use private browser window, or type query for normal search"

#browser commands
DEFAULT_BROWSER="flatpak run app.zen_browser.zen"
DEFAULT_PRIVATE_BROWSER="flatpak run app.zen_browser.zen --private-window"

###main logic (exceptions to browser based searches first)
handle_engine() {
    local engine="$1"
    local direct_query="$2"
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
            ###default browser search logic

            #resolve engine file
            local engine_file="$ENGINES_DIR/$engine"
            [[ ! -f "$engine_file" ]] && engine_file="$ENGINES_DIR/$ENGINE_DEFAULT"

            local url_base
            url_base=$(<"$engine_file")

            #if a direct query was passed (from free text input), skip the rofi mode selection
            if [[ -n "$direct_query" ]]; then
                search_query="$direct_query"
                browser_cmd="$DEFAULT_BROWSER"
            else
                #when search engine directly selected, ask for private mode vs normal query
                local mode_choice
                mode_choice=$(echo -e "$PRIVATE_MODE_TEXT" | rofi -l 1 -dmenu -p "$engine Search")

                #this check may not be needed at all
                #[[ -z "$mode_choice" ]] && return

                if [[ "$mode_choice" == "$PRIVATE_MODE_TEXT" ]]; then
                    search_query=$(rofi -lines 0 -dmenu -p "Private $engine Search")
                    browser_cmd="$DEFAULT_PRIVATE_BROWSER"
                else
                    search_query="$mode_choice"
                    browser_cmd="$DEFAULT_BROWSER"
                fi
            fi

            #execute search
            if [[ -n "$search_query" ]]; then
                local full_url="${url_base}${search_query}"
                read -ra cmd_array <<< "$browser_cmd"
                "${cmd_array[@]}" "$full_url" &
            fi
            ;;
    esac
}

###engine selection/free text to default engine handling

#generate list with svg icons
ENGINE_SELECT=$(ls "$ENGINES_DIR" | while read -r A; do
    if [[ -f "$ENGINES_DIR/.ICONS/$A.svg" ]]; then
        echo -en "$A\x00icon\x1f$ENGINES_DIR/.ICONS/$A.svg\n"
    else
        echo "$A"
    fi
done | rofi -dmenu -p "Search" -i -selected-row 2 -l "$(ls -1 "$ENGINES_DIR" | wc -l)")

#exit if nothing selected (Escape pressed)
[[ -z "$ENGINE_SELECT" ]] && exit 0

#check if input matches a valid engine file
if [[ -f "$ENGINES_DIR/$ENGINE_SELECT" ]]; then
    #valid engine selected from list
    handle_engine "$ENGINE_SELECT"
else
    #free text typed (no matching file) -> treat as query for default engine
    handle_engine "$ENGINE_DEFAULT" "$ENGINE_SELECT"
fi
