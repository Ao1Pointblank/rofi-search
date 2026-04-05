#!/usr/bin/env bash
#https://github.com/Ao1Pointblank/rofi-search_query

ENGINES_DIR=~/.local/opt/rofi-search-engines/
ENGINE_DEFAULT=Brave
PRIVATE_MODE_TEXT="Press ENTER to use private browser window, or type query for normal search"

DEFAULT_BROWSER="flatpak run app.zen_browser.zen"
DEFAULT_PRIVATE_BROWSER="flatpak run app.zen_browser.zen --private-window"

#added icon support for engines. store icons as svg in $ENGINES_DIR/.ICONS/name_of_engine.svg
ENGINE_SELECT=$(ls $ENGINES_DIR | while read A ; do  echo -en "$A\x00icon\x1f$ENGINES_DIR/.ICONS/$A.svg\n"  ; done | rofi -dmenu -p "Search" -i -selected-row 2 -l $(ls -1 $ENGINES_DIR | wc -l)) &&

if [[ -e $ENGINES_DIR"$ENGINE_SELECT" ]]
then

    if [[ $ENGINE_SELECT == "Firefox Bookmarks" ]]
    then
		#make sure the delimiter (𝆓 by default) matches the one in firefox_bookmarks.py
    	QUERY=$(python3 "$ENGINES_DIR"/"Firefox Bookmarks" | rofi -dmenu -p "Firefox Bookmarks" -i | awk -F"𝆓" '{print $2}')
        if [[ -n "$QUERY" ]]; then
            $DEFAULT_BROWSER $QUERY
        fi

    elif [[ $ENGINE_SELECT == "Freetube" ]]
    then
    	QUERY=$(rofi -dmenu -p "Search Freetube" -i)
        "$ENGINES_DIR"/Freetube --rofi "$QUERY"
    elif [[ $ENGINE_SELECT == "Spellcheck" ]]
    then
        QUERY=$(rofi -dmenu -lines 0 -p 'Search Dictionary')
        WORD=$(echo "$QUERY" | hunspell -a | awk '/^&/{for(i=5;i<=NF;i++) {gsub(/,$/, "", $i); print $i}}')
        if [[ -z "$WORD" ]]
        then
            dict "$QUERY" | rofi -dmenu -fullscreen -p "Dictionary results for '$QUERY'"
        else
            echo "$WORD" | rofi -dmenu -p "Spellcheck results for '$QUERY'" | xclip -selection clipboard
        fi
    else
        QUERY=$(echo $PRIVATE_MODE_TEXT | rofi -l 1 -dmenu -p "$ENGINE_SELECT Search") &&

	    if [[ $QUERY == $PRIVATE_MODE_TEXT ]]
	    then
            PRIVATE_QUERY=$(rofi -lines 0 -dmenu -p "Private $ENGINE_SELECT Search") &&
    		$DEFAULT_PRIVATE_BROWSER $(cat $ENGINES_DIR"$ENGINE_SELECT")"$PRIVATE_QUERY"
    	else
		    $DEFAULT_BROWSER $(cat $ENGINES_DIR"$ENGINE_SELECT")"$QUERY"
	    fi
    fi
else
	$DEFAULT_BROWSER $(cat $ENGINES_DIR"$ENGINE_DEFAULT")"$ENGINE_SELECT"
fi
exit
