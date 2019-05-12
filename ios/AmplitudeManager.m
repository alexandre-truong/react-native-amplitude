//
//  OGWaveManager.m
//  OGReactNativeWaveform
//
//  Created by juan Jimenez on 10/01/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "AmplitudeManager.h"
//#import "OGWaveUtils.h"
#import <React/UIView+React.h>


@implementation OGWaveManager

RCT_EXPORT_VIEW_PROPERTY(waveFormStyle, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(src, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(autoPlay, BOOL);
RCT_EXPORT_VIEW_PROPERTY(play, BOOL);
RCT_EXPORT_VIEW_PROPERTY(stop, BOOL);
RCT_EXPORT_VIEW_PROPERTY(volume, float);
RCT_EXPORT_VIEW_PROPERTY(componentID, NSString);
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFinishPlay, RCTBubblingEventBlock);

//RCT_EXPORT_VIEW_PROPERTY(test, NSNumber);


//- (UIView *)view
//{

//    OGWaverformView *OGWaveformView =  [[OGWaverformView alloc] initWithBridge:self.bridge];
//    [OGWaveformView setDelegate:self];
//    return OGWaveformView;
//}
RCT_EXPORT_MODULE(Amplitude);

RCT_EXPORT_METHOD(alertSth:(NSString *)string)
{
    RCTLogInfo(@"ALERT :  %@", string);
}

//RCT_EXPORT_METHOD(getNb:(NSString *)_soundPath:(RCTResponseSenderBlock)callback)
//{
//    NSNumber *nb = [NSNumber numberWithInteger:1];
//    callback(@[[NSNull null], _soundPath]);
//}

RCT_EXPORT_METHOD(getAmplitudeValues:(NSString *)_fileName:(RCTResponseSenderBlock)callback)
{
//    OGWaverformView *OGWaveformView = [[OGWaverformView alloc] init];
    
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"audio"];
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    NSLog(@"resource path : %@", resourcePath);
    NSLog(@"path of document resource directory : %@", documentsPath);
    NSLog(@"array of files in resource directory : %@", directoryContents);
    
    NSLog(@"File to read : %@", _fileName);
    
    NSString * audioFilePath = [documentsPath stringByAppendingPathComponent: _fileName];
    
    NSURL *url;
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
        url = [NSURL fileURLWithPath:audioFilePath];
        NSLog(@"file exists at url %@", url);
    }
    else NSLog(@"file does not exist");
    
    
    
    
    
//    NSString *uri = @"http://192.168.1.67:8081/assets/audio/wildbot.mp3?platform=ios&hash=a0aeef81cd0bef009c7daa519e9b6957";
//    [OGWaveformView setSrcWithURI:@"http://192.168.1.67:8081/assets/audio/wildbot.mp3?platform=ios&hash=a0aeef81cd0bef009c7daa519e9b6957"];
    
    
//    NSLog(@"URI ::: %@",uri);
    
    //Since any file sent from JS side in React Native is through HTTP, and
    //AVURLAsset just works wiht local files, then, downloading and processing.
//    NSURL  *remoteUrl = [NSURL URLWithString:uri];
    
    NSLog(@"NSURLRequest :: %@",url);
    
    NSLog(@"Step 3 before connection");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         NSLog(@"balh %@",connectionError);
         if (data.length > 0 && connectionError == nil)
         {
             NSLog(@"data : %@", data);
             _mdata = [[NSMutableData alloc]init];
             [_mdata appendData:data];
             
             //connectionDidFinishLoading
//             NSString *fileName = [NSString stringWithFormat:@"%@.aac",[OGWaveUtils randomStringWithLength:5]];
             NSString *fileName = [NSString stringWithFormat:@"electric_theater_tmp.aac"];
             
             _soundPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
             [_mdata writeToFile:_soundPath atomically:YES];
             
             NSURL * localUrl = [NSURL fileURLWithPath: _soundPath];
             _asset = [AVURLAsset assetWithURL: localUrl];
             
             NSMutableArray *amplitude = [self getAmplitudeData:_asset];
             NSLog(@"AMPLITUDE : %@", amplitude);
             if(amplitude) callback(@[[NSNull null], amplitude]);
             else callback(@[[NSNull null], @"no, data null"]);
         }
         else NSLog(@"no data");
     }];
    
    
    
