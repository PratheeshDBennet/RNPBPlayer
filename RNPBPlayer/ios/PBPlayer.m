//
//  PBPlayer.m
//  RNPBPlayer
//
//  Created by Pratheesh Bennet on 20/07/21.
//

#import <Foundation/Foundation.h>
#import "React/RCTViewManager.h"
#import <React/RCTLog.h>

@interface RCT_EXTERN_MODULE(PBPlayer, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(shouldPlay, BOOL)
RCT_EXPORT_VIEW_PROPERTY(isPlaying, BOOL)
RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(onEnd, RCTDirectEventBlock);
RCT_EXTERN_METHOD(playPauseAction: (nonnull NSNumber *)node callback: (RCTResponseSenderBlock)callback)
@end
