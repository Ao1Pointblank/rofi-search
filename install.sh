#!/bin/bash
#https://github.com/Ao1Pointblank/rofi-search
###rudimentary install script

###dependencies (fzf not strictly required)
dependencies=("rofi" "firefox" "fzf" "dict" "wordnet")

#check availability of each command
to_install=()
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        to_install+=("$dep")
    fi
done

#if there are commands to install, run apt install
if [[ ${#to_install[@]} -gt 0 ]]; then
    echo "Installing missing dependencies: ${to_install[*]}"
    sudo apt install -y "${to_install[@]}"
else
    echo "All apt dependencies are already installed."
fi

#pip dependency
if ! pip show beautifulsoup4 &> /dev/null; then
	pip install beautifulsoup4
else
	echo "All pip dependencies are already installed."
fi

#freetube dependency
if ! command -v freetube &> /dev/null; then
	echo "Freetube not found in '$PATH', please visit https://github.com/FreeTubeApp/FreeTube/ and install the latest .deb package."
else
	echo "Freetube already installed."
fi

###set about:config flag to export bookmarks
echo "Remember to quit Firefox!"
firefox_dir="~/.mozilla/firefox/"

#find default user prefs.js file
firefox_profile="$(ls "$firefox_dir" | grep -E '.*\.default.*' | head -n 1)"
pushd "$firefox_dir"/"$firefox_profile"
firefox_prefs=$(ls | grep "prefs.js")

#change browser.bookmarks.autoExportHTML to true
sed -i 's/\("browser\.bookmarks.autoExportHTML", \)false/\1true/' "$firefox_prefs"

###return to git folder; add chmod rule
popd
echo "Adding execute permissions..."
chmod +x ./rofi-search.sh
chmod +x ./rofi-search-engines/Freetube

###move folders
echo "Installed rofi-search script to $HOME/.local/bin/rofi-search"
cp ./rofi-search.sh ~/.local/bin/rofi-search

echo "Installed rofi-search-engines folder to $HOME/.local/opt/rofi-search-engines/"
mkdir -p ~/.local/opt/
cp -R ./rofi-search-engines ~/.local/opt/rofi-search-engines
