//
//  UIBezierPath+point.h
//  画板
//
//  Created by 谢佳培 on 2021/2/26.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (point)
/*!
 @method  获得UIBezierPath曲线上的所有点坐标
 @abstract 获得UIBezierPath曲线上的所有点坐标
 @result 坐标点数组
 */
- (NSArray *)points;

@end
