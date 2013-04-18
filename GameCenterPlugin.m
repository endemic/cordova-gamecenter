//
//  GameCenterPlugin.m
//
//  Created by Nathan Demick on 3/1/13.
//  Copyright (c) 2013 Ganbaru Games. All rights reserved.
//

#import "GameCenterPlugin.h"
#import <Cordova/CDV.h>

@implementation GameCenterPlugin

@synthesize achievementsDictionary, currentTurnBasedMatch, currentMatches;

#pragma mark -
#pragma mark Game Center methods

- (void)authenticateLocalPlayer:(CDVInvokedUrlCommand *)command
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

    // iOS5-style auth
    [localPlayer authenticateWithCompletionHandler: ^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        }
        else if (localPlayer.isAuthenticated)
        {
            NSDictionary *playerInfo = [NSDictionary dictionaryWithObjectsAndKeys:localPlayer.playerID, @"playerID",
                                                                               localPlayer.alias, @"alias",
                                                                               [NSNumber numberWithBool:localPlayer.isAuthenticated], @"authenticated", nil];
            
            // Tell the current class to respond to turn based event notifications
            [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:playerInfo];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wasn't able to authenticate. Try logging in using the Game Center app."];
        }
        
        // Send the result
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark -
#pragma mark Leaderboards

/* Send a high score */
- (void)reportScore:(CDVInvokedUrlCommand *)command
{
    int64_t score = (int64_t)[command.arguments objectAtIndex:0];
    NSString *category = [command.arguments objectAtIndex:1];
    
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    
    //NSLog(@"Trying to send score %lld for category %@", score, category);
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        NSDictionary *highScore = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:score], @"score", category, @"category", nil];
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:highScore];
        }
        
        // Send the result
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/* Show native leaderboard UI */
- (void)showLeaderboard:(CDVInvokedUrlCommand *)command
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    
    if (leaderboardController != nil)
    {
        NSString *category = nil,
                 *timeScope = nil;
        
        if (command.arguments.count > 0)
        {
            category = [command.arguments objectAtIndex:0];
        }
        
        if (command.arguments.count > 1)
        {
            timeScope = [command.arguments objectAtIndex:1];
        }
        
        // Set category
        if (category)
        {
            leaderboardController.category = category;
        }
        
        // Set time scope - default is all time. ALL TIME.
        if ([timeScope isEqualToString:@"day"])
        {
            leaderboardController.timeScope = GKLeaderboardTimeScopeToday;
        }
        else if ([timeScope isEqualToString:@"week"])
        {
            leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
        }
        else
        {
            leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
        }
        
        leaderboardController.leaderboardDelegate = self;
        [self.viewController presentViewController:leaderboardController animated: YES completion:nil];
        
        // Send the success callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
    else
    {
        // Send the error callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

/* Delegate callback to dismiss the native leaderboard UI */
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

/* Retrieve leaderboard scores programmatically in order to create a custom UI */
- (void)retrieveScores:(CDVInvokedUrlCommand *)command
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        NSString *category = nil,
                 *friendScope = nil,
                 *timeScope = nil;
        int range = 25;
        
        if (command.arguments.count > 0)
        {
            category = [command.arguments objectAtIndex:0];
        }
        
        if (command.arguments.count > 1)
        {
            friendScope = [command.arguments objectAtIndex:1];
        }
        
        if (command.arguments.count > 2)
        {
            timeScope = [command.arguments objectAtIndex:2];
        }
        
        if (command.arguments.count > 3)
        {
            range = [[command.arguments objectAtIndex:3] intValue];
        }
        
        // Your "default" leaderboard will be used unless you explicitly supply another one here
        if (category)
        {
            leaderboardRequest.category = category;
        }
        
        // Set global/friends scope - default is global
        if ([friendScope isEqualToString:@"friends"])
        {
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
        }
        else
        {
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        }
        
        // Set time scope - default is all time. ALL TIME.
        if ([timeScope isEqualToString:@"week"])
        {
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeWeek;
        }
        else if ([timeScope isEqualToString:@"day"])
        {
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
        }
        else
        {
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        }

        // Set the # of returned results - default is 25
        if (range > 0 && range <= 100)
        {
            leaderboardRequest.range = NSMakeRange(1, range);
        }
        
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error != nil)
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            }
            else
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:scores];
            }
            
            // Send the result
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
}

#pragma mark -
#pragma mark Achievements

/* Temporarily store achievements in a local data structure */
- (void)loadAchievements
{
    // Load player achievements
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error != nil)
        {
            // handle errors
        }
        if (achievements != nil)
        {
            // process array of achievements
            for (GKAchievement* achievement in achievements)
            {
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
            }
        }
    }];
}

/**
 * Get an achievement object in the locally stored dictionary
 */
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier
{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    
    return achievement;
}

/**
 * Send a completion % for a specific achievement to Game Center
 */
- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent
{
    // Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    
    if (achievement)
    {
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                NSLog(@"Error sending achievement!");
            }
        }];
    }
}

/**
 * Send a completion % for a specific achievement to Game Center - increments an existing achievement object
 */
