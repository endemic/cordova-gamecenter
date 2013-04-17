# Cordova Game Center Plugin

## Installation Instructions (Currently Unfinished)

1. Copy __GameCenterPlugin.h__ and __GameCenterPlugin.m__ to your project's _Plugins_ directory.
2. Copy __gamecenter.js__ to your project's _www_ directory.
3. Edit your project's _Cordova.plist_ file:
	1. Add __*.apple.com__ to the _ExternalHosts_ array.
	2. Add __GameCenterPlugin__ to the _Plugins_ dictionary (for both key and value).
4. Include a reference to __gamecenter.js__ in your index file (e.g. &lt;script src="js/gamecenter.js"&gt;&lt;/script&gt;).
5. Set up GameCenter for your app in iTunes Connect.

## Documentation

_GameCenter.authenticatePlayer(success, error)_  
Displays the Game Center login UI, or automatically log the player in if they've previously authenticated. The _success_ callback is passed 
an object which looks like the following: __{ authenticated: true, playerID: XXXXX, alias: "Public display name" }__. The _error_ callback 
is passed a string which gives details about the error.

_GameCenter.reportScore(score, category, success, error)_  
Send a _score_ to a Game Center leaderboard, represented by the _category_ string. _category_ must be the identifier that you set up for the 
leaderboard in iTunes Connect. The _error_ callback is passed a string which gives details about the error. The plugin doesn't save/resend 
scores if there was a transmission failure; it's up to you to keep track of which scores were successfully sent. A common technique for this 
is to save your scores in an array, iterate/send each one, and _splice_ the score out of the array if it was successfully sent. 

_GameCenter.showLeaderboard(category, time, success, error)_  
Display the "native" Game Center UI for the _category_ leaderboard. _category_ must be the identifier that you set up for the 
leaderboard in iTunes Connect. _time_ is a string representing the time interval of displayed scores. Acceptable values are "day," "week," 
or "all." The _error_ callback is passed a string which gives details about the error. 

_more to come..._