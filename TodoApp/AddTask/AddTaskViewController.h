//
//  AddTaskViewController.h
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@protocol AddTaskDelegate <NSObject>
- (void)didAddTask:(Task *)task;
@end

@interface AddTaskViewController : UIViewController
@property (nonatomic, weak) id<AddTaskDelegate> delegate;
@end
