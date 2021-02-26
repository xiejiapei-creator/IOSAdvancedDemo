//
//  CustomView.h
//  画板
//
//  Created by 谢佳培 on 2021/2/26.
//

#import <UIKit/UIKit.h>

typedef void(^OnePathEndBlock)(NSMutableDictionary *dict);

NS_ASSUME_NONNULL_BEGIN

@interface CustomView : UIView

// 当前正在绘制的贝塞尔曲线
@property (strong, nonatomic) UIBezierPath *currentPath;
// 总的贝塞尔曲线合集
@property (strong, nonatomic) NSMutableArray *pathArray;
// 贝塞尔曲线线条颜色 HEX
@property (copy, nonatomic) NSString *lineColor;
// 贝塞尔曲线线条宽度
@property (assign, nonatomic) CGFloat lineWidth;
// 一条贝塞尔曲线绘制完成后的回调Block
@property (copy, nonatomic) OnePathEndBlock onePathEndBlock;

- (void)dealwithData:(UIBezierPath *)path lineColor:(NSString *)lineColor lineWidth:(CGFloat)lineWidth;

@end

NS_ASSUME_NONNULL_END
