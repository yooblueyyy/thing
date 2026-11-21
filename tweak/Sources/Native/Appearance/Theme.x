// App themes: the base grey (#121212) and the elevated greys over it (#1F1F1F placeholders, #292929
// cards, up to #333333) are repainted from one background colour, the elevated ones lighter by as much as
// Spotify's are over its base, so the layering reads the same. Same hooks and same greys as Amoled.x,
// which wins when both are on.
#import "Core/SGCore.h"
#import "Appearance.h"

typedef struct { NSString *name; uint32_t background; int32_t accent; } SGTheme;

// The mod's own palettes. accent -1 leaves the accent colour alone.
static const SGTheme kThemes[] = {
    {@"Spotify", 0, -1},
    {@"Midnight", 0x0B1020, 0x6C8CFF},
    {@"Forest", 0x0C1A12, 0x4CD38A},
    {@"Plum", 0x1A0E1E, 0xD27BFF},
    {@"Mocha", 0x1C140F, 0xE0A46B},
    {@"Ocean", 0x071820, 0x3CC8E0},
    {@"Crimson", 0x1E0A0C, 0xFF5A66},
    {@"Graphite", 0x17181B, 0xB8C0CC},
    {@"Custom", 0, -1},
};
static const NSInteger kCount = sizeof kThemes / sizeof *kThemes;

static NSInteger chosen(void) {
    NSInteger i = SGInt(SGKeyTheme, 0);
    return i >= 0 && i < kCount ? i : 0;
}

NSArray<NSString *> *SGThemeNames(void) {
    NSMutableArray *names = [NSMutableArray array];
    for (NSInteger i = 0; i < kCount; i++) [names addObject:kThemes[i].name];
    return names;
}

NSString *SGThemeLabel(void) {
    return kThemes[chosen()].name;
}

static CGFloat sBg[3];

// Neutral greys from just above black to #333333; the darkest of them is Spotify's base.
static BOOL greyLevel(CGColorRef color, CGFloat *level) {
    if (!color || CFGetTypeID(color) != CGColorGetTypeID()) return NO;
    const CGFloat *c = CGColorGetComponents(color);
    size_t n = CGColorGetNumberOfComponents(color);
    if (n == 2) { *level = c[0]; }
    else if (n >= 3 && fabs(c[0] - c[1]) < 0.02 && fabs(c[1] - c[2]) < 0.02) { *level = c[0]; }
    else return NO;
    return *level > 0.01 && *level <= 0.20;
}

// #121212 (0.07) maps to the background; each step lighter adds the same to every channel.
static CGColorRef copyTinted(CGColorRef color, CGFloat level) {
    CGFloat lift = MAX(0, level - 0.07);
    CGFloat comps[4] = {MIN(1, sBg[0] + lift), MIN(1, sBg[1] + lift), MIN(1, sBg[2] + lift), CGColorGetAlpha(color)};
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGColorRef out = CGColorCreate(space, comps);
    CGColorSpaceRelease(space);
    return out;
}

%hook CALayer
- (void)setBackgroundColor:(CGColorRef)color {
    CGFloat level;
    if (!greyLevel(color, &level)) { %orig; return; }
    CGColorRef tinted = copyTinted(color, level);
    %orig(tinted);
    CGColorRelease(tinted);
}
%end

%hook CAGradientLayer
- (void)setColors:(NSArray *)colors {
    NSMutableArray *mapped = [[NSMutableArray alloc] initWithCapacity:colors.count];
    for (id entry in colors) {
        CGColorRef color = (__bridge CGColorRef)entry;
        CGFloat level;
        if (!greyLevel(color, &level)) { [mapped addObject:entry]; continue; }
        CGColorRef tinted = copyTinted(color, level);
        [mapped addObject:(__bridge id)tinted];
        CGColorRelease(tinted);
    }
    %orig(colors ? mapped : nil);
}
%end

#pragma mark - choosing

static void SGPromptRestart(void) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restart Spotify?"
        message:@"The theme shows after Spotify restarts." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Restart now" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { SGRestartSpotify(); }]];
    [SGTopController() presentViewController:alert animated:YES completion:nil];
}

@interface SGThemePicker : NSObject <UIColorPickerViewControllerDelegate>
@end

@implementation SGThemePicker
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)picker {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [picker.selectedColor getRed:&r green:&g blue:&b alpha:&a];
    uint32_t rgb = ((uint32_t)lround(MIN(1, MAX(0, r)) * 255) << 16)
                 | ((uint32_t)lround(MIN(1, MAX(0, g)) * 255) << 8)
                 | (uint32_t)lround(MIN(1, MAX(0, b)) * 255);
    SGSetInt(SGKeyThemeCustom, rgb);
    SGSetInt(SGKeyTheme, kCount - 1);
    SGPromptRestart();
}
@end

static void pickCustom(void) {
    static SGThemePicker *delegate;
    if (!delegate) delegate = [SGThemePicker new];
    UIColorPickerViewController *picker = [UIColorPickerViewController new];
    picker.title = @"Background";
    picker.supportsAlpha = NO;
    NSInteger rgb = SGInt(SGKeyThemeCustom, 0x141414);
    picker.selectedColor = [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0 green:((rgb >> 8) & 0xFF) / 255.0 blue:(rgb & 0xFF) / 255.0 alpha:1];
    picker.delegate = delegate;
    [SGTopController() presentViewController:picker animated:YES completion:nil];
}

void SGChooseTheme(void) {
    UIViewController *top = SGTopController();
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Theme"
        message:@"Repaints Spotify's backgrounds and cards, and sets a matching accent. Applies after a restart." preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < kCount; i++) {
        BOOL custom = i == kCount - 1;
        NSString *title = i == chosen() ? [kThemes[i].name stringByAppendingString:@" ✓"] : kThemes[i].name;
        [sheet addAction:[UIAlertAction actionWithTitle:custom ? @"Custom…" : title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (custom) { pickCustom(); return; }
            SGSetInt(SGKeyTheme, i);
            if (kThemes[i].accent >= 0) SGSetInt(SGKeyAccent, kThemes[i].accent);
            SGPromptRestart();
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = top.view;
    sheet.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(top.view.bounds), CGRectGetMidY(top.view.bounds), 0, 0);
    sheet.popoverPresentationController.permittedArrowDirections = 0;
    [top presentViewController:sheet animated:YES completion:nil];
}

%ctor {
    if (!SGNativeUI()) return;
    NSInteger i = chosen();
    if (i == 0 || SGFlag(SGKeyAmoled, NO)) return;
    uint32_t rgb = i == kCount - 1 ? (uint32_t)SGInt(SGKeyThemeCustom, 0x141414) : kThemes[i].background;
    sBg[0] = ((rgb >> 16) & 0xFF) / 255.0; sBg[1] = ((rgb >> 8) & 0xFF) / 255.0; sBg[2] = (rgb & 0xFF) / 255.0;
    %init;
}
