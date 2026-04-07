//
//  ViewController.m
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import "ViewController.h"
#import "Task.h"
#import "CustomTaskTableViewCell.h"
#import "TaskDetailsViewController.h"

@interface ViewController ()  <UITableViewDelegate, UITableViewDataSource , UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segemntUI;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<Task *> *tasks;
@property (nonatomic, strong) NSMutableArray<Task *> *filteredTasks;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<Task *> *> *tasksByPriority;
@property (nonatomic, strong) NSArray<NSString *> *priorityOrder;
@property (nonatomic, assign) BOOL isGroupedByPriority;
@end

@implementation ViewController

- (IBAction)segmentTab:(UISegmentedControl *)sender {
    [self applySegmentFilter];
}

- (void)applySegmentFilter {
    NSInteger selectedIndex = self.segemntUI.selectedSegmentIndex;

    if (selectedIndex == 0) {
        // All — flat list
        self.isGroupedByPriority = NO;
        self.filteredTasks = [NSMutableArray arrayWithArray:self.tasks];
    } else if (selectedIndex == 4) {
        // Priority — grouped into 3 sections (High / Medium / Low)
        // Change index 4 to match whichever segment index "Priority" is in your UISegmentedControl
        self.isGroupedByPriority = YES;
        [self rebuildTasksByPriority];
    } else {
        // High / Medium / Low — flat filtered list
        self.isGroupedByPriority = NO;
        NSString *priority = [self prioritySegmentTitle:selectedIndex];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Task *task, NSDictionary *bindings) {
            return [task.pirority isEqualToString:priority];
        }];
        self.filteredTasks = [[self.tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    }

    [self.tableView reloadData];
    [self updateEmptyState];
}

- (NSString *)prioritySegmentTitle:(NSInteger)index {
    switch (index) {
        case 1: return @"High";
        case 2: return @"Medium";
        case 3: return @"Low";
        default: return @""; // All
    }
}

- (void)rebuildTasksByPriority {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *p in self.priorityOrder) {
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(Task *task, NSDictionary *b) {
            return [task.pirority isEqualToString:p];
        }];
        dict[p] = [[self.tasks filteredArrayUsingPredicate:pred] mutableCopy];
    }
    self.tasksByPriority = [dict copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;

    self.priorityOrder = @[@"High", @"Medium", @"Low"];
    [self loadTasks];

    if (!self.tasks) {
        self.tasks = [NSMutableArray array];
    }

    self.isGroupedByPriority = NO;
    self.filteredTasks = [NSMutableArray arrayWithArray:self.tasks];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(addTask)];

    self.navigationItem.rightBarButtonItem = addButton;
}

