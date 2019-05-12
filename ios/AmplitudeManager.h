//
//  OGWaveManager.h
//  OGReactNativeWaveform
//
//  Created by juan Jimenez on 10/01/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <React/RCTViewManager.h>
//#import "OGWaveDelegateProtocol.h"
//#import "OGWaverformView.h"

#import <AVFoundation/AVFoundation.h>

@interface OGWaveManager : RCTViewManager 

@property(nonatomic) NSMutableData * mdata;
@property(nonatomic) AVURLAsset *asset;
@property(nonatomic) NSString *soundPath;

@end
