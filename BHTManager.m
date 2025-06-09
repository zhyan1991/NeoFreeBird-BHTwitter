//
//  BHTdownloadManager.m
//  BHT
//
//  Created by BandarHelal on 24/12/1441 AH.
//

#import "BHTManager.h"
#import "SettingsViewController.h"
#import "BHTBundle/BHTBundle.h"

@implementation BHTManager
+ (bool)isDMVideoCell:(T1InlineMediaView *)view {
    if (view.playerIconViewType == 4) {
        return true;
    } else {
        return false;
    }
}
+ (void)cleanCache {
    NSArray <NSURL *> *DocumentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in DocumentFiles) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
    }
    
    NSArray <NSURL *> *TempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in TempFiles) {
        if ([file.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"mov"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file.pathExtension.lowercaseString isEqualToString:@"tmp"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file hasDirectoryPath]) {
            if ([BHTManager isEmpty:file]) {
                [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
            }
        }
    }
}
+ (BOOL)isEmpty:(NSURL *)url {
    NSArray *FolderFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    if (FolderFiles.count == 0) {
        return true;
    } else {
        return false;
    }
}
+ (NSString *)getDownloadingPersent:(float)per {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSNumber *number = [NSNumber numberWithFloat:per];
    return [numberFormatter stringFromNumber:number];
}
+ (NSString *)getVideoQuality:(NSString *)url {
    NSMutableArray *q = [NSMutableArray new];
    NSArray *splits = [url componentsSeparatedByString:@"/"];
    for (int i = 0; i < [splits count]; i++) {
        NSString *item = [splits objectAtIndex:i];
        NSArray *dir = [item componentsSeparatedByString:@"x"];
        for (int k = 0; k < [dir count]; k++) {
            NSString *item2 = [dir objectAtIndex:k];
            if (!(item2.length == 0)) {
                if ([BHTManager doesContainDigitsOnly:item2]) {
                    if (!(item2.integerValue > 10000)) {
                        if (!(q.count == 2)) {
                            [q addObject:item2];
                        }
                    }
                }
            }
        }
    }
    if (q.count == 0) {
        return @"GIF";
    }
    return [NSString stringWithFormat:@"%@x%@", q.firstObject, q.lastObject];
}
+ (BOOL)isVideoCell:(id <T1StatusViewModel>)model {
    return model.isMediaEntityVideo || model.isGIF;
}
+ (void)save:(NSURL *)url {
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } error:nil];
}
+ (void)showSaveVC:(NSURL *)url {
    UIActivityViewController *acVC = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    if (is_iPad()) {
        acVC.popoverPresentationController.sourceView = topMostController().view;
        acVC.popoverPresentationController.sourceRect = CGRectMake(topMostController().view.bounds.size.width / 2.0, topMostController().view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    [topMostController() presentViewController:acVC animated:true completion:nil];
}

+ (MediaInformation *)getM3U8Information:(NSURL *)mediaURL {
    MediaInformationSession *mediaInformationSession = [FFprobeKit getMediaInformation:mediaURL.absoluteString];
    MediaInformation *mediaInformation = [mediaInformationSession getMediaInformation];
    return mediaInformation;
}
+ (TFNMenuSheetViewController *)newFFmpegDownloadSheet:(MediaInformation *)mediaInformation downloadingURL:(NSURL *)downloadingURL progressView:(JGProgressHUD *)hud {
    NSAttributedString *AttString = [[NSAttributedString alloc] initWithString:[[BHTBundle sharedBundle] localizedStringForKey:@"DOWNLOAD_MENU_TITLE"] attributes:@{
        NSFontAttributeName: [[objc_getClass("TAEStandardFontGroup") sharedFontGroup] headline2BoldFont],
        NSForegroundColorAttributeName: UIColor.labelColor
    }];
    TFNActiveTextItem *title = [[objc_getClass("TFNActiveTextItem") alloc] initWithTextModel:[[objc_getClass("TFNAttributedTextModel") alloc] initWithAttributedString:AttString] activeRanges:nil];
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:title];
    
    for (StreamInformation *stream in [mediaInformation getStreams]) {
        NSNumber *width = [stream getWidth];
        NSNumber *height = [stream getHeight];
        if (width != nil && height != nil) {
            NSString *resolution = [NSString stringWithFormat:@"%@x%@", width, height];
            TFNActionItem *downloadOption = [objc_getClass("TFNActionItem") actionItemWithTitle:resolution imageName:@"arrow_down_circle_stroke" action:^{
                hud.textLabel.text = [[BHTBundle sharedBundle] localizedStringForKey:@"PROGRESS_DOWNLOADING_STATUS_TITLE"];
                [hud showInView:topMostController().view];

                NSURL *newFilePath = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", NSUUID.UUID.UUIDString]];
                [FFmpegKit executeAsync:[NSString stringWithFormat:@"-i %@ -vf scale=%@:flags=lanczos -b:v 2M -c:a copy %@", downloadingURL.absoluteString, resolution, newFilePath.path] withCompleteCallback:^(FFmpegSession *session) {
                    ReturnCode *returnCode = [session getReturnCode];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        if ([ReturnCode isSuccess:returnCode]) {
                            if (!([BHTManager DirectSave])) {
                                [hud dismiss];
                                [BHTManager showSaveVC:newFilePath];
                            } else {
                                [BHTManager save:newFilePath];
                            }
                        } else {
                            [hud dismiss];
                        }
                    });
                }];
            }];
            [actions addObject:downloadOption];
        }
    }
    
    TFNMenuSheetViewController *alert = [[objc_getClass("TFNMenuSheetViewController") alloc] initWithActionItems:[NSArray arrayWithArray:actions]];
    return alert;
}
+ (BOOL)DownloadingVideos {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dw_v"];
}
+ (BOOL)DirectSave {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"direct_save"];
}
+ (BOOL)LikeConfirm {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"like_con"];
}
+ (BOOL)TweetConfirm {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tweet_con"];
}
+ (BOOL)FollowConfirm {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"follow_con"];
}
+ (BOOL)HidePromoted {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_promoted"];
}
+ (BOOL)HideTopics {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_topics"];
}
+ (BOOL)DisableVODCaptions {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dis_VODCaptions"];
}
+ (BOOL)UndoTweet {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"undo_tweet"];
}
+ (BOOL)NoHistory {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"no_his"];
}
+ (BOOL)BioTranslate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bio_translate"];
}
+ (BOOL)Padlock {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"padlock"];
}
+ (BOOL)OldStyle {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"old_style"];
}
+ (BOOL)changeFont {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_font"];
}
+ (BOOL)FLEX {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"flex_twitter"];
}
+ (BOOL)autoHighestLoad {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoHighestLoad"];
}
+ (BOOL)disableSensitiveTweetWarnings {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disableSensitiveTweetWarnings"];
}
+ (BOOL)showScrollIndicator {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"showScollIndicator"];
}
+ (BOOL)CopyProfileInfo {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"CopyProfileInfo"];
}
+ (BOOL)tweetToImage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"TweetToImage"];
}
+ (BOOL)hideSpacesBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_spaces"];
}
+ (BOOL)disableRTL {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dis_rtl"];
}
+ (BOOL)alwaysOpenSafari {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"openInBrowser"];
}
+ (BOOL)hideWhoToFollow {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_who_to_follow"];
}
+ (BOOL)hideTopicsToFollow {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_topics_to_follow"];
}
+ (BOOL)hideViewCount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_view_count"];
}
+ (BOOL)hidePremiumOffer {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_premium_offer"];
}
+ (BOOL)hideTrendVideos {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_trend_videos"];
}
+ (BOOL)forceTweetFullFrame {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"force_tweet_full_frame"];
}
+ (BOOL)stripTrackingParams {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"strip_tracking_params"];
}
+ (BOOL)alwaysFollowingPage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"always_following_page"];
}
+ (BOOL)stopHidingTabBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"no_tab_bar_hiding"];
}
+ (BOOL)noTabBarHiding {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"no_tab_bar_hiding"];
}
+ (BOOL)changeBackground {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"change_msg_background"];
}
+ (bool)backgroundImage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"background_image"];
}
+ (BOOL)hideBookmarkButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_bookmark_button"];
}
+ (BOOL)customVoice {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"custom_voice_upload"];
}