-(void)addTask {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Task"
                                                                   message:@"\n\n\n\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    alert.view.transform = CGAffineTransformMakeScale(1.1, 1.2);

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Task Name";
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Description";
    }];

    UILabel *priorityLabel = [[UILabel alloc] init];
    priorityLabel.text = @"Priority";
    priorityLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    priorityLabel.textColor = [UIColor blackColor];
    priorityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:priorityLabel];

    UISegmentedControl *priorityControl = [[UISegmentedControl alloc] initWithItems:@[@"High", @"Medium", @"Low"]];
    priorityControl.selectedSegmentIndex = 1;
    priorityControl.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:priorityControl];

    [NSLayoutConstraint activateConstraints:@[
        [priorityLabel.topAnchor constraintEqualToAnchor:alert.view.topAnchor constant:90],
        [priorityLabel.leadingAnchor constraintEqualToAnchor:alert.view.leadingAnchor constant:20],

        [priorityControl.topAnchor constraintEqualToAnchor:priorityLabel.bottomAnchor constant:8],
        [priorityControl.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor],
        [priorityControl.widthAnchor constraintEqualToConstant:220]
    ]];

    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields[0].text;
        NSString *desc = alert.textFields[1].text;

        if (name.length > 0) {
            Task *task = [Task new];
            task.name = name;
            task.desc = desc;
            task.dateOfCreation = [self getCurrentDateString];
            task.state = @"Todo";

            switch (priorityControl.selectedSegmentIndex) {
                case 0: task.pirority = @"High"; break;
                case 1: task.pirority = @"Medium"; break;
                case 2: task.pirority = @"Low"; break;
                default: task.pirority = @"Medium"; break;
            }

            [self.tasks addObject:task];

            if (self.isGroupedByPriority) {
                [self rebuildTasksByPriority];
                [self.tableView reloadData];
            } else {
                [self.filteredTasks addObject:task];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.filteredTasks.count - 1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }

            [self saveTasks];
            [self updateEmptyState];
        }
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:addAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isGroupedByPriority ? self.priorityOrder.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isGroupedByPriority) {
        NSString *priority = self.priorityOrder[section];
        return self.tasksByPriority[priority].count;
    }
    return self.filteredTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    Task *task;
    if (self.isGroupedByPriority) {
        NSString *priority = self.priorityOrder[indexPath.section];
        task = self.tasksByPriority[priority][indexPath.row];
    } else {
        task = self.filteredTasks[indexPath.row];
    }

    [cell configureWithTask:task];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.isGroupedByPriority) return nil;

    NSString *priority = self.priorityOrder[section];
    NSArray *tasksForPriority = self.tasksByPriority[priority];
    return tasksForPriority.count > 0 ? priority : nil;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Task"
                                                                       message:@"Are you sure?"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
            Task *taskToDelete;

            if (self.isGroupedByPriority) {
                NSString *priority = self.priorityOrder[indexPath.section];
                NSMutableArray *sectionTasks = [self.tasksByPriority[priority] mutableCopy];
                taskToDelete = sectionTasks[indexPath.row];
                [sectionTasks removeObjectAtIndex:indexPath.row];
                NSMutableDictionary *dict = [self.tasksByPriority mutableCopy];
                dict[priority] = sectionTasks;
                self.tasksByPriority = [dict copy];
            } else {
                taskToDelete = self.filteredTasks[indexPath.row];
                [self.filteredTasks removeObjectAtIndex:indexPath.row];
            }

            [self.tasks removeObject:taskToDelete];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];

            [self saveTasks];
            [self updateEmptyState];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];

        [alert addAction:deleteAction];
        [alert addAction:cancelAction];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

// MARK: - Persistence

- (void)saveTasks {
    NSError *error = nil;

    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self.tasks
                                                requiringSecureCoding:YES
                                                                error:&error];
    if (error) {
        NSLog(@"Encode error: %@", error);
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"tasks"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Keep grouped view in sync after any save
    if (self.isGroupedByPriority) {
        [self rebuildTasksByPriority];
    }

    NSLog(@"Saved tasks successfully");
}

- (void)loadTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
    NSLog(@"data: %@", data);

    if (data) {
        NSArray<Task *> *savedTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], [Task class], nil] fromData:data error:nil];
        if (savedTasks) {
            self.tasks = [savedTasks mutableCopy];
        }
    }
}

// MARK: - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (self.isGroupedByPriority) {
        // Rebuild with search filter applied per section
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *p in self.priorityOrder) {
            NSMutableArray *filtered = [NSMutableArray array];
            for (Task *task in self.tasks) {
                if (![task.pirority isEqualToString:p]) continue;
                if (searchText.length == 0 ||
                    [task.name.lowercaseString containsString:searchText.lowercaseString] ||
                    [task.desc.lowercaseString containsString:searchText.lowercaseString]) {
                    [filtered addObject:task];
                }
            }
            dict[p] = filtered;
        }
        self.tasksByPriority = [dict copy];
    } else {
        [self.filteredTasks removeAllObjects];

        if (searchText.length == 0) {
            [self.filteredTasks addObjectsFromArray:self.tasks];
        } else {
            for (Task *task in self.tasks) {
                if ([task.name.lowercaseString containsString:searchText.lowercaseString] ||
                    [task.desc.lowercaseString containsString:searchText.lowercaseString]) {
                    [self.filteredTasks addObject:task];
                }
            }
        }
    }

    [self.tableView reloadData];
    [self updateEmptyState];
}

// MARK: - Empty State

- (void)updateEmptyState {
    BOOL isEmpty;

    if (self.isGroupedByPriority) {
        NSInteger total = 0;
        for (NSString *p in self.priorityOrder) {
            total += self.tasksByPriority[p].count;
        }
        isEmpty = (total == 0);
    } else {
        isEmpty = (self.filteredTasks.count == 0);
    }

    if (isEmpty) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        label.text = @"No Tasks Available";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:18];
        self.tableView.backgroundView = label;
    } else {
        self.tableView.backgroundView = nil;
    }
}

