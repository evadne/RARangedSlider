//
//  RARangedSlider.h
//  RARangedSlider
//
//  Created by Evadne Wu on 12/11/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface RARangedSlider : UIControl

@property (nonatomic, readwrite, assign) float minValue;
@property (nonatomic, readwrite, assign) float maxValue;

@property (nonatomic, readwrite, assign) float lowValue;
@property (nonatomic, readwrite, assign) float highValue;

- (void) setLowValue:(float)lowValue highValue:(float)highValue animated:(BOOL)animate completion:(void(^)(void))completion;

@property (nonatomic, readwrite, getter=isContinuous) BOOL continuous;

- (void) setThumbImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *) thumbImageForState:(UIControlState)state;

- (void) setValueTrackImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *) valueTrackImageForState:(UIControlState)state;

- (void) setBackgroundTrackImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *) backgroundTrackImageForState:(UIControlState)state;

@property (nonatomic, readonly, strong) UIImage *currentActiveThumbImage;
@property (nonatomic, readonly, strong) UIImage *currentInactiveThumbImage;
@property (nonatomic, readonly, strong) UIImage *currentValueTrackImage;
@property (nonatomic, readonly, strong) UIImage *currentBackgroundTrackImage;

- (CGRect) backgroundTrackRectForBounds:(CGRect)bounds;
- (CGRect) valueTrackRectForBounds:(CGRect)bounds;
- (CGRect) thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value active:(BOOL)active;

@end
