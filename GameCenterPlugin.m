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

/*
- (void)echo:(CDVInvokedUrlCommand *)command
{
	CDVPluginResult *result = nil;
	NSString *arg = [command.arguments objectAtIndex:0];

	if (arg != nil && arg.length > 0)
	{
		result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:arg];
	}
	else
	{
		result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No string passed."];
	}

	[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

	// Example of calling an async callback
	// [self writeJavascript:@"window.storekit.callback.apply(window.storekit, ['arg1', 'arg2'])"];
 
 //            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:nil];
 //            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
 */

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

//- (void)reportScore:(int64_t)score forCategory:(NSString *)category
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
        
        // Your "Default" leaderboard will be used unless you explicitly supply another one here
        if (category)
        {
            // Set category
            leaderboardRequest.category = category;
            NSLog(@"Category: %@", leaderboardRequest.category);
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
        
        // Make the request
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error != nil)
            {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            }
            else
            {
                // Return scores
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:scores];
            }
            
            // Send the result
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
}

#pragma mark -
#pragma mark Achievements

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

#pragma mark -
#pragma mark Matchmaking

/**
 * Request a Game Center match
 */
- (void)requestMatch:(CDVInvokedUrlCommand *)command
{
    // Create the match request, with all the appropriate options filled in
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    request.playerGroup = 0;  // Can be whatever, user-specified
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    
    // Will this work?
    [self.viewController presentViewController:mmvc animated:YES completion:nil];
    
    // Return plugin result
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

/* Cancel */
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    // Execute a custom callback?
}

/* Fail */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    // Execute a custom callback?
}

/*  */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    
}

/**
 * Called after user successfully finds a match
 */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Found a match: %@", match);
    
    // Store this match
    self.currentTurnBasedMatch = match;
    
    // Execute a custom callback
}

/**
 * Retrieve the list of matches the local player is participating in
 */
- (void)loadMatches:(CDVInvokedUrlCommand *)command
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        CDVPluginResult *result = nil;
        
        if (matches)
        {
            // Store list of current matches, can't send Obj-C objects back to the Javascript layer, so will need to iterate/find the native object based on matchID
            self.currentMatches = matches;
            
            NSMutableArray *toJson = [NSMutableArray array];
            
            for (GKTurnBasedMatch *match in matches)
            {
                NSMutableArray *participants = [NSMutableArray array];
                
                // Get participants
                for (GKTurnBasedParticipant *participant in match.participants)
                {
                    NSDictionary *p = [NSDictionary dictionaryWithObjectsAndKeys:participant.playerID, @"playerId",
                                       participant.status, @"status",
                                       participant.timeoutDate, @"timeoutDate",
                                       nil];
                    [participants addObject:p];
                }
                
                // Get current participant
                NSDictionary *currentParticipant = [NSDictionary dictionaryWithObjectsAndKeys:match.currentParticipant.playerID, @"playerId",
                                   match.currentParticipant.status, @"status",
                                   match.currentParticipant.timeoutDate, @"timeoutDate",
                                   nil];
                
                // Create a dictionary w/ relevant data
                NSDictionary *m = [NSDictionary dictionaryWithObjectsAndKeys:match.matchID, @"matchId",
                                   match.status, @"status",
                                   match.message, @"message",
                                   participants, @"participants",
                                   currentParticipant, @"currentParticipant",
                                   nil];
                [toJson addObject:m];
            }
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:toJson];
            
            // Get match info here!
            /*
             match object
             {
                matchID: 'xxxx',
                status: 
                message:
                participants:
                currentParticipant:
             }
             
             participant object
             {
                playerID
                status
                timeoutDate
                matchOutcome
             }
             
             */
        }
        else if (error != nil)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        }
        else
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/**
 * Load data from the selected match
 */
- (void)loadMatchData
{
    [self.currentTurnBasedMatch loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        // Decode the match data here
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *json = [[NSString alloc] initWithData:matchData encoding:NSUTF8StringEncoding];
        
    }];
}

/**
 * Update match data -- called at the end of a turn
 * Match data is max 64k
 */
- (void)updateMatchData
{
    NSString *json = @"{results:false}";
    NSData *data = [NSData dataFromBase64String:json];
    
    [self.currentTurnBasedMatch saveCurrentTurnWithMatchData:data completionHandler:^(NSError *error) {
        if (error != nil)
        {
            
        }
        else
        {
            
        }
    }];
}

/**
 * Advance the turn
 */
- (void)advanceTurn
{
    NSString *json = @"{results:false}";
    NSData *data = [NSData dataFromBase64String:json];
    NSArray *sortedPlayerOrder = [NSArray array];   // TODO: re-arrange the players in the "currentTurnBasedMatch" obj
    
    [self.currentTurnBasedMatch endTurnWithNextParticipants:sortedPlayerOrder turnTimeout:GKTurnTimeoutDefault matchData:data completionHandler:^(NSError *error) {
        
    }];
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
    
    // Will this work?
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
     When your delegate receives this message, it should display the match’s final results to the player and allow the player the option of saving or removing the match data from Game Center.
     Also should probably allow a rematch.
     */
}

@end