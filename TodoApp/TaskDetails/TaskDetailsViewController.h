//
//  TaskDetailsViewController.h
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import <UIKit/UIKit.h>
#import "Task.h"


@interface TaskDetailsViewController : UIViewController
@property (nonatomic, strong) Task *task;
@property (nonatomic, copy) void (^onUpdateTask)(Task *updatedTask);
@end
