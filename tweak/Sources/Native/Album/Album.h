// Album: parts of the album page hidden one switch each, and the cover behind its header (Album.x).
// An unset switch is off.
#import <UIKit/UIKit.h>

#define SGKeyAlbumBackdrop @"spectra.albumBackdrop"

#define SGHideAlbumExplore @"spectra.hide.albumExplore"
#define SGHideAlbumAddTo @"spectra.hide.albumAddTo"
#define SGHideAlbumDownload @"spectra.hide.albumDownload"
#define SGHideAlbumMore @"spectra.hide.albumMore"

#define SGHideAlbumMoreBy @"spectra.hide.albumMoreBy"
#define SGHideAlbumVideos @"spectra.hide.albumVideos"
#define SGHideAlbumConcerts @"spectra.hide.albumConcerts"
#define SGHideAlbumMerch @"spectra.hide.albumMerch"
#define SGHideAlbumYouMightLike @"spectra.hide.albumYouMightLike"

UIViewController *SGAlbumSettingsPage(void);   // opened from the Home & Library page
