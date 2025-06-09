//
//  BHTdownloadManager.h
//  BHT
//
//  Created by BandarHelal on 24/12/1441 AH.
//

#import "TWHeaders.h"


@interface BHTManager : NSObject
+ (NSString *)getDownloadingPersent:(float)per;
+ (void)cleanCache;
+ (NSString *)getVideoQuality:(NSString *)url;
+ (BOOL)isVideoCell:(id <T1StatusViewModel>)model;
+ (bool)isDMVideoCell:(T1InlineMediaView *)view;
+ (BOOL)doesContainDigitsOnly:(NSString *)string;
+ (UIViewController *)BHTSettingsWithAccount:(TFNTwitterAccount *)twAccount;
+ (void)showSaveVC:(NSURL *)url;
+ (void)save:(NSURL *)url;
+ (MediaInformation *)getM3U8Information:(NSURL *)mediaURL;
+ (TFNMenuSheetViewController *)newFFmpegDownloadSheet:(MediaInformation *)mediaInformation downloadingURL:(NSURL *)downloadingURL progressView:(JGProgressHUD *)hud;

+ (BOOL)DownloadingVideos;
+ (BOOL)DirectSave;
+ (BOOL)UndoTweet;
+ (BOOL)NoHistory;
+ (BOOL)BioTranslate;
+ (BOOL)LikeConfirm;
+ (BOOL)TweetConfirm;
+ (BOOL)FollowConfirm;
+ (BOOL)HidePromoted;
+ (BOOL)HideTopics;
+ (BOOL)DisableVODCaptions;
+ (BOOL)Padlock;
+ (BOOL)OldStyle;
+ (BOOL)changeFont;
+ (BOOL)FLEX;
+ (BOOL)autoHighestLoad;
+ (BOOL)disableSensitiveTweetWarnings;
+ (BOOL)showScrollIndicator;
+ (BOOL)CopyProfileInfo;
+ (BOOL)tweetToImage;
+ (BOOL)hideSpacesBar;
+ (BOOL)disableRTL;
+ (BOOL)alwaysOpenSafari;
+ (BOOL)hideWhoToFollow;
+ (BOOL)hideTopicsToFollow;
+ (BOOL)hideViewCount;
+ (BOOL)hidePremiumOffer;
+ (BOOL)hideTrendVideos;
+ (BOOL)forceTweetFullFrame;
+ (BOOL)stripTrackingParams;
+ (BOOL)alwaysFollowingPage;
+ (BOOL)stopHidingTabBar;
+ (BOOL)changeBackground;
+ (bool)backgroundImage;
+ (BOOL)hideBookmarkButton;
+ (BOOL)customVoice;
+ (BOOL)RestoreTweetLabels;
+ (BOOL)disableMediaTab;
+ (BOOL)disableArticles;
+ (BOOL)disableHighlights;

+ (BOOL)hideGrokAnalyze;
+ (BOOL)hideFollowButton;
+ (BOOL)restoreFollowButton;
+ (BOOL)squareAvatars;
+ (BOOL)restoreVideoTimestamp;
+ (BOOL)dmAvatars;
+ (BOOL)classicTabBarEnabled;
+ (BOOL)restoreTabLabels;
+ (BOOL)noTabBarHiding;

// Translate functionality
+ (BOOL)enableTranslate;
+ (NSString *)translateEndpoint;
+ (NSString *)translateAPIKey;
+ (NSString *)translateModel;

+ (BOOL)dmComposeBarV2;
+ (BOOL)replySorting;
+ (BOOL)dmVoiceCreation;

+ (void)clearSourceLabelCache;

+ (BOOL)restoreReplyContext;

@end

