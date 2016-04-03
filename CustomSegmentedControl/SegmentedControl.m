//
//  SegmentedControl.m
//  CustomSegmentedControl
//
//  Created by Admin on 02.04.16.
//  Copyright © 2016 Anton Glezman. All rights reserved.
//

#import "SegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation SegmentItem

@synthesize title, selectedTitle;

-(id)initWithTitle:(NSString*)title_ andSelectedTitle:(NSString*)selTitle
{
    if (self = [super init])
    {
        self.title = title_;
        self.selectedTitle = selTitle;
    }
    return self;
}

@end

//******//

NSString *const sgEnterAnimation = @"SegmentEnterAnimation";
NSString *const sgLeaveAnimation = @"SegmentLeaveAnimation";
CGFloat const backgroundLineHeight = 4.0;

@interface SegmentedControl ()
{
    NSUInteger _previousSelectedSegmentIndex;
    NSUInteger _selectedSegmentIndex;
    CALayer *firstTouchLayer;
    CALayer *previousTouchLayer;
    CAShapeLayer *backgroundLayer;
    NSMutableArray<CAShapeLayer*> *shapeLayers;
    NSMutableArray<CATextLayer*> *textLayers;
    NSMutableArray *segmentRects;
    NSMutableArray *textRects;
}
@end

@implementation SegmentedControl

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

/// данные для отладки в InterfaceBuilder
-(void)prepareForInterfaceBuilder
{
    SegmentItem *item1 = [[SegmentItem alloc] initWithTitle:@"1" andSelectedTitle:@"1 день"];
    SegmentItem *item2 = [[SegmentItem alloc] initWithTitle:@"3" andSelectedTitle:@"3 дня"];
    SegmentItem *item3 = [[SegmentItem alloc] initWithTitle:@"5" andSelectedTitle:@"5 дней"];
    NSArray *items = @[item1,item2,item3];
    self.segments = items;
}

- (void)commonInit
{
    shapeLayers = [NSMutableArray new];
    textLayers = [NSMutableArray new];
    segmentRects = [NSMutableArray new];
    textRects = [NSMutableArray new];
}

#pragma mark - Drawing

- (NSAttributedString *)attributedTitleAtIndex:(NSUInteger)index{

    BOOL selected = index == self.selectedSegmentIndex;
    NSString *title = selected ? self.segments[index].selectedTitle : self.segments[index].title;

    NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
    
    // the color should be cast to CGColor in order to avoid invalid context on iOS7
    UIColor *titleColor = titleAttrs[NSForegroundColorAttributeName];
    
    if (titleColor) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:titleAttrs];
        
        dict[NSForegroundColorAttributeName] = (id)titleColor.CGColor;
        
        titleAttrs = [NSDictionary dictionaryWithDictionary:dict];
    }
    
    return [[NSAttributedString alloc] initWithString:(NSString *)title attributes:titleAttrs];
}


- (UIBezierPath *)segmetShapeWithSize:(CGSize)size
{
    UIBezierPath *bz = [UIBezierPath bezierPath];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    bz = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:size.height/2];
    return bz;
}

- (UIBezierPath *)backgroundShapeWithSize:(CGSize)size
{
    UIBezierPath *bz = [UIBezierPath bezierPath];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    bz = [UIBezierPath bezierPathWithRect:frame];
    return bz;
}


- (void)drawRect:(CGRect)rect
{
    if ([self.segments count] == 0) return;
    
    [self updateShapeAndTextRects];
    for (int i=0; i<[self.segments count]; i++)
    {
        CGRect segmentRect = [segmentRects[i] CGRectValue];
        if (i >= [shapeLayers count])
        {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [[self segmetShapeWithSize:segmentRect.size] CGPath];
            shapeLayer.lineWidth = self.strokeWidth;
            shapeLayer.strokeColor = self.strokeColor.CGColor;
            shapeLayer.fillColor = i == self.selectedSegmentIndex ? self.selectedItemColor.CGColor : self.itemColor.CGColor;
            shapeLayer.frame = segmentRect;
            [shapeLayers addObject:shapeLayer];
            [self.layer addSublayer:shapeLayer];
        }
        
        if (i >= [textLayers count])
        {
            CGRect textRect = [textRects[i] CGRectValue];
            CATextLayer *titleLayer = [CATextLayer layer];
            titleLayer.frame = textRect;
            titleLayer.alignmentMode = kCAAlignmentCenter;
            titleLayer.string = [self attributedTitleAtIndex:i];
            titleLayer.truncationMode = kCATruncationEnd;
            titleLayer.contentsScale = [[UIScreen mainScreen] scale];
            [textLayers addObject:titleLayer];
            [self.layer addSublayer:titleLayer];
        }
    }
    
    if (backgroundLayer == nil)
    {
        CGRect bgLayerRect = [self getBackgroundLayerRect];
        backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.path = [[self backgroundShapeWithSize:bgLayerRect.size] CGPath];
        backgroundLayer.lineWidth = self.strokeWidth;
        backgroundLayer.strokeColor = nil;
        backgroundLayer.fillColor = self.itemColor.CGColor;
        backgroundLayer.frame = bgLayerRect;
        [self.layer insertSublayer:backgroundLayer atIndex:0];

    }
}

