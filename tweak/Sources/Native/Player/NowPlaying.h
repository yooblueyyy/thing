// The native look's player: Spotify's full screen player with the artwork background and glass header
// buttons (Player.x), the glass lyrics card (LyricsCard.x), the gestures' hookup (PlayerGestures.x) and the parts of it to hide (PlayerDeclutter.x). The glass
// lyrics page is Native/Lyrics/LyricsPage.x's and shares SGKeyLyricsCard ("Glass lyrics").
#import <UIKit/UIKit.h>

#define SGKeyPlayer @"spectra.player"
#define SGKeyPlayerBackdrop @"spectra.playerBackdrop"
#define SGKeyLyricsCard @"spectra.lyricsCard"

// Parts of the player to hide, one switch each (PlayerDeclutter.x). An unset switch is off.
#define SGHideShuffle @"spectra.hide.shuffle"
#define SGHideRepeat @"spectra.hide.repeat"
#define SGHideConnect @"spectra.hide.connect"
#define SGHideShare @"spectra.hide.share"
#define SGHideQueue @"spectra.hide.queue"
#define SGHideAddTo @"spectra.hide.addTo"
#define SGHideLyricsInline @"spectra.hide.lyricsInline"
#define SGHideLyricsCard @"spectra.hide.lyricsCard"
#define SGHideAboutArtist @"spectra.hide.aboutArtist"
#define SGHideRelatedVideos @"spectra.hide.relatedVideos"
#define SGHideSongDNA @"spectra.hide.songDNA"
#define SGHideLiveEvents @"spectra.hide.liveEvents"
#define SGHideExploreArtist @"spectra.hide.exploreArtist"
#define SGHideCredits @"spectra.hide.credits"
#define SGHideMerch @"spectra.hide.merch"
#define SGHideRecommendations @"spectra.hide.recommendations"

// The welcome tour's one switch for the player: on hides every card under the player but the
// lyrics, off shows them again. The player's buttons are not its business. Only the tour reads
// it; the hooks read the keys above.
#define SGKeyPlayerLyricsOnly @"spectra.hide.playerLyricsOnly"
void SGSetPlayerLyricsOnly(BOOL on);

@class SGModRow, SGModSection;
// PlayerSettings.m: the player screen's sections of the Player page, the Queue & devices page and the
// "Glass lyrics" row of the Lyrics page.
NSArray<SGModSection *> *SGNativePlayerScreenSections(void);
UIViewController *SGQueueSettingsPage(void);
SGModRow *SGGlassLyricsRow(void);
