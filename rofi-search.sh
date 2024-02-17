#!/usr/bin/env bash

ENGINES_DIR=~/.local/opt/rofi-search-engines/
ENGINE_DEFAULT=Brave
PRIVATE_MODE_TEXT="Press ENTER to use private Mullvad window, or type query for normal search"

DEFAULT_BROWSER="firefox"
#DEFAULT_PRIVATE_BROWSER="firefox --private-window"
DEFAULT_PRIVATE_BROWSER="/home/pointblank/.local/opt/mullvad-browser/Browser/start-mullvad-browser"

ENGINE_SELECT=$(ls $ENGINES_DIR | rofi -dmenu -p "Search" -i -selected-row 1 -l $(ls -1 $ENGINES_DIR | wc -l)) &&
if [[ -e $ENGINES_DIR"$ENGINE_SELECT" ]]
then

    if [[ $ENGINE_SELECT == "Firefox Bookmarks" ]]
    then
    	QUERY=$(python3 ~/.local/bin/firefox_bookmarks.py | rofi -dmenu -p "Firefox Bookmarks" -i | awk -F"𝆓" '{print $2}') &&
        $DEFAULT_BROWSER $QUERY
    elif [[ $ENGINE_SELECT == "Freetube" ]]
    then
        freetube-search -r
    elif [[ $ENGINE_SELECT == "Dictionary (Local)" ]]
    then
    	rofi-dict () {
    		QUERY=$(rofi -dmenu -lines 0 -p 'Search Dictionary') && dict "$QUERY" | rofi -dmenu -fullscreen -p "Dictionary results for '$QUERY'" && rofi-dict
    	}
    	rofi-dict
    else
        QUERY=$(echo $PRIVATE_MODE_TEXT | rofi -l 1 -dmenu -p "$ENGINE_SELECT Search") &&

	    if [[ $QUERY == $PRIVATE_MODE_TEXT ]]
	    then
            PRIVATE_QUERY=$(rofi -lines 0 -dmenu -p "Private $ENGINE_SELECT Search") &&
		$(cat $ENGINES_DIR"$ENGINE_SELECT")"$PRIVATE_QUERY"
    	$DEFAULT_PRIVATE_BROWSER $(cat $ENGINES_DIR"$ENGINE_SELECT")"$PRIVATE_QUERY"
    	else
		    $DEFAULT_BROWSER $(cat $ENGINES_DIR"$ENGINE_SELECT")"$QUERY"
	    fi
    fi
else
	$DEFAULT_BROWSER $(cat $ENGINES_DIR"$ENGINE_DEFAULT")"$ENGINE_SELECT"
fi
exit
