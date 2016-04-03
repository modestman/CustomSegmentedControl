//
//  ViewController.m
//  CustomSegmentedControl
//
//  Created by Admin on 02.04.16.
//  Copyright © 2016 Anton Glezman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    int counter;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    SegmentItem *item1 = [[SegmentItem alloc] initWithTitle:@"2" andSelectedTitle:@"2 дня"];
    SegmentItem *item2 = [[SegmentItem alloc] initWithTitle:@"3" andSelectedTitle:@"3 дня"];
    SegmentItem *item3 = [[SegmentItem alloc] initWithTitle:@"5" andSelectedTitle:@"5 дней"];
    SegmentItem *item4= [[SegmentItem alloc] initWithTitle:@"6" andSelectedTitle:@"6 дней"];
    NSArray *items = @[item1,item2,item3,item4];
    self.segmentedControl.segments = items;
}


- (IBAction)selectedIndexChanged:(SegmentedControl *)sender
{
    NSUInteger idx = self.segmentedControl.selectedSegmentIndex;
    if (idx < [self.segmentedControl.segments count])
    {
        self.label.text = [NSString stringWithFormat:@"Выбран сегмент: %ld; (%@)", idx, self.segmentedControl.segments[idx].selectedTitle];
    }
    else
    {
        self.label.text = @"Не выбран ни один сегмент";
    }
}

- (IBAction)selectFirst:(UIButton *)sender
{
    if ([self.segmentedControl.segments count] > 0)
        self.segmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)addSegment:(UIButton *)sender
{
    SegmentItem *item1 = [[SegmentItem alloc] initWithTitle:@"a" andSelectedTitle:@"abcde"];
    [self.segmentedControl addSegment:item1];
}

- (IBAction)inserSegment:(UIButton *)sender
{
    if ([self.segmentedControl.segments count] > 1)
    {
        SegmentItem *item = [[SegmentItem alloc] initWithTitle:@"b" andSelectedTitle:@"qwer"];
        [self.segmentedControl insertSegment:item atIndex:1];
    }
}

- (IBAction)removeSegment:(UIButton *)sender
{
    if ([self.segmentedControl.segments count] > 0)
        [self.segmentedControl removeSegmentAtIndex:self.segmentedControl.segments.count-1];
}

@end
