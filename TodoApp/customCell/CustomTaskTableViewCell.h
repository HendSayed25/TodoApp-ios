//
//  CustomTaskTableViewCell.h
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import <UIKit/UIKit.h>
#import "Task.h"


@interface CustomTaskTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIView *priortyView;
@property (weak, nonatomic) IBOutlet UILabel *pirorityLabel;

-(void)layoutSubviews;
-(void)configureWithTask:(Task *)task;
@end
