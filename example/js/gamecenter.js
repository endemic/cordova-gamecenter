/*jslint sloppy: true */
/*global window, cordova */

// Game Center Resources
// http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html

// Test account: nd_test@test.com
// Password: G4m3c3nt3r
// Test account: ja_test@test.com
// Password: G4m3c3nt3r

window.GameCenter = {};

/**
 * @description Presents a login modal
 * @param Function success Success callback - passed an object which looks like: { authenticated: true, playerID: XXXXX, alias: "Public display name" }
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.authenticatePlayer = function (success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "authenticateLocalPlayer", []);	// success callback, error callback, class, method, args
};

/**
 * @description Send a leaderboard high score for a particular category
 * @param String score Integer value
 * @param String category The unique ID you set up in iTunes Connect
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.reportScore = function (score, category, success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "reportScore", [score, category]);	// success callback, error callback, class, method, args
};

/**
 * @description Show a native UI leaderboard for a particular category
 * @param String category The unique ID you set up in iTunes Connect
 * @param String time Time interval for displayed scores; accepted values: "day", "week", "all"
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.showLeaderboard = function (category, time, success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "showLeaderboard", [category, time]);	// success callback, error callback, class, method, args
};

/**
 * @description Retrieve all high scores in a particular category
 * @param String category
 * @param Function success Success callback, takes a "score" object as a parameter which contains "score" and "category" properties
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.retrieveScores = function (category, success, error) {
    cordova.exec(success, error, "GameCenterPlugin", "retrieveScores", [category]);	// success callback, error callback, class, method, args
};

/**
 * @description Show native achievement list
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.showAchievements = function (success, error) {
    cordova.exec(success, error, "GameCenterPlugin", "showAchievements", []);	// success callback, error callback, class, method, args
};

/**
 * @description Request a turn based match
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.requestMatch = function (minPlayers, maxPlayers, success, error) {
    cordova.exec(success, error, "GameCenterPlugin", "requestMatch", []);	// success callback, error callback, class, method, args
};

/**
 * @description Custom callback, executed when a user's match request goes through successfully
 * Probably should show player the gameplay UI/scene
 */
window.GameCenter.foundMatch = function (matchId) {
	/* Your own code here */
	/*console.log("Found match " + matchId);*/
};

/**
 * @description Load current matches for the logged in player
 * @param Function success Success callback, takes a "matches" array as a parameter which contains objects representing current matches
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.loadMatches = function (success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "loadMatches", []);	// success callback, error callback, class, method, args
};

/**
 * @description Play a move in a specified match
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.advanceTurn = function (data, success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "advanceTurn", [data]);	// success callback, error callback, class, method, args
};