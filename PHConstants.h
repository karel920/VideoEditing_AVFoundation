//
//  PHConstants.h
//  PrepHero
//
//  Created by Xinjiang Shao on 7/17/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#ifndef PrepHero_PHConstants_h
#define PrepHero_PHConstants_h

// Identifiers
static NSString *const capViewControllerIdentifier = @"captureViewControllerIdentifier";
static NSString *const PHMainTabBarStoryboardID = @"PHMainTabBarStoryboardID";
// All Notifications
static NSString *const PHUserLoggedInSuccessfulNotification = @"PHUserLoggedInSuccessfulNotification";
static NSString *const PHUserLoggedInFailureNotification = @"PHUserLoggedInFailureNotification";
static NSString *const PHUserLoggedOutNotification = @"PHUserLoggedOutNotification";
static NSString *const PHVideoCreatedNotification = @"PHVideoCreatedNotification";
static NSString *const PHVideoClipedNotification = @"PHVideoClipedNotification";
static NSString *const kPHKeychainServiceName = @"PrepHeroKeychainService";
// DB management
static NSString *const PHCapturedVideos = @"created";
static NSString *const PHHighLightsVideos = @"cliped";
static NSString *const ClipedVideos = @"Videos";
static NSString *const ClipedVideoName = @"ClipedVideoName";
static NSString *const ClipedDescription = @"ClipedDescription";
static NSString *const ClipedDate = @"ClipedDate";
static NSString *const DeletVideo = @"Delete";

// Button Color
static NSString *const WhiteButtonBackGroundColor = @"BBBBBB";
static NSString *const WhiteButtonActiveColor = @"313131";
static NSString *const RedButtonBackgroundColor = @"BB2A26";
static NSString *const RedButtonActiveColor = @"7F1F1F";
static NSString *const GreenButtonBackgroundColor = @"53A650";
static NSString *const GreenButtonActiveColor = @"153B2C";
static NSString *const YellowButtonBackgroundColor = @"EEAA44";
static NSString *const YellowButtonActiveColor = @"AA6005";
#define kPHMaxRecordDuration 10.0f

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(NSInteger, DGBLevel) {
    DBGError = 0,
    DBGWarning,
    DBGLog,
    DBGDebug
};

typedef NS_ENUM(NSInteger, VideoResolution) {
    VideoResolution_192x144 = 0,
    VideoResolution_320x240,
    VideoResolution_480x360,
    VideoResolution_640x480,
    VideoResolution_1280x720,
    VideoResolution_1920x1080
};

typedef NS_ENUM(NSInteger, Video_Orientation) {
    Orientation_Portrait           = 1,
    Orientation_PortraitUpsideDown,
    Orientation_LandscapeRight,
    Orientation_LandscapeLeft,
    Orientation_All
};

typedef NS_ENUM(NSInteger, MaximumBitrates) {
    MaximumBitrate_192x144   =   128 * 1000,
    MaximumBitrate_320x240   =   700 * 1000,
    MaximumBitrate_480x360   =  3500 * 1000,
    MaximumBitrate_640x480   =  3500 * 1000,
    MaximumBitrate_1280x720  =  5000 * 1000,
    MaximumBitrate_1920x1080 = 10000 * 1000
};

typedef NS_ENUM(NSInteger, MinimumBitrates) {
    MinimumBitrate_192x144   =   50 * 1000,
    MinimumBitrate_320x240   =  128 * 1000,
    MinimumBitrate_480x360   =  200 * 1000,
    MinimumBitrate_640x480   =  350 * 1000,
    MinimumBitrate_1280x720  = 1500 * 1000,
    MinimumBitrate_1920x1080 = 3000 * 1000
};

typedef NS_ENUM(NSInteger, RecordingState) {
    RecordingState_Error = 0,
    RecordingState_Warning,
    RecordingState_Ready,
    RecordingState_Starting,
    RecordingState_Started,
    RecordingState_Stopping,
    RecordingState_Stopped
};

typedef NS_ENUM(NSInteger, MarkButtonsState) {
    MarkButtonsState_Beginning = 5,
    MarkButtonsState_Yourself,
    MarkButtonsState_End,
    MarkButtonsState_UnBeginning,
    MarkButtonsState_UnYourself,
    MarkButtonsState_UnEnd
};

typedef NS_ENUM(NSInteger, VideoPlayingState) {
    VideoPlayingState_Play = 1,
    VideoPlayingState_Slow ,
    VideoPlayingState_Slower,
    VideoPlayingState_Pause
};

typedef NS_ENUM(NSInteger, SegmentSelection) {
    SegmentSel_Videos = 0,
    SegmentSel_RowVideos,
    SegmentSel_Highlights
};

typedef NS_ENUM(NSInteger, ClipTimeChange) {
    ClipTimeChange_Beginnig = 1,
    ClipTimeChange_Yourself,
    ClipTimeChange_End
};

#define kDefaultFramesPerSecond 24
#define kDefaultKeyFrameInterval 30
#define kDefaultBufferLength 0.4
#define kDefaultBufferCount 25
#define kDefaultAudioRate 44100.0

#define DBG DBGDebug

#define nlog(level, message, ...) \
if (DBG >= level) NSLog(message, __VA_ARGS__);

#define nlog2(level, message) \
if (DBG >= level) NSLog(message);

#define elog(message, code, ...) {               \
char errstr[255];                              \
av_strerror(code, errstr, 255);                \
nlog(DBGError, message, __VA_ARGS__, errstr); \
}

#define elog2(message, code) {      \
char errstr[255];                 \
av_strerror(code, errstr, 255);   \
nlog(DBGError, message, errstr); \
}

#endif