- (CGSize)measureTitleAtIndex:(NSUInteger)index
{
    CGSize size = CGSizeZero;
    BOOL selected = index == self.selectedSegmentIndex;
    NSString *title = selected ? self.segments[index].selectedTitle : self.segments[index].title;
    NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
    size = [title sizeWithAttributes:titleAttrs];
    return CGRectIntegral((CGRect){CGPointZero, size}).size;
}

-(void)updateShapeAndTextRects
{
    [segmentRects removeAllObjects];
    [textRects removeAllObjects];
    
    for (NSUInteger i = 0; i<[self.segments count]; i++)
    {
        CGSize titleSize = [self measureTitleAtIndex:i];
        CGFloat width = MAX(titleSize.width+10, self.bounds.size.height);
        CGFloat height = self.bounds.size.height;
        CGRect prevSegmentRect = i>0 ? [segmentRects[i-1] CGRectValue] : CGRectZero;
        CGRect segmentRect = CGRectMake(prevSegmentRect.size.width+prevSegmentRect.origin.x+self.horizontalSpace, 0, width, height);
        [segmentRects addObject:[NSValue valueWithCGRect: segmentRect]];
        
        CGFloat stringHeight = titleSize.height;
        CGFloat textWidth = segmentRect.size.width;
        CGFloat yOffset = roundf(CGRectGetHeight(self.frame) / 2  - (stringHeight / 2));
        CGFloat textXOffset = segmentRect.origin.x;
        CGRect textRect = CGRectMake(textXOffset, yOffset, textWidth, stringHeight);
        textRect = CGRectMake(ceilf(textRect.origin.x), ceilf(textRect.origin.y), ceilf(textRect.size.width), ceilf(textRect.size.height));
        [textRects addObject:[NSValue valueWithCGRect: textRect]];
    }
}

-(CGRect)getBackgroundLayerRect
{
    CGFloat bgX1 = [[segmentRects firstObject] CGRectValue].origin.x + [[segmentRects firstObject] CGRectValue].size.width / 2;
    CGFloat bgX2 = [[segmentRects lastObject] CGRectValue].origin.x + [[segmentRects lastObject] CGRectValue].size.width / 2;
    CGFloat bgY = roundf(CGRectGetHeight(self.frame) / 2  - (backgroundLineHeight / 2));
    CGRect bgLayerRect = CGRectMake(bgX1, bgY, bgX2-bgX1, backgroundLineHeight);
    return bgLayerRect;
}

-(void)redraw
{
    for (CALayer *layer in shapeLayers)
    {
        [layer removeFromSuperlayer];
    }
    for (CALayer *layer in textLayers)
    {
        [layer removeFromSuperlayer];
    }
    [shapeLayers removeAllObjects];
    [textLayers removeAllObjects];
    [segmentRects removeAllObjects];
    [backgroundLayer removeFromSuperlayer];
    backgroundLayer = nil;
    
    [self setNeedsDisplay];
}

#pragma mark - Styling

- (NSDictionary *)resultingTitleTextAttributes {
    NSDictionary *defaults = @{
                               NSFontAttributeName : self.titleFont ? self.titleFont : [UIFont systemFontOfSize:17.0f],
                               NSForegroundColorAttributeName : self.titleColor ? self.titleColor : [UIColor blackColor],
                               };
    return defaults;
}

- (NSDictionary *)resultingSelectedTitleTextAttributes {
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:[self resultingTitleTextAttributes]];
    
    if (self.selectedTitleColor) {
        [resultingAttrs setObject:self.selectedTitleColor forKey:NSForegroundColorAttributeName];
    }
    
    return [resultingAttrs copy];
}


#pragma mark - Touches