- (void)reportAchievementIdentifier:(NSString *)identifier incrementPercentComplete:(float)percent
{
    // Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    
    if (achievement)
    {
        achievement.percentComplete += percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
             if (error != nil)
             {
                 NSLog(@"Error sending achievement!");
             }
         }];
    }
}

/* Show the native achievement UI */
- (void)showAchievements:(CDVInvokedUrlCommand *)command
{
    GKAchievementViewController *achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController != nil)
    {
        achievementController.achievementDelegate = self;
        [self.viewController presentModalViewController:achievementController animated:YES];
        
        // Send the success callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
    else
    {
        // Send the error callback
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

/* Delegate callback to dismiss achievement view controller */
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Turn-based Matchmaking

/**
 * Request a Game Center match
 */
- (void)requestMatch:(CDVInvokedUrlCommand *)command
{
    int minPlayers = 2,
        maxPlayers = 2;
    
    if (command.arguments.count > 0)
    {
        minPlayers = [[command.arguments objectAtIndex:0] intValue];
    }
    
    if (command.arguments.count > 1)
    {
        maxPlayers = [[command.arguments objectAtIndex:1] intValue];
    }
    
    // Create the match request, with all the appropriate options filled in
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    request.playerGroup = 0;  // An optional property that allows you to create distinct subsets of players in your game.
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = NO;  // Change this to list matches in the view controller
    
    // Show the native UI
    [self.viewController presentViewController:mmvc animated:YES completion:nil];
    
    // Return plugin result
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

/**
 * Called after user successfully finds a match, or selects a game in progress
 */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Found a match: %@", match);
    
    // Store this match
    self.currentTurnBasedMatch = match;
    
    // Dismiss the native UI
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    // Execute a custom callback to let Javascript layer know a match was found; probably should update UI
    [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.foundMatch(%@)", match.matchID]];
}

/**
 * Programmatically retrieve the list of matches the local player is participating in
 */
- (void)loadMatches:(CDVInvokedUrlCommand *)command
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        CDVPluginResult *result = nil;
        
        if (matches)
        {
            // Store list of current matches;
            // can't send Obj-C objects back to the Javascript layer,
            // so will need to iterate/find the native object based on matchID
            self.currentMatches = matches;
            
            NSMutableArray *json = [NSMutableArray array];
            NSMutableArray *playerIds = [NSMutableArray array];
            
            for (GKTurnBasedMatch *match in matches)
            {
                NSMutableArray *participants = [NSMutableArray array];
                
                // Get participants
                for (GKTurnBasedParticipant *participant in match.participants)
                {
                    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithObjectsAndKeys:participant.playerID, @"playerId",
                                       [NSNumber numberWithInt:participant.status], @"status",
                                       participant.timeoutDate, @"timeoutDate", nil];
                    
                    [participants addObject:p];
                    
                    // Add participant to the "alias" lookup array
                    if (participant.playerID != nil && [playerIds indexOfObject:participant.playerID] == NSNotFound)
                    {
                        [playerIds addObject:participant.playerID];
                    }
                }
                
                // Get current participant
                NSMutableDictionary *currentParticipant = [NSMutableDictionary dictionaryWithObjectsAndKeys:match.currentParticipant.playerID, @"playerId",
                                   [NSNumber numberWithInt:match.currentParticipant.status], @"status",
                                   match.currentParticipant.timeoutDate, @"timeoutDate", nil];
                
                // Create a dictionary w/ relevant data
                NSMutableDictionary *m = [NSMutableDictionary dictionaryWithObjectsAndKeys:match.matchID, @"matchId",
                                   [NSNumber numberWithInt:match.status], @"status",
                                   match.message, @"message",
                                   participants, @"participants",
                                   currentParticipant, @"currentParticipant", nil];
                
                [json addObject:m];
            }
            
            // Get player aliases
            [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler:^(NSArray *players, NSError *error) {
                CDVPluginResult *result = nil;
                NSMutableDictionary *playerAliases = [NSMutableDictionary dictionary];
                
                if (players)
                {
                    // Create a dictionary w/ ID of player as key, alias as value
                    for (GKPlayer *player in players)
                    {
                        [playerAliases setObject:player.alias forKey:player.playerID];
                    }
                    
                    // Loop through the results array and add player aliases to match objects
                    for (NSMutableDictionary *match in json)
                    {
                        // Set the alias for the current participant
                        NSMutableDictionary *currentParticipant = [match objectForKey:@"currentParticipant"];
                        NSString *playerId = [currentParticipant objectForKey:@"playerId"];
                        if (playerId != nil)
                        {
                            [currentParticipant setObject:[playerAliases objectForKey:playerId] forKey:@"alias"];
                        }
                        
                        // Set the alias for all participants
                        NSMutableArray *participants = [match objectForKey:@"participants"];
                        for (NSMutableDictionary *participant in participants)
                        {
                            NSString *playerId = [participant objectForKey:@"playerId"];
                            if (playerId != nil)
                            {
                                [participant setObject:[playerAliases objectForKey:playerId] forKey:@"alias"];
                            }
                        }
                    }
                    
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:json];
                }
                else if (error != nil)
                {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                }
                
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }];
        }
        else if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

/**
 * Loads match data from a specific match ID
 */
- (void)loadMatch:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";

    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    if ([self findMatchWithId:matchId] == NO)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [self.currentTurnBasedMatch loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        CDVPluginResult *result = nil;
        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:matchData options:NSJSONWritingPrettyPrinted error:nil];

        // Decode the match data here
        NSString *json = [[NSString alloc] initWithData:matchData encoding:NSUTF8StringEncoding];
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Advance the turn
 */
- (void)advanceTurn:(CDVInvokedUrlCommand *)command
{
    NSString *argument = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:0]];
    NSLog(@"Turn data: %@", argument);
    
    // Convert data arg to NSData
    NSData *data = [argument dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *sortedPlayerOrder = [NSMutableArray arrayWithArray:self.currentTurnBasedMatch.participants];
    
    // Remove the first player and add to the end of the array
    GKTurnBasedParticipant *p = [sortedPlayerOrder objectAtIndex:0];
    [sortedPlayerOrder removeObjectAtIndex:0];
    [sortedPlayerOrder addObject:p];
    
    // TODO: allow JS to pass a message indicating current game state
    self.currentTurnBasedMatch.message = @"Hello!";
    
    [self.currentTurnBasedMatch endTurnWithNextParticipants:sortedPlayerOrder turnTimeout:GKTurnTimeoutDefault matchData:data completionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
        // Send results
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * When a player wants to resign from a particular match
 */
- (void)quitMatch:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";
    
    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    if ([self findMatchWithId:matchId] == NO)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    // Determine if you are the current player or not
    if ([self.currentTurnBasedMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        NSMutableArray *sortedPlayerOrder = [NSMutableArray arrayWithArray:self.currentTurnBasedMatch.participants];
        
        // Remove the first player
        [sortedPlayerOrder removeObjectAtIndex:0];
        
        [self.currentTurnBasedMatch participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:sortedPlayerOrder turnTimeout:604800 matchData:self.currentTurnBasedMatch.matchData completionHandler:^(NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error != nil)
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            }
            else
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            
            // Send results
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    } else {
        [self.currentTurnBasedMatch participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error != nil)
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
            }
            else
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            
            // Send results
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
}

/**
 * When the game ends "normally"
 */
- (void)endMatch:(CDVInvokedUrlCommand *)command
{
    NSString *argument = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:0]];
    
    // Convert data arg to NSData
    NSData *data = [argument dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.currentTurnBasedMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
        // Send results
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Remove a finished game from Game Center
 */
- (void)removeMatch:(CDVInvokedUrlCommand *)command
{
    NSString *matchId = @"";

    if (command.arguments.count > 0)
    {
        matchId = [command.arguments objectAtIndex:0];
    }
    
    if ([self findMatchWithId:matchId] == NO)
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Match not found."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    [self.currentTurnBasedMatch removeWithCompletionHandler:^(NSError *error) {
        CDVPluginResult *result = nil;
        
        if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        
        // Send results
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Helper method which sets 'currentTurnBasedMatch' to the match with the provided matchId
 */
- (BOOL)findMatchWithId:(NSString *)matchId
{
    BOOL foundMatch = NO;
    
    // Loop through local store of match objects to find the desired one
    for (GKTurnBasedMatch *match in self.currentMatches)
    {
        if ([match.matchID isEqualToString:matchId])
        {
            self.currentTurnBasedMatch = match;
            foundMatch = YES;
            break;
        }
    }
    
    return foundMatch;
}

#pragma mark -
#pragma mark Matchmaking delegate methods

/* Cancel */
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    // Execute a custom callback
    [self writeJavascript:@"window.GameCenter.matchCancelled()"];
}

/* Fail */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    // Execute a custom callback
    [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.matchError(%@)", error.localizedDescription]];
}

/* Quit */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    // Execute a custom callback
    [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.playerQuit(%@)", match.matchID]];
}

#pragma mark -
#pragma mark Matchmaking events

// Player receives invitation - Push
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite
{
    /*
     When your delegate receives this message, your game should create a new GKMatchRequest object and assign 
     the playersToInvite parameter to the match request’s playersToInvite property. Then, your game can either 
     call the GKTurnBasedMatch class method findMatchForRequest:withCompletionHandler: to find a match 
     programmatically or it can use the request to instantiate a new GKTurnBasedMatchmakerViewController
     object to show a user interface to the player.
     */
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.playersToInvite = playersToInvite;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    
    // Show native interface
    [self.viewController presentViewController:mmvc animated:YES completion:nil];
}

// Becomes player's turn - Push
// Becomes someone else's turn - Foreground
// Another player updates match data - Foreground
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive
{
    /*
     When your delegate receives this message, the player has accepted a push notification for a match already in progress. 
     Your game should end whatever task it was performing and switch to the match information provided by the match object.
     */
}

// Match ended - Push
- (void)handleMatchEnded:(GKTurnBasedMatch *)match
{
    /*
     When your delegate receives this message, it should display the match’s final results to the player and allow the 
     player the option of saving or removing the match data from Game Center.
     Also should probably allow a rematch.
     */
}

@end