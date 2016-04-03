//
//  ViewController.h
//  CustomSegmentedControl
//
//  Created by Admin on 02.04.16.
//  Copyright © 2016 Anton Glezman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentedControl.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet SegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *label;

- (IBAction)selectedIndexChanged:(SegmentedControl *)sender;
- (IBAction)selectFirst:(UIButton *)sender;
- (IBAction)addSegment:(UIButton *)sender;
- (IBAction)inserSegment:(UIButton *)sender;
- (IBAction)removeSegment:(UIButton *)sender;


@end

