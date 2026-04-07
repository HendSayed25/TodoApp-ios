//
//  AddTaskViewController.m
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import "AddTaskViewController.h"

@interface AddTaskViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;
@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(350, 220);
    self.modalPresentationStyle = UIModalPresentationPopover;
}

- (IBAction)addButtonTapped:(id)sender {
    if (self.nameTextField.text.length == 0) return;
    
    Task *task = [Task new];
    task.name = self.nameTextField.text;
    task.desc = self.descTextField.text;
    
    NSInteger index = self.prioritySegment.selectedSegmentIndex;
    if (index == 0) task.pirority = @"High";
    else if (index == 1) task.pirority = @"Medium";
    else task.pirority = @"Low";
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM d, yyyy"];
    task.dateOfCreation = [formatter stringFromDate:[NSDate date]];
    
    [self.delegate didAddTask:task];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
