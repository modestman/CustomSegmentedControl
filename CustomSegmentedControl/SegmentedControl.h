//
//  SegmentedControl.h
//  CustomSegmentedControl
//
//  Created by Admin on 02.04.16.
//  Copyright © 2016 Anton Glezman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentItem : NSObject

/// наименоване элемента в невыбранном состоянии
@property (nonatomic, copy) NSString *title;

/// наименование элемента в выбранном состоянии
@property (nonatomic, copy) NSString *selectedTitle;

-(id)initWithTitle:(NSString*)title andSelectedTitle:(NSString*)selTitle;

@end

//******//

IB_DESIGNABLE
@interface SegmentedControl : UIControl

/// коллекция сегментов
@property (nonatomic, strong) NSArray<SegmentItem*> *segments;

/// индекс выбранного сегмента
@property (nonatomic, assign) IBInspectable NSUInteger selectedSegmentIndex;

/// цвет фона сегмента
@property (nonatomic, strong) IBInspectable UIColor *itemColor;

/// цвет фона выбранного сегмента
@property (nonatomic, strong) IBInspectable UIColor *selectedItemColor;

/// цвет обводки сегмента
@property (nonatomic, strong) IBInspectable UIColor *strokeColor;

/// толщина линии обводки
@property (nonatomic, assign) IBInspectable CGFloat strokeWidth;

/// расстояние между сегментами
@property (nonatomic, assign) IBInspectable CGFloat horizontalSpace;

/// цвет текста выбранного сегмента
@property (nonatomic, strong) IBInspectable UIColor *selectedTitleColor;

/// цвет текста
@property (nonatomic, strong) IBInspectable UIColor *titleColor;

/// шрифт
@property (nonatomic, strong) UIFont *titleFont;


/// добавить сегмент
-(void)addSegment:(SegmentItem*)segment;

/// вставить сегмент в позицию index
-(void)insertSegment:(SegmentItem*)segment atIndex:(NSUInteger)index;

/// удалить сегмент в позиции index
-(void)removeSegmentAtIndex:(NSUInteger)index;


@end
