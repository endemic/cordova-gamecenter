/*jslint sloppy: true, devel: true */
/*global window, cordova */

// Game Center Resources
// http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/GameKit_Guide/Introduction/Introduction.html

// Test account: nd_test@test.com
// Password: G4m3c3nt3r
// Test account: ja_test@test.com
// Password: G4m3c3nt3r

window.GameCenter = {};

/* Some GameCenter enums */
window.GameCenter.GKTurnBasedMatchStatus = [
	'GKTurnBasedMatchStatusUnknown',
	'GKTurnBasedMatchStatusOpen',
	'GKTurnBasedMatchStatusEnded',
	'GKTurnBasedMatchStatusMatching'
];

window.GameCenter.GKTurnBasedParticipantStatus = [
	'GKTurnBasedParticipantStatusUnknown',
	'GKTurnBasedParticipantStatusInvited',
	'GKTurnBasedParticipantStatusDeclined',
	'GKTurnBasedParticipantStatusMatching',
	'GKTurnBasedParticipantStatusActive',
	'GKTurnBasedParticipantStatusDone'
];

/* A local cache of match data */
window.GameCenter.matches = {};

/* Whether or not the previous request was successful; helpful to know whether to make a request again. */
window.GameCenter.requestError = false;

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
 * @description Programatically retrieve all high scores in a particular category
 * @param String category Leaderboard ID set up in iTunes Connect
 * @param String friends Allowed values: "global" or "friends" to show scores from friends only
 * @param String time Allowed values: "day" "week" or "all"
 * @param String range Number of returned results, between 1 and 100. Default is 25.
 * @param Function success Success callback, takes a "score" object as a parameter which contains "score" and "category" properties
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.retrieveScores = function (category, friends, time, range, success, error) {
    cordova.exec(success, error, "GameCenterPlugin", "retrieveScores", [category, friends, time, range]);	// success callback, error callback, class, method, args
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
 * @param Number minPlayers Minimum # of players for match
 * @param Number maxPlayers Maximum # of players for match
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
	console.log("Found match " + matchId);
	/* Your own code here; call 'loadMatchWithId' to get game data, then transition to gameplay */
};

/**
 * @description Called when there was some sort of error setting up a Game Center match (network timeout, etc.)
 * Overwrite this method with your own code.
 */
window.GameCenter.matchError = function (error) {
	/* Your own code here */
	console.log("There was an error creating the match: " + error);
};

/**
 * @description Called when the match picker was cancelled; overwrite this method with your own code.
 */
window.GameCenter.matchCancelled = function () {
	/* Your own code here */
	console.log("The match was cancelled.");
};

/**
 * @description Called when another player quits a game
 */
window.GameCenter.playerQuit = function (matchId) {
	/* Your own code here */
	console.log("Another player quit game #" + matchId);
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
 * @description Load the stored data for a match with a specific match ID
 * @param String GameCenter match ID
 * @param Function success Success callback, takes a "data" object as a parameter which contains match data (played moves, etc.)
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.loadMatch = function (matchId, success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "loadMatch", [matchId]);	// success callback, error callback, class, method, args
};

/**
 * @description Play a move in a specified match
 * @param String Arbitrary data that indicates the state of the match
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.advanceTurn = function (data, success, error) {
	if (typeof data === "object") {
		data = JSON.stringify(data);
	}
	cordova.exec(success, error, "GameCenterPlugin", "advanceTurn", [data]);	// success callback, error callback, class, method, args
};

/**
 * @description End a game when a player has won or lost
 * @param String Arbitrary data that indicates the ending state of the match
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.endMatch = function (data, success, error) {
	if (typeof data === "object") {
		data = JSON.stringify(data);
	}
	cordova.exec(success, error, "GameCenterPlugin", "endMatch", [data]);	// success callback, error callback, class, method, args
};

/**
 * @description Quit an in-progress match
 * @param String GameCenter match ID
 * @param Function success Success callback, takes a "data" object as a parameter which contains match data (played moves, etc.)
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.quitMatch = function (matchId, success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "quitMatch", [matchId]);	// success callback, error callback, class, method, args
};

/**
 * @description Remove a finished match. Will return an error if player is current participant
 * @param String GameCenter match ID
 * @param Function success Success callback
 * @param Function error Error callback, takes a string as a parameter which contains an error message
 */
window.GameCenter.removeMatch = function (matchId, success, error) {
	cordova.exec(success, error, "GameCenterPlugin", "removeMatch", [matchId]);	// success callback, error callback, class, method, args
};