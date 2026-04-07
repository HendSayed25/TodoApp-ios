//
//  TaskDetailsViewController.m
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import "TaskDetailsViewController.h"

@interface TaskDetailsViewController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *priorityLabel;
@property (nonatomic, strong) UISegmentedControl *stateControl;

@end

@implementation TaskDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Task Details";

    self.nameLabel = [self createLabelWithText:[NSString stringWithFormat:@"Name: %@", self.task.name]];
    [self.view addSubview:self.nameLabel];

    self.descLabel = [self createLabelWithText:[NSString stringWithFormat:@"Description: %@", self.task.desc]];
    [self.view addSubview:self.descLabel];

    self.dateLabel = [self createLabelWithText:[NSString stringWithFormat:@"Created: %@", self.task.dateOfCreation]];
    [self.view addSubview:self.dateLabel];

    self.priorityLabel = [self createLabelWithText:[NSString stringWithFormat:@"Priority: %@", self.task.pirority]];
    [self.view addSubview:self.priorityLabel];

    // State Segmented Control
    self.stateControl = [[UISegmentedControl alloc] initWithItems:@[@"Todo", @"In Progress", @"Done"]];
    
    // Default selection
    if (!self.task.state) self.task.state = @"Todo";
    
    if ([self.task.state isEqualToString:@"Todo"]) self.stateControl.selectedSegmentIndex = 0;
    else if ([self.task.state isEqualToString:@"In Progress"]) self.stateControl.selectedSegmentIndex = 1;
    else self.stateControl.selectedSegmentIndex = 2;
    
    [self.stateControl addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    self.stateControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.stateControl];

    [self setupConstraints];
}

- (UILabel *)createLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:18];
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (void)setupConstraints {
    CGFloat padding = 20;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:padding],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        
        [self.descLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:padding],
        [self.descLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.descLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.descLabel.bottomAnchor constant:padding],
        [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        
        [self.priorityLabel.topAnchor constraintEqualToAnchor:self.dateLabel.bottomAnchor constant:padding],
        [self.priorityLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.priorityLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        
        [self.stateControl.topAnchor constraintEqualToAnchor:self.priorityLabel.bottomAnchor constant:30],
        [self.stateControl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.stateControl.widthAnchor constraintEqualToConstant:300]
    ]];
}

- (void)stateChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: self.task.state = @"Todo"; break;
        case 1: self.task.state = @"In Progress"; break;
        case 2: self.task.state = @"Done"; break;
    }
    
    if (self.onUpdateTask) {
        self.onUpdateTask(self.task);
    }
}

@end