-(CALayer*)hitTest:(CGPoint)point
{
    for (CAShapeLayer *layer in shapeLayers)
    {
        BOOL hit = CGRectContainsPoint(layer.frame, point); //CGPathContainsPoint(layer.path, nil, p, YES);
        if (hit)
            return layer;
    }
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    firstTouchLayer = [self hitTest:touchLocation];
    previousTouchLayer = firstTouchLayer;
    [self segmentEnterAnimation:firstTouchLayer];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    CALayer *nextTouchLayer = [self hitTest:touchLocation];
    if (![nextTouchLayer isEqual:previousTouchLayer])
    {
        [previousTouchLayer removeAnimationForKey:sgEnterAnimation];
        [self segmentLeaveAnimation:previousTouchLayer];
        [self segmentEnterAnimation:nextTouchLayer];
        previousTouchLayer = nextTouchLayer;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    CALayer *lastTouchLayer = [self hitTest:touchLocation];
    if (lastTouchLayer)
    {
        NSInteger idx = [shapeLayers indexOfObject:(CAShapeLayer*)lastTouchLayer];
        self.selectedSegmentIndex = idx;
    }
    [self segmentLeaveAnimation:lastTouchLayer];
}

#pragma mark - Index Change

-(void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex
{
    if (selectedSegmentIndex == _selectedSegmentIndex) return;
    _previousSelectedSegmentIndex = _selectedSegmentIndex;
    _selectedSegmentIndex = selectedSegmentIndex;
    [self animateIndexChangeFrom:_previousSelectedSegmentIndex toIndex:_selectedSegmentIndex];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)addSegment:(SegmentItem*)segment
{
    NSMutableArray *sg = [NSMutableArray arrayWithArray:self.segments];
    [sg addObject:segment];
    self.segments = [sg copy];
    [self redraw];
}

-(void)insertSegment:(SegmentItem*)segment atIndex:(NSUInteger)index
{
    NSMutableArray *sg = [NSMutableArray arrayWithArray:self.segments];
    [sg insertObject:segment atIndex:index];
    self.segments = [sg copy];
    [self redraw];
}

-(void)removeSegmentAtIndex:(NSUInteger)index
{
    if (index < [self.segments count])
    {
        NSMutableArray *sg = [NSMutableArray arrayWithArray:self.segments];
        [sg removeObjectAtIndex:index];
        self.segments = [sg copy];
        if (index == self.selectedSegmentIndex) self.selectedSegmentIndex = NSNotFound;
        [self redraw];
    }
}

#pragma mark - Animation

-(void)segmentEnterAnimation:(CALayer*)layer
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
    [scaleAnimation setToValue:[NSNumber numberWithFloat:1.15f]];
    [scaleAnimation setDuration:0.2f];
    [scaleAnimation setRemovedOnCompletion:NO];
    [scaleAnimation setFillMode:kCAFillModeForwards];
    [layer addAnimation:scaleAnimation forKey:sgEnterAnimation];
}

-(void)segmentLeaveAnimation:(CALayer*)layer
{
    [CATransaction begin];
    CALayer *currentLayer = layer.presentationLayer;
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [scaleAnimation setFromValue:[NSValue valueWithCATransform3D:currentLayer.transform]];
    [scaleAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [scaleAnimation setDuration:0.2f];
    [scaleAnimation setRemovedOnCompletion:NO];
    [scaleAnimation setFillMode:kCAFillModeForwards];
    [CATransaction setCompletionBlock:^{
        [layer removeAllAnimations];
    }];
    [layer addAnimation:scaleAnimation forKey:sgLeaveAnimation];
    [CATransaction commit];
}

-(void)animateIndexChangeFrom:(NSUInteger)prevIndex toIndex:(NSUInteger)curIndex
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2f];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self updateShapeAndTextRects];
    for (NSUInteger i = 0; i<[self.segments count]; i++)
    {
        CGRect segmentRect = [segmentRects[i] CGRectValue];
        CAShapeLayer *shapeLayer = shapeLayers[i];
        shapeLayer.path = [[self segmetShapeWithSize:segmentRect.size] CGPath];
        shapeLayer.frame = segmentRect;
        shapeLayer.fillColor = i == self.selectedSegmentIndex ? self.selectedItemColor.CGColor : self.itemColor.CGColor;

        CGRect textRect = [textRects[i] CGRectValue];
        CATextLayer *titleLayer = textLayers[i] ;
        titleLayer.frame = textRect;
        titleLayer.string = [self attributedTitleAtIndex:i];
    }
    
    CGRect bgLayerRect = [self getBackgroundLayerRect];
    backgroundLayer.path = [self backgroundShapeWithSize:bgLayerRect.size].CGPath;
    backgroundLayer.frame = bgLayerRect;
    
    [CATransaction commit];
}

@end
