//
//  PlayerViewModelObjc.m
//  AvPlayerP2PAdapterExample
//
//  Created by nice on 18/12/2019.
//  Copyright © 2019 npaw. All rights reserved.
//

#import "AvPlayerP2PExampleViewModelObjc.h"
#import <YouboraLib/YouboraLib.h>
#import <YouboraConfigUtils/YouboraConfigUtils-Swift.h>
#import <YouboraAVPlayerAdapter/YouboraAVPlayerAdapter.h>
#import "Samples-Swift.h"

@interface AvPlayerExampleViewModelObjc()

@property MenuResourceOption *resource;
@property MenuAdOption *ad;
@property YBPlugin *plugin;

@property NSArray <NSNumber*> *adsInterval;
@property NSInteger currentAdPosition;
@property NSString *currentAdLink;
@property AvailableP2P selectedP2P;

@end

@implementation AvPlayerExampleViewModelObjc

-(instancetype)initWith:(MenuResourceOption*)resource andAd:(MenuAdOption*)ad {
    self = [super init];
    if (self) {
        self.resource = resource;
        self.ad = ad;
        
        YBOptions *options = [YouboraConfigManager getOptions];
        options.offline = false;
        options.contentResource = resource.resourceLink;
        options.accountCode = @"powerdev";
        options.adResource = self.ad.adLink;
        options.contentIsLive = [[NSNumber alloc] initWithBool: resource.isLive];
        
        self.plugin = [[YBPlugin alloc] initWithOptions:options];
        
        self.adsInterval = @[@10,@20,@30];
        self.currentAdPosition = 0;
    }
    
    return self;
}

- (void)startYouboraWithPlayer:(AVPlayer * _Nullable)player andDnaClient:(DNAClient * _Nullable)dnaClient {
    [self.plugin fireInit];
    [self.plugin setAdapter:[[YBAVPlayerP2PAdapter alloc] initWithDnaClient:dnaClient andPlayer:player]];
}

- (NSURL *)getVideoUrl {
    return [[NSURL alloc] initWithString:self.resource.resourceLink];
}

- (void)stopYoubora {
    [self.plugin fireStop];
    
    [self.plugin removeAdapter];
    [self.plugin removeAdsAdapter];
}

- (NSURL * _Nullable)getNextAd:(double)currentPlayhead {
    if (!self.ad) { return nil; }
    if (self.currentAdLink) { return nil; }
    if (self.currentAdPosition > (self.adsInterval.count - 1)) { return nil; }
    
    if (currentPlayhead < [self.adsInterval[self.currentAdPosition] doubleValue]) {
        return nil;
    }
    
    self.currentAdPosition ++;
    self.currentAdLink = self.ad.adLink;
    
    return [[NSURL alloc] initWithString:self.ad.adLink];
}

- (Boolean)containAds {
    if (self.ad && ![self.ad isKindOfClass:[NoAdsOption class]]) {
        return true;
    }
    
    return false;
}

- (void)setAdsAdapterWithPlayer:(AVPlayer * _Nullable)player {
    if (player) {
        [self.plugin setAdsAdapter:[[YBAVPlayerAdsAdapter alloc] initWithPlayer:player]];
    }
}

- (void)adsDidFinish {
    self.currentAdLink = nil;
    [self.plugin removeAdsAdapter];
}

- (AvailableP2P)getSelectedP2P {
    if (self.selectedP2P) { return self.selectedP2P; }
    
    return Streamroot;
}


@end
