/*jslint sloppy: true */
/*global window, cordova */

// Game Center Resources
// http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html

// Test account: nd_test@test.com
// Password: G4m3c3nt3r

window.GameCenter = {};

/**
 * @description Presents a login modal
 * success callback is passed an object which looks like: { authenticated: true, playerID: XXXXX, alias: "Public display name" }
 */
window.GameCenter.authenticatePlayer = function (success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "authenticateLocalPlayer", []);	// success callback, error callback, class, method, args
};

/**
 * @description Send a leaderboard high score for a particular category
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
 */
window.GameCenter.requestMatch = function (success, error) {
    cordova.exec(success, error, "GameCenterPlugin", "requestMatch", []);	// success callback, error callback, class, method, args
};

/**
 * @description Load current matches for the logged in player
 * @param Function success Success callback, takes a "matches" array as a parameter which contains objects representing current matches
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.loadMatches = function (success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "loadMatches", []);	// success callback, error callback, class, method, args
};

// Load matches
// Advance turn
