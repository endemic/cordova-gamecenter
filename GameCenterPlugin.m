//
//  GameCenterPlugin.m
//
//  Created by Nathan Demick on 3/1/13.
//  Copyright (c) 2013 Ganbaru Games. All rights reserved.
//

#import "GameCenterPlugin.h"
#import <Cordova/CDV.h>

@implementation GameCenterPlugin

@synthesize achievementsDictionary;

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
}
 */

#pragma mark -
#pragma mark Game Center methods

- (void)authenticateLocalPlayer:(CDVInvokedUrlCommand *)command
{
//    CDVPluginResult *result = nil;
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

    // iOS5-style auth
    [localPlayer authenticateWithCompletionHandler: ^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:localPlayer.playerID, @"playerID",
                                                                               localPlayer.alias, @"alias",
                                                                               [NSNumber numberWithBool:localPlayer.isAuthenticated], @"authenticated", nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:nil];
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [self writeJavascript:[NSString stringWithFormat:@"window.GameCenter.playerWasAuthenticated(%@)", json]];
        }
        else
        {
            [self writeJavascript:@"window.GameCenter.playerWasAuthenticated({ authenticated: false })"];
        }
    }];
}

#pragma mark -
#pragma mark Leaderboards

//- (void)reportScore:(int64_t)score forCategory:(NSString *)category
- (void)reportScore:(CDVInvokedUrlCommand *)command
{
    int64_t score = (int64_t)[command.arguments objectAtIndex:0];
    NSString *category = [command.arguments objectAtIndex:1];
    
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = score;
    
    //NSLog(@"Trying to send score %lld for category %@", score, category);
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
//            TODO: Send the score details back as an error
            NSLog(@"Error sending score! %lld for category %@", score, category);
        }
        else
        {
//            TODO: Send a "success" message
            NSLog(@"Successfully sent score!");
        }
    }];
}

#pragma mark -
#pragma mark Achievements

/**
 * Get an achievement object in the locally stored dictionary
 */
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier
{
    if (true)
    {
        GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
        if (achievement == nil)
        {
            achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
            [achievementsDictionary setObject:achievement forKey:achievement.identifier];
        }
        return [[achievement retain] autorelease];
    }
    return nil;
}

/**
 * Send a completion % for a specific achievement to Game Center
 */
- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent
{
    if (true)
    {
        // Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
        GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
        if (achievement)
        {
            achievement.percentComplete = percent;
            [achievement reportAchievementWithCompletionHandler:^(NSError *error)
            {
                if (error != nil)
                {
                    // Retain the achievement object and try again later
//                    [unsentAchievements addObject:achievement];

                    NSLog(@"Error sending achievement!");
                }
            }];
        }
    }
}

/**
 * Send a completion % for a specific achievement to Game Center - increments an existing achievement object
 */
- (void)reportAchievementIdentifier:(NSString *)identifier incrementPercentComplete:(float)percent
{
    if (true)
    {
        // Instantiate GKAchievement object for an achievement (set up in iTunes Connect)
        GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
        if (achievement)
        {
            achievement.percentComplete += percent;
            [achievement reportAchievementWithCompletionHandler:^(NSError *error)
             {
                 if (error != nil)
                 {
                     // Retain the achievement object and try again later
//                     [unsentAchievements addObject:achievement];
                     
                     NSLog(@"Error sending achievement!");
                 }
             }];
        }
    }
}

@end