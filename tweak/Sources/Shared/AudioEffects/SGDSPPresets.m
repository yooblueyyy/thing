// Sound presets: a reset, then a handful of effects set to a starting point. Values are the mod's own.
#import "AudioEffects.h"

typedef struct { NSString *name; double eq[15]; double bass; double wide; double tube; BOOL compander; } SGDSPSoundPreset;

static const SGDSPSoundPreset kPresets[] = {
    // 25 40 63 100 160 250 400 630 1k 1.6k 2.5k 4k 6.3k 10k 16k
    {@"Warm",       {2, 2, 1.5, 1, 0.5, 0.5, 0, 0, -0.5, -1, -1.5, -2, -2, -2.5, -3}, 0, 0, 3, NO},
    {@"Bass",       {5, 5, 4, 3, 1.5, 0, 0, 0, 0, 0, 0, 0, 0.5, 1, 1}, 6, 0, 0, NO},
    {@"Vocal",      {-2, -2, -1.5, -1, 0, 1, 2, 2.5, 3, 2.5, 2, 1, 0, -0.5, -1}, 0, 0, 0, YES},
    {@"Electronic", {4, 4, 3, 1.5, 0, -1, -1, 0, 0.5, 1, 2, 3, 3, 3.5, 3}, 4, 65, 0, NO},
    {@"Late night", {-1, -1, 0, 0, 0, 0, 0.5, 1, 1, 0.5, 0, -1, -2, -3, -3}, 0, 0, 0, YES},
};
static const NSInteger kCount = sizeof kPresets / sizeof *kPresets;

NSArray<NSString *> *SGDSPSoundPresetNames(void) {
    NSMutableArray *names = [NSMutableArray array];
    for (NSInteger i = 0; i < kCount; i++) [names addObject:kPresets[i].name];
    return names;
}

void SGDSPApplySoundPreset(NSInteger index) {
    if (index < 0 || index >= kCount) return;
    const SGDSPSoundPreset *p = &kPresets[index];
    SGDSPResetAll();
    NSMutableArray *gains = [NSMutableArray array];
    for (int i = 0; i < 15; i++) [gains addObject:@(p->eq[i])];
    SGDSPSetGains(SGKeyDSPEqualizerGains, gains);
    SGDSPSetSwitch(SGKeyDSPEqualizer, YES);
    if (p->bass > 0) { SGDSPSetNumber(SGKeyDSPBassGain, p->bass); SGDSPSetSwitch(SGKeyDSPBass, YES); }
    if (p->wide > 0) { SGDSPSetNumber(SGKeyDSPStereoWideLevel, p->wide); SGDSPSetSwitch(SGKeyDSPStereoWide, YES); }
    if (p->tube > 0) { SGDSPSetNumber(SGKeyDSPTubeDrive, p->tube); SGDSPSetSwitch(SGKeyDSPTube, YES); }
    if (p->compander) SGDSPSetSwitch(SGKeyDSPCompander, YES);
    if (!SGDSPSwitch(SGKeyDSP)) SGDSPSetSwitch(SGKeyDSP, YES);
}
