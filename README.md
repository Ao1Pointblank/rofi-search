# rofi-search
- Search tool to quickly find what you need from an array of user-defined web searches, or search a URL directly.
- Option to launch a private browser window instead (firefox and firefox --private-window by default)

**Non-websearch tools include:**
- Local dictionary (powered by ``dict``)
- Search Firefox exported bookmarks (technically offline?) by title, tag, and URL.  
  *this requires a firefox config flag to be altered:  
  go to ``about:config`` in firefox, and search for ``browser.bookmarks.autoExportHTML`` and set it to ``true``*  

# TODO:
install script? 

# Requires:
``rofi``   
``dict`` (optional)    
``firefox``  
``freetube`` (optional)  
``beautifulsoup4`` (required to search firefox bookmarks)  

# Installation:
- download: ``git clone https://github.com/Ao1Pointblank/rofi-search``

- install beautifulsoup4 if you plan to search firefox bookmarks: ``pip install beautifulsoup4`` (also remember to change ``browser.bookmarks.autoExportHTML`` to true in Firefox's ``about:config``)

- install dict if you want to use local offline dictionaries: ``apt install dict wordnet`` (wordnet is a basic english dictionary library; you can add multiple other libraries too)

- move ``rofi-search.sh`` to ``~/.local/bin/`` 

- move ``rofi-search-engines`` to ``~/.local/opt/`` or to a directory of your choice (modify the ENGINES_DIR variable in the .sh file)

# Potential issues:
- path to firefox bookmarks file not valid. this can be fixed by editing line #12 of the ``firefox_bookmarks.py`` file to reflect the correct path on your system.
- permissions: make sure special search engines that run local commands have chmod +x permission (Freetube and the main script, perhaps Firefox Bookmarks too)


# Credits
the Freetube script with fzf support was inspired by https://github.com/pystardust/ytfzf
