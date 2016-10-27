//
//  HomeListGroupHeader.m
//  Crideo
//
//  Created by weiying on 16/9/21.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "HomeListGroupHeader.h"

@interface HomeListGroupHeader ()
@property (weak, nonatomic) IBOutlet UILabel *normalTimeLabel;

@end

@implementation HomeListGroupHeader

+ (instancetype)groupNormalHeader
{
    return [[[NSBundle mainBundle] loadNibNamed:@"HomeListGroupHeader" owner:nil options:nil] firstObject];
}

- (void)firstHeaderWithGroupTime:(NSString *)time
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date =[dateFormat dateFromString:time];
    [dateFormat setDateFormat:@"cccc"];
    NSString *dateStr = [dateFormat stringFromDate:date];
    self.normalTimeLabel.font = [UIFont fontWithName:@"Lobster-Regular" size:16 * SCREEN_SCALE];
    self.normalTimeLabel.text = dateStr;
}

- (void)normalHeaderWithGroupTime:(NSString *)time
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date =[dateFormat dateFromString:time];
    [dateFormat setDateFormat:@"- LLL. dd -"];
    NSString *dateStr = [dateFormat stringFromDate:date];
    self.normalTimeLabel.font = [UIFont fontWithName:@"Lobster-Regular" size:12 * SCREEN_SCALE];
    self.normalTimeLabel.text = dateStr;
}

@end
