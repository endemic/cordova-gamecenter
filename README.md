cordova-gamecenter-plugin
=========================

GameCenter plugin for Apache Cordova

## Installation Instructions (Currently Unfinished) ##

1. Copy __GameCenterPlugin.h__ and __GameCenterPlugin.m__ to your project's _Plugins_ directory.
2. Copy __gamecenter.js__ to your project's _www_ directory.
3. Edit your project's _Cordova.plist_ file:
	1. Add __*.apple.com__ to the _ExternalHosts_ array.
	2. Add __GameCenterPlugin__ to the _Plugins_ dictionary (for both key and value).
4. Include a reference to __gamecenter.js__ in your index file (e.g. &lt;script src="js/gamecenter.js"&gt;&lt;/script&gt;).
5. Set up GameCenter for your app in iTunes Connect.