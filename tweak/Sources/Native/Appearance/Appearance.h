// The native look's appearance: the AMOLED background (Amoled.x), the accent colour in place of
// Spotify's green (Accent.x), the soft top edge (EdgeEffect.x) and Repaint.x, which keeps what the
// native tweaks stripped transparent when Spotify repaints it. The switches are off until asked for.
#import <UIKit/UIKit.h>

#define SGKeyAmoled @"spectra.amoled"
#define SGKeyAccent @"spectra.accent"   // 0xRRGGBB; unset or negative keeps Spotify's own green

// App theme: Spotify's greys repainted in a tint. 0 keeps Spotify's own; the last is Custom, its
// background picked under SGKeyThemeCustom (0xRRGGBB). A theme with an accent sets SGKeyAccent when picked.
#define SGKeyTheme       @"spectra.theme"
#define SGKeyThemeCustom @"spectra.theme.custom"
NSArray<NSString *> *SGThemeNames(void);
NSString *SGThemeLabel(void);
void SGChooseTheme(void);

UIColor *SGAccentColor(void);   // nil while Spotify's own green is kept
NSString *SGAccentLabel(void);  // "#RRGGBB", or the name of Spotify's own
void SGPickAccent(void);        // the system colour picker over the top of the app, stored on the way out

@class SGModRow;
NSArray<SGModRow *> *SGNativeAppearanceRows(void);   // AMOLED and the accent colour, for the Appearance card