// MARK: - Row Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task;
    if (self.isGroupedByPriority) {
        NSString *priority = self.priorityOrder[indexPath.section];
        task = self.tasksByPriority[priority][indexPath.row];
    } else {
        task = self.filteredTasks[indexPath.row];
    }
    [self showEditAlertForTask:task indexPath:indexPath];
}

- (void)showEditAlertForTask:(Task *)task indexPath:(NSIndexPath *)indexPath {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit Task"
                                                                   message:@"\n\n\n\n\n\n\n\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = task.name;
        textField.placeholder = @"Task Name";
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = task.desc;
        textField.placeholder = @"Description";
    }];

    UILabel *priorityLabel = [[UILabel alloc] init];
    priorityLabel.text = @"Priority:";
    priorityLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    priorityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:priorityLabel];

    UISegmentedControl *priorityControl = [[UISegmentedControl alloc] initWithItems:@[@"High", @"Medium", @"Low"]];
    if ([task.pirority isEqualToString:@"High"]) priorityControl.selectedSegmentIndex = 0;
    else if ([task.pirority isEqualToString:@"Medium"]) priorityControl.selectedSegmentIndex = 1;
    else priorityControl.selectedSegmentIndex = 2;
    priorityControl.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:priorityControl];

    UILabel *stateLabel = [[UILabel alloc] init];
    stateLabel.text = @"State:";
    stateLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:stateLabel];

    UISegmentedControl *stateControl = [[UISegmentedControl alloc] initWithItems:@[@"Todo", @"In Progress", @"Done"]];
    if ([task.state isEqualToString:@"Done"]) stateControl.selectedSegmentIndex = 2;
    else if ([task.state isEqualToString:@"In Progress"]) stateControl.selectedSegmentIndex = 1;
    else stateControl.selectedSegmentIndex = 0;

    if ([task.state isEqualToString:@"In Progress"]) {
        [stateControl setEnabled:NO forSegmentAtIndex:0];
    } else if ([task.state isEqualToString:@"Done"]) {
        [stateControl setEnabled:NO forSegmentAtIndex:0];
        [stateControl setEnabled:NO forSegmentAtIndex:1];
    }

    stateControl.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:stateControl];

    [NSLayoutConstraint activateConstraints:@[
        [priorityLabel.topAnchor constraintEqualToAnchor:alert.view.topAnchor constant:90],
        [priorityLabel.leadingAnchor constraintEqualToAnchor:alert.view.leadingAnchor constant:20],

        [priorityControl.topAnchor constraintEqualToAnchor:priorityLabel.bottomAnchor constant:5],
        [priorityControl.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor],
        [priorityControl.widthAnchor constraintEqualToConstant:220],

        [stateLabel.topAnchor constraintEqualToAnchor:priorityControl.bottomAnchor constant:10],
        [stateLabel.leadingAnchor constraintEqualToAnchor:alert.view.leadingAnchor constant:20],

        [stateControl.topAnchor constraintEqualToAnchor:stateLabel.bottomAnchor constant:5],
        [stateControl.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor],
        [stateControl.widthAnchor constraintEqualToConstant:220]
    ]];

    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Confirm Update"
                                                                         message:@"Are you sure you want to save changes to this task?"
                                                                  preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            NSString *newName = alert.textFields[0].text;
            NSString *newDesc = alert.textFields[1].text;

            if (newName.length > 0) {
                task.name = newName;
                task.desc = newDesc;

                switch (priorityControl.selectedSegmentIndex) {
                    case 0: task.pirority = @"High"; break;
                    case 1: task.pirority = @"Medium"; break;
                    case 2: task.pirority = @"Low"; break;
                }

                switch (stateControl.selectedSegmentIndex) {
                    case 0: task.state = @"Todo"; break;
                    case 1: task.state = @"In Progress"; break;
                    case 2: task.state = @"Done"; break;
                }

                if (self.isGroupedByPriority) {
                    [self rebuildTasksByPriority];
                    [self.tableView reloadData];
                } else {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }

                [self saveTasks];
            }
        }];

        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

        [confirm addAction:yesAction];
        [confirm addAction:noAction];
        [self presentViewController:confirm animated:YES completion:nil];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:updateAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - Helpers

- (NSString *)getCurrentDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

@end
