//
//  ViewController.m
//  AVPlayerSkipFail
//
//  Created by Oisin Prendiville on 22/03/2016.
//  Copyright © 2016 Oisin Prendiville. All rights reserved.
//

#import "ViewController.h"

@import MediaPlayer;
@import AVFoundation;

@interface ViewController ()

@property (nonatomic) AVQueuePlayer *player;

@end

@implementation ViewController

NSString * NSStringFromCMTime(CMTime time) {
  return [NSString stringWithFormat:@"%@", @(CMTimeGetSeconds(time))];
}

BOOL AVPlayerItemCanSeekToTime(AVPlayerItem *playerItem, CMTime time) {
  for (NSValue *range in playerItem.seekableTimeRanges) {
    CMTimeRange timeRange = [range CMTimeRangeValue];
    if (CMTimeRangeContainsTime(timeRange, time)) {
      return YES;
    }
  }
  return NO;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"3971767414857652294" withExtension:@"mp3"];
  AVAsset *asset = [AVAsset assetWithURL:url];
  if (!asset.isPlayable) {
    NSLog(@"asset is not playable");
  }
  AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
  [playerItem seekToTime:CMTimeMake(120500, 100)];
  
  self.player = [[AVQueuePlayer alloc] initWithPlayerItem:playerItem];
  
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(audioPlayerDidPlayToEnd:)
                                               name: AVPlayerItemDidPlayToEndTimeNotification
                                             object: nil];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)skipByTimeInterval:(NSTimeInterval)interval
{
  AVPlayerItem *playerItem = self.player.currentItem;
  NSLog(@"Current time %@", NSStringFromCMTime(playerItem.currentTime));
  NSLog(@"Current duration %@", NSStringFromCMTime(playerItem.duration));
  
  CMTime seekToTime = CMTimeAdd(playerItem.currentTime, CMTimeMake(interval * 100, 100));
  NSLog(@"Seek to time %@", NSStringFromCMTime(seekToTime));
  
  if (!AVPlayerItemCanSeekToTime(playerItem, seekToTime)) {
    NSLog(@"Cannot seek, out of range");
  } else {
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
      [playerItem seekToTime:seekToTime completionHandler:^(BOOL finished) {
        if (finished) {
          NSLog(@"successfully seeked to time %@",NSStringFromCMTime(playerItem.currentTime));
        } else {
          NSLog(@"failed to seek to time");
        }
      }];
    } else {
      [playerItem seekToTime:seekToTime];
    }
  }
}

- (IBAction)togglePlayPause:(id)sender
{
  if (self.player.rate > 0.0f) {
    [self.player pause];
  } else {
    [self.player play];
    NSLog(@"Current time %@", NSStringFromCMTime(self.player.currentItem.currentTime));
    NSLog(@"Current duration %@", NSStringFromCMTime(self.player.currentItem.duration));
  }
}

- (IBAction)skipBack:(id)sender
{
  [self skipByTimeInterval:-15.0f];
}

- (IBAction)skipForward:(id)sender
{
  [self skipByTimeInterval:30.0f];
}

- (void)audioPlayerDidPlayToEnd:(NSNotification *)notification
{
  NSLog(@"played to end of file %@",notification);
  NSLog(@"Current time %@", NSStringFromCMTime(self.player.currentItem.currentTime));
  NSLog(@"Current duration %@", NSStringFromCMTime(self.player.currentItem.duration));
}

@end
