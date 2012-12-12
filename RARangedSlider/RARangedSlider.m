//
//  RARangedSlider.m
//  RARangedSlider
//
//  Created by Evadne Wu on 12/11/12.
//  Copyright (c) 2012 Radius. All rights reserved.
//

#import "RARangedSlider.h"

extern NSString * SPStringFromUIControlState (UIControlState state);

@interface RARangedSlider () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, assign) float minValue;
@property (nonatomic, readwrite, assign) float maxValue;

@property (nonatomic, readwrite, assign) float lowValue;
@property (nonatomic, readwrite, assign) float highValue;

@property (nonatomic, readonly, strong) UIImageView *backgroundTrackView;
@property (nonatomic, readonly, strong) UIImageView *valueTrackView;
@property (nonatomic, readonly, strong) UIImageView *lowThumbView;
@property (nonatomic, readonly, strong) UIImageView *highThumbView;

@property (nonatomic, readwrite, weak) UIView *trackedThumbView;

@property (nonatomic, readonly, strong) NSMutableDictionary *thumbImages;
@property (nonatomic, readonly, strong) NSMutableDictionary *valueTrackImages;
@property (nonatomic, readonly, strong) NSMutableDictionary *backgroundTrackImages;

@end

@implementation RARangedSlider
@synthesize backgroundTrackView = _backgroundTrackView;
@synthesize valueTrackView = _valueTrackView;
@synthesize lowThumbView = _lowThumbView;
@synthesize highThumbView = _highThumbView;
@synthesize trackedThumbView = _trackedThumbView;
@synthesize thumbImages = _thumbImages;
@synthesize valueTrackImages = _valueTrackImages;
@synthesize backgroundTrackImages = _backgroundTrackImages;

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	[self commonInit];
	
	return self;
	
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (!self)
		return nil;
	
	[self commonInit];
	
	return self;

}

