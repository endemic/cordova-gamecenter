//
//  GameCenterPlugin.h
//
//  Created by Nathan Demick on 3/1/13.
//  Copyright (c) 2013 Ganbaru Games. All rights reserved.
//

#import <Cordova/CDV.h>
#import <GameKit/GameKit.h>

@interface GameCenterPlugin : CDVPlugin
{
    // Store saved Game Center achievement progress
    NSMutableDictionary *achievementsDictionary;
}

@property (nonatomic, retain) NSMutableDictionary *achievementsDictionary;

// Game Center methods
- (BOOL)isGameCenterAPIAvailable;
- (void)authenticateLocalPlayer;

// Leaderboards
- (void)reportScore:(int64_t)score forCategory:(NSString *)category;

// Achievements
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier;
- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent;
- (void)reportAchievementIdentifier:(NSString *)identifier incrementPercentComplete:(float)percent;

@end