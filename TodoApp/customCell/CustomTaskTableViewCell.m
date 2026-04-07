//
//  CustomTaskTableViewCell.m
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import "CustomTaskTableViewCell.h"
#import "Task.h"

@implementation CustomTaskTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.priortyView.layer.cornerRadius = self.priortyView.frame.size.width / 2;
    self.priortyView.clipsToBounds = YES;
}

- (void)configureWithTask:(Task *)task {
    self.title.text = task.name;
    self.date.text = task.dateOfCreation;
    
    if ([task.pirority isEqualToString:@"High"]) {
        self.priortyView.backgroundColor = [UIColor redColor];
        self.pirorityLabel.text = @"High";
    } else if ([task.pirority isEqualToString:@"Medium"]) {
        self.priortyView.backgroundColor = [UIColor orangeColor];
        self.pirorityLabel.text = @"Medium";
    } else {
        self.priortyView.backgroundColor = [UIColor greenColor];
        self.pirorityLabel.text = @"Low";
    }
}
@end