//    NSMutableArray *data = [[NSMutableArray alloc] initWithObjects:@"H:S", @"H:W", @"H:AGR", @"H:TPC", @"H:P", @"H:TI", nil];
//    callback(@[[NSNull null], localUrl]);
    
    
//    [NSThread sleepForTimeInterval:2.0f];
//    NSNumber *nb = [NSNumber numberWithInteger:1];
//    callback(@[[NSNull null], _mdata]);
}


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

//#pragma mark OGWaveDelegateProtocol
//-(void)OGWaveOnTouch:(OGWaverformView *)waveformView componentID:(NSString *)componentID{
//    if(!waveformView.onPress)
//        return;
//
//    waveformView.onPress(@{@"onPress":@"true",@"currentStatus":@"playing",@"componentID":componentID});
//}
//-(void)OGWaveFinishPlay:(OGWaverformView *)waveformView componentID:(NSString *)componentID{
//    if(!waveformView.onFinishPlay)
//        return;
//
//    waveformView.onFinishPlay(@{@"onFinishPlay":@"true",@"currentStatus":@"stopped",@"componentID":componentID});
//}










#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)



- (NSMutableArray *) getAmplitudeData:(AVURLAsset *)songAsset {
    
    NSError * error = nil;
    
    AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    if (songAsset.tracks.count == 0) {
        return nil;
    }
    AVAssetTrack * songTrack = [songAsset.tracks objectAtIndex:0];
    
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        //     [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
                                        //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,    /*Not Supported*/
                                        
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        
                                        nil];
    
    if(error){
        NSLog(@"ERROROR : %@",error.description);
    }
    
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    UInt32 sampleRate,channelCount;
    
    NSArray* formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if(fmtDesc ) {
            
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
            
            //    NSLog(@"channels:%u, bytes/packet: %u, sampleRate %f",fmtDesc->mChannelsPerFrame, fmtDesc->mBytesPerPacket,fmtDesc->mSampleRate);
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    Float32 normalizeMax = noiseFloor;
    NSLog(@"normalizeMax = %f",normalizeMax);
    NSMutableData * fullSongData = [[NSMutableData alloc] init];
    NSMutableArray * myData = [[NSMutableArray alloc] init];
    [reader startReading];
    
    UInt64 totalBytes = 0;
    
    Float64 totalLeft = 0;
    Float64 totalRight = 0;
    Float32 sampleTally = 0;
    
    NSInteger samplesPerPixel = sampleRate / 50;
    
    while (reader.status == AVAssetReaderStatusReading){
        
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef){
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            
            
            
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
            
            
            SInt16 * samples = (SInt16 *) data.mutableBytes;
            int sampleCount = length / bytesPerSample;
            for (int i = 0; i < sampleCount ; i ++) {
                
                Float32 left = (Float32) *samples++;
//                                NSLog(@"left value : %f", left);
                
                left = decibel(left);
                left = minMaxX(left,noiseFloor,0);
                
                totalLeft  += left;
                
                
                
                Float32 right;
                if (channelCount==2) {
                    right = (Float32) *samples++;
                    right = decibel(right);
                    right = minMaxX(right,noiseFloor,0);
                    
                    totalRight += right;
                }
                
                sampleTally++;
                
                if (sampleTally > samplesPerPixel) {
                    
                    left  = totalLeft / sampleTally;
                    if (left > normalizeMax) {
                        normalizeMax = left;
                    }
                    // NSLog(@"left average = %f, normalizeMax = %f",left,normalizeMax);
                    
                    [fullSongData appendBytes:&left length:sizeof(left)];
                    [myData addObject:[NSNumber numberWithInteger:left]];
                    
                    if (channelCount==2) {
                        right = totalRight / sampleTally;
                        
                        
                        if (right > normalizeMax) {
                            normalizeMax = right;
                        }
                        
                        [fullSongData appendBytes:&right length:sizeof(right)];
                    }
                    
                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                    
                }
            }
            
            
            
            CMSampleBufferInvalidate(sampleBufferRef);
            
            CFRelease(sampleBufferRef);
        }
    }
//    NSMutableArray *data = [[NSMutableArray alloc] initWithObjects:@"H:S", @"H:W", @"H:AGR", @"H:TPC", @"H:P", @"H:TI", nil];
    return myData;
}






@end