- (void) commonInit {

	_minValue = 0.0f;
	_maxValue = 1.0f;
	_lowValue = 0.25f;
	_highValue = 0.75f;
	
	_thumbImages = [NSMutableDictionary dictionary];
	_valueTrackImages = [NSMutableDictionary dictionary];
	_backgroundTrackImages = [NSMutableDictionary dictionary];
	
	UIImage * (^image)(NSString *) = ^ (NSString *imageName) {
		
		NSString *name = [NSString stringWithFormat:@"RARangedSlider.bundle/%@.png", imageName];
		UIImage *image = [UIImage imageNamed:name];
		
		NSCParameterAssert(name && image);
		return image;
		
	};
	
	[self setBackgroundTrackImage:[image(@"UISliderWhite") stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal];
	[self setValueTrackImage:[image(@"UISliderBlue") stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal];
	[self setThumbImage:image(@"UISliderHandle") forState:UIControlStateNormal];
	[self setThumbImage:image(@"UISliderHandleDown") forState:UIControlStateHighlighted];
	
	[self addSubview:self.backgroundTrackView];
	[self addSubview:self.valueTrackView];
	[self addSubview:self.lowThumbView];
	[self addSubview:self.highThumbView];
	
}

- (void) layoutSubviews {

	[super layoutSubviews];
	
	CGRect bounds = self.bounds;
	
	BOOL lowThumbActive = (self.trackedThumbView == self.lowThumbView);
	BOOL highThumbActive = (self.trackedThumbView == self.highThumbView);
	
	CGRect trackRect = [self backgroundTrackRectForBounds:bounds];
	CGRect valueTrackRect = [self valueTrackRectForBounds:bounds];
	CGRect lowThumbRect = [self thumbRectForBounds:bounds trackRect:trackRect value:self.lowValue active:lowThumbActive];
	CGRect highThumbRect = [self thumbRectForBounds:bounds trackRect:trackRect value:self.highValue active:highThumbActive];
		
	self.backgroundTrackView.frame = trackRect;
	self.backgroundTrackView.image = self.currentBackgroundTrackImage;
	self.valueTrackView.frame = valueTrackRect;
	self.valueTrackView.image = self.currentValueTrackImage;
	self.lowThumbView.frame = lowThumbRect;
	self.lowThumbView.image = lowThumbActive ?
		self.currentActiveThumbImage :
		self.currentInactiveThumbImage;
	self.highThumbView.frame = highThumbRect;
	self.highThumbView.image = highThumbActive ?
		self.currentActiveThumbImage :
		self.currentInactiveThumbImage;

	[self.trackedThumbView.superview bringSubviewToFront:self.trackedThumbView];

}

- (void) setLowValue:(float)lowValue highValue:(float)highValue animated:(BOOL)animate completion:(void (^)(void))completion {
	
	[UIView animateWithDuration:(animate ? 0.35f : 0.0f) delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
		
		self.lowValue = lowValue;
		self.highValue = highValue;
		
		[self layoutSubviews];
	
	} completion:^(BOOL finished) {
		
		if (completion)
			completion();
		
	}];
	
}

- (UIView *) thumbForTouchAtPoint:(CGPoint)point {

	typeof(self.lowThumbView) ltv = self.lowThumbView;
	typeof(self.highThumbView) htv = self.highThumbView;
	
	CGFloat (^distance)(CGPoint, CGPoint) = ^ (CGPoint lhs, CGPoint rhs) {
		return sqrtf(powf(lhs.x - rhs.x, 2) + powf(lhs.y - rhs.y, 2));
	};
	
	CGFloat const tolerance = 44.0f;
	
	CGFloat ltvDistance = distance([ltv convertPoint:ltv.center fromView:ltv.superview], [ltv convertPoint:point fromView:self]);
	CGFloat htvDistance = distance([htv convertPoint:htv.center fromView:htv.superview], [htv convertPoint:point fromView:self]);
	
	return (ltvDistance < tolerance) ?
		((htvDistance < ltvDistance) ? htv : ltv) :
			(htvDistance < tolerance) ?
				htv :
				nil;

}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	UIView *superAnswer = [super hitTest:point withEvent:event];
	if (superAnswer)
		return superAnswer;
	
	return [self thumbForTouchAtPoint:point];

}

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {

	UIView *hitThumbView = [self thumbForTouchAtPoint:[touch locationInView:self]];
		
	if (hitThumbView) {
	
		self.trackedThumbView = hitThumbView;
				
		[self setNeedsLayout];
		
		return YES;
	
	}
	
	return NO;

}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {

	self.trackedThumbView.center = [touch locationInView:self];
	CGFloat newValue = MIN(self.maxValue, MAX(self.minValue, [self valueForThumbRect:self.trackedThumbView.frame inTrackRect:[self backgroundTrackRectForBounds:self.bounds]]));
	
	if (self.trackedThumbView == self.highThumbView) {
		
		if (newValue < self.lowValue) {
			
			self.trackedThumbView = self.lowThumbView;
			self.highValue = self.lowValue;
			self.lowValue = newValue;
			
		} else {
			
			self.highValue = newValue;
		
		}
		
	} else if (self.trackedThumbView == self.lowThumbView) {
		
		if (newValue > self.highValue) {
			
			self.trackedThumbView = self.highThumbView;
			self.lowValue = self.highValue;
			self.highValue = newValue;
			
		} else {
			
			self.lowValue = newValue;
		
		}
		
	} else {
		
		return NO;
		
	}
	
	NSCParameterAssert(self.maxValue >= self.highValue);
	NSCParameterAssert(self.highValue >= self.lowValue);
	NSCParameterAssert(self.lowValue >= self.minValue);
	
	[self setNeedsLayout];
	
	if (self.continuous){
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
	
	return YES;

}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	
	[super endTrackingWithTouch:touch withEvent:event];
	
	self.trackedThumbView = nil;

	[self setNeedsLayout];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	
}

- (void) cancelTrackingWithEvent:(UIEvent *)event {

	[super cancelTrackingWithEvent:event];

	self.trackedThumbView = nil;

	[self setNeedsLayout];
	
}

- (CGRect) backgroundTrackRectForBounds:(CGRect)bounds {

	CGFloat height = self.currentBackgroundTrackImage.size.height;
	
	return (CGRect){
		(CGPoint){
			0.0f,
			roundf(0.5f * (CGRectGetHeight(bounds) - height))
		},
		(CGSize){
			CGRectGetWidth(bounds),
			height
		}
	};
	
	return CGRectZero;

}

- (CGRect) valueTrackRectForBounds:(CGRect)bounds {

	CGFloat width = CGRectGetWidth(bounds);
	CGFloat height = self.currentValueTrackImage.size.height;
	
	CGFloat valueSpan = (self.maxValue - self.minValue);
	CGFloat lowValuePoint = (self.lowValue - self.minValue) / valueSpan;
	CGFloat highValuePoint = (self.highValue - self.minValue) / valueSpan;
	
	return (CGRect){
		(CGPoint){
			lowValuePoint * width,
			roundf(0.5f * (CGRectGetHeight(bounds) - height))
		},
		(CGSize){
			(highValuePoint - lowValuePoint) * width,
			height
		}
	};

}