+ (BOOL)RestoreTweetLabels {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"restore_tweet_labels"];
}

+ (BOOL)disableMediaTab {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disableMediaTab"];
}

+ (BOOL)disableArticles {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disableArticles"];
}

+ (BOOL)disableHighlights {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disableHighlights"];
}

// New feature toggles implementation
+ (BOOL)hideGrokAnalyze {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_grok_analyze"];
}

+ (BOOL)hideFollowButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_follow_button"];
}

+ (BOOL)restoreFollowButton {
    // Also controls hideSubscribeButton functionality
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"restore_follow_button"];
}

+ (BOOL)squareAvatars {
    // Simply return the current setting without any side effects
    // The alert will be handled exclusively by the Settings view controller
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"square_avatars"];
}

+ (BOOL)restoreVideoTimestamp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"restore_video_timestamp"];
}

+ (BOOL)dmAvatars {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dm_avatars"];
}

+ (BOOL)classicTabBarEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tab_bar_theming"];
}

+ (BOOL)restoreTabLabels {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"restore_tab_labels"];
}

+ (void)clearSourceLabelCache {
    // Post notification to trigger cache clearing in Tweak.x
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BHTClearSourceLabelCacheNotification" object:nil];
}

// Translate functionality
+ (BOOL)enableTranslate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_translate"];
}

+ (NSString *)translateEndpoint {
    NSString *endpoint = [[NSUserDefaults standardUserDefaults] stringForKey:@"translate_endpoint"];
    return endpoint ?: @"https://generativelanguage.googleapis.com/v1beta/models";
}

+ (NSString *)translateAPIKey {
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"translate_api_key"];
    return apiKey;
}

+ (NSString *)translateModel {
    NSString *model = [[NSUserDefaults standardUserDefaults] stringForKey:@"translate_model"];
    return model ?: @"gemini-1.5-flash";
}

+ (UIViewController *)BHTSettingsWithAccount:(TFNTwitterAccount *)twAccount {
    SettingsViewController *pref = [[SettingsViewController alloc] initWithTwitterAccount:twAccount];
    [pref.navigationItem setTitleView:[objc_getClass("TFNTitleView") titleViewWithTitle:@"NeoFreeBird" subtitle:twAccount.displayUsername]];
    return pref;
}

// https://stackoverflow.com/a/45356575/9910699
+ (BOOL)doesContainDigitsOnly:(NSString *)string {
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

    BOOL containsDigitsOnly = [string rangeOfCharacterFromSet:nonDigits].location == NSNotFound;

    return containsDigitsOnly;
}

+ (BOOL)doesContainNonDigitsOnly:(NSString *)string {
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];

    BOOL containsNonDigitsOnly = [string rangeOfCharacterFromSet:digits].location == NSNotFound;

    return containsNonDigitsOnly;
}

+ (BOOL)dmComposeBarV2 {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dm_compose_bar_v2_enabled"];
}

+ (BOOL)replySorting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"reply_sorting_enabled"];
}

+ (BOOL)dmVoiceCreation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dm_voice_creation_enabled"];
}

+ (BOOL)restoreReplyContext {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"restore_reply_context"];
}

@end

