//
//  HelloWorldLayer.m
//  ArtworkEvolution_SquashStretch
//
//  Created by Mike Lyman on 7/31/13.
//  Copyright Mike Lyman 2013. All rights reserved.
//
// Artwork Evolution: http://artworkevolution.com/blog/
// Code written by Mike Lyman, based off cocos2D template project.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

// Needed to support gestures on ccsprites
#import "CCNode+SFGestureRecognizers.h"

#pragma mark - HelloWorldLayer

static float kMotionAnimationThreshold = 1000;
static float kOriginalScale = 1.0;
static float kAngleWhereSkewStartsLookingBad = 45;

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {\
//        Create a sprite and enable touch
        self.sprite = [[CCSprite alloc] initWithFile:@"Icon.png"];
        [self addChild:self.sprite];
        self.sprite.position = ccp(self.boundingBox.size.width/2,self.boundingBox.size.height/2);
        self.sprite.isTouchEnabled = YES;
        
//        Create a pan gesture recognizer and add it to the sprite
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        panGesture.delaysTouchesBegan = NO;
//        Sprite and gesture support from CCNode+SFGestureRecognizers.h
        [self.sprite addGestureRecognizer:panGesture];
	}
	return self;
}


/**** Artwork Evolution: http://artworkevolution.com/blog/
 handlePangesture: moves the sprite with the player's finger and causes squash-stretch animations.
 Some of the constant values below have been chosen through trail-and-error to find an animation that looks good.
 Depending on how drastic you want your squash and stretch to be you may want to tweak the values, mess with skewY as well, or come up with new equations entirely!
 ****/
- (void)handlePanGesture:(UIPanGestureRecognizer*)panGesture {
    
//    Get the velocity of the pan
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    
//    Translate the sprite to the pan's location
    CGPoint translation = [panGesture translationInView:panGesture.view];
    translation.y *= -1;
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
    CGPoint p = ccpAdd(self.sprite.position, translation);
    self.sprite.position = ccp(p.x,p.y);
    
//    Squashing and stretching animation code below
    //    Get the angle of motion the sprite is moving in
    float angle = atan2f(velocity.y, velocity.x);
    float newScaleX;
    float newScaleY;
    if (hypot(velocity.x, velocity.y) > kMotionAnimationThreshold) {
//        If the X velocity is greater, stretch in X, squash in Y. And vice versa
        if (fabsf(velocity.x) > fabsf(velocity.y)) {
            newScaleX = kOriginalScale + ((0.5 - fabsf(cos(angle) * sin(angle))) * fabsf((velocity.x / 750)));
            newScaleY = kOriginalScale / newScaleX;
        }
        else {
            newScaleY = kOriginalScale + ((0.5 - fabsf(cos(angle) * sin(angle))) * fabsf((velocity.y / 750)));
            newScaleX = kOriginalScale / newScaleY;
        }
        
        self.sprite.scaleX = newScaleX;
        self.sprite.scaleY = newScaleY;
        
        float skew = -kAngleWhereSkewStartsLookingBad * (sin(angle) * cos(angle) * hypotf(velocity.x, velocity.y) / 1000 );
        if (skew < 0 && skew < -kAngleWhereSkewStartsLookingBad) {
            skew = -kAngleWhereSkewStartsLookingBad;
        }
        else if (skew > 0 && skew > kAngleWhereSkewStartsLookingBad) {
            skew = kAngleWhereSkewStartsLookingBad;
        }
        self.sprite.skewX = skew;
    }
    else {
        self.sprite.skewX = 0;
        self.sprite.scaleX = kOriginalScale;
        self.sprite.scaleY = kOriginalScale;
    }
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        self.sprite.skewX = 0;
        self.sprite.scaleX = kOriginalScale;
        self.sprite.scaleY = kOriginalScale;
    }

    
}

@end