- (float) valueForThumbRect:(CGRect)rect inTrackRect:(CGRect)trackRect {
	
	return self.minValue +
		(self.maxValue - self.minValue) *
		((CGRectGetMidX(rect) - CGRectGetMinX(trackRect)) /
			(CGRectGetMaxX(trackRect) - CGRectGetMinX(trackRect)));

}

- (CGRect) thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value  active:(BOOL)active {
	
	CGPoint thumbCenter = (CGPoint) {
		(((CGRectGetMaxX(rect) - CGRectGetMinX(rect)) / (self.maxValue - self.minValue)) *
			((value - self.minValue) / (self.maxValue - self.minValue))),
		roundf(CGRectGetMidY(rect))
	};
	
	UIImage *thumbImage = active ?
		self.currentActiveThumbImage :
		self.currentInactiveThumbImage;
	
	CGSize thumbSize = thumbImage.size;
	
	return (CGRect){
		(CGPoint){
			roundf(thumbCenter.x - 0.5f * thumbSize.width),
			roundf(thumbCenter.y - 0.5f * thumbSize.height)
		},
		thumbSize
	};

}

- (UIImageView *) backgroundTrackView {
	
	if (!_backgroundTrackView) {
		_backgroundTrackView = [[UIImageView alloc] initWithFrame:CGRectZero];
	}
	
	return _backgroundTrackView;

}

- (UIImageView *) valueTrackView {

	if (!_valueTrackView) {
		
		_valueTrackView = [[UIImageView alloc] initWithFrame:CGRectZero];
		
	}
	
	return _valueTrackView;

}

- (UIImageView *) lowThumbView {

	if (!_lowThumbView) {
		
		_lowThumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
		
	}
	
	return _lowThumbView;

}

- (UIImageView *) highThumbView {

	if (!_highThumbView) {
	
		_highThumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
		
	}
	
	return _highThumbView;

}

- (UIImage *) imageForState:(UIControlState)state inDictionary:(NSDictionary *)dictionary {

	UIImage *image = dictionary[@(state)];
	
	return image ?
		image :
		(state == UIControlStateNormal) ?
			nil :
			dictionary[@(UIControlStateNormal)];

}

- (void) setThumbImage:(UIImage *)image forState:(UIControlState)state {

	self.thumbImages[@(state)] = image;
	
}

- (UIImage *) thumbImageForState:(UIControlState)state {

	return [self imageForState:state inDictionary:self.thumbImages];
	
}

- (void) setValueTrackImage:(UIImage *)image forState:(UIControlState)state {

	self.valueTrackImages[@(state)] = image;

}

- (UIImage *) valueTrackImageForState:(UIControlState)state {
	
	return [self imageForState:state inDictionary:self.valueTrackImages];

}

- (void) setBackgroundTrackImage:(UIImage *)image forState:(UIControlState)state {

	self.backgroundTrackImages[@(state)] = image;

}

- (UIImage *) backgroundTrackImageForState:(UIControlState)state {

	return [self imageForState:state inDictionary:self.backgroundTrackImages];

}

- (UIImage *) currentActiveThumbImage {

	UIControlState state = ((self.state & UIControlStateHighlighted) == UIControlStateHighlighted) ?
		self.state :
		UIControlStateNormal;

	return [self thumbImageForState:state];

}

- (UIImage *) currentInactiveThumbImage {

	UIControlState state = ((self.state & UIControlStateHighlighted) == UIControlStateHighlighted) ?
		UIControlStateNormal :
		self.state;
	
	return [self thumbImageForState:state];

}

- (UIImage *) currentValueTrackImage {

	UIControlState state = ((self.state & UIControlStateDisabled) == UIControlStateDisabled) ?
		UIControlStateDisabled :
		UIControlStateNormal;
	
	return [self valueTrackImageForState:state];
	
}

- (UIImage *) currentBackgroundTrackImage {
	
	UIControlState state = ((self.state & UIControlStateDisabled) == UIControlStateDisabled) ?
		UIControlStateDisabled :
		UIControlStateNormal;
	
	return [self backgroundTrackImageForState:state];
	
}

@end

NSString * SPStringFromUIControlState (UIControlState state) {

	return [NSString stringWithFormat:@"Normal: %x; Highlighted: %x; Disabled: %x; Selected: %x; Application: %x; Reserved: %x", (state & UIControlStateNormal), (state & UIControlStateHighlighted), (state & UIControlStateDisabled), (state & UIControlStateSelected), (state & UIControlStateApplication), (state & UIControlStateReserved)];

}
