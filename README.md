# rofi-search
- Search tool to quickly find what you need from an array of user-defined web searches, or search a URL directly.
- Option to launch a private browser window instead (firefox and firefox --private-window by default)

**Non-websearch tools include:**
- Local dictionary (powered by ``dict``)
- Search Firefox exported bookmarks (technically offline?) by title, tag, and URL.  
  *this requires a firefox config flag to be altered:  
  go to ``about:config`` in firefox, and search for ``browser.bookmarks.autoExportHTML`` and set it to ``true``*  

# TODO:
searching local Firefox bookmarks (add python script to parse bookmarks)  
Freetube fuzzyfind search (refine bash script before uploading)
install script?

# Requires:
``rofi``  
``dict`` (optional)  
``firefox`` (optional)  
``freetube`` (optional)  
