//
//  ViewController.m
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//
#import "ViewController.h"
#import "Task.h"
#import "CustomTaskTableViewCell.h"

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
    self.searchBar.text = @"";
    [self applySegmentFilter];
}

- (void)applySegmentFilter {
    NSInteger selectedIndex = self.segemntUI.selectedSegmentIndex;
    NSString *trimmedText = [[self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];

    if (selectedIndex == 0) {
        // All
        self.isGroupedByPriority = NO;
        [self.filteredTasks removeAllObjects];

        for (Task *task in self.tasks) {
            if (trimmedText.length == 0 ||
                [task.name.lowercaseString containsString:trimmedText]) {
                [self.filteredTasks addObject:task];
            }
        }

    } else if (selectedIndex == 4) {
        // Priority — grouped into 3 sections
        self.isGroupedByPriority = YES;
        [self rebuildTasksByPriority];

    } else {
        // Filter by state (Todo / In Progress / Done)
        self.isGroupedByPriority = NO;
        NSString *state = [self stateSegmentTitle:selectedIndex];
        [self.filteredTasks removeAllObjects];

        for (Task *task in self.tasks) {
            if (![task.state isEqualToString:state]) continue;

            if (trimmedText.length == 0 ||
                [task.name.lowercaseString containsString:trimmedText]) {
                [self.filteredTasks addObject:task];
            }
        }
    }

    [self.tableView reloadData];
    [self updateEmptyState];
}

- (NSString *)stateSegmentTitle:(NSInteger)index {
    switch (index) {
        case 1: return @"Todo";
        case 2: return @"In Progress";
        case 3: return @"Done";
        default: return @"";
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
    
    self.searchBar.placeholder = @"Search for tasks...";

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

- (void)addTask {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Task"
                                                                   message:@"\n\n\n\n\n\n\n\n"
                                                            preferredStyle:UIAlertControllerStyleAlert];

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

    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.text = [NSString stringWithFormat:@"Creation Date: %@", [self getCurrentDateString]];
    dateLabel.font = [UIFont systemFontOfSize:14];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:dateLabel];

    [NSLayoutConstraint activateConstraints:@[
        [priorityLabel.topAnchor constraintEqualToAnchor:alert.view.topAnchor constant:90],
        [priorityLabel.leadingAnchor constraintEqualToAnchor:alert.view.leadingAnchor constant:20],

        [priorityControl.topAnchor constraintEqualToAnchor:priorityLabel.bottomAnchor constant:8],
        [priorityControl.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor],
        [priorityControl.widthAnchor constraintEqualToConstant:220],

        [dateLabel.topAnchor constraintEqualToAnchor:priorityControl.bottomAnchor constant:8],
        [dateLabel.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor]
    ]];

    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields[0].text;
        NSString *desc = alert.textFields[1].text;

        Task *task = [Task new];
        task.name = name;
        task.desc = desc;
        task.dateOfCreation = [self getCurrentDateString];
        task.state = @"Todo";

        switch (priorityControl.selectedSegmentIndex) {
            case 0: task.pirority = @"High"; break;
            case 1: task.pirority = @"Medium"; break;
            case 2: task.pirority = @"Low"; break;
        }

        [self.tasks addObject:task];
        [self saveTasks];
        [self applySegmentFilter]; // rebuilds filteredTasks/tasksByPriority + reloads
        [self updateEmptyState];
    }];

    addAction.enabled = NO;

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:addAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:^{
        UITextField *nameField = alert.textFields[0];
        [nameField addTarget:self action:@selector(validateTaskName:) forControlEvents:UIControlEventEditingChanged];
    }];
}

- (void)validateTaskName:(UITextField *)textField {
    UIAlertController *alert = (UIAlertController *)self.presentedViewController;
    NSString *name = alert.textFields[0].text;
    UIAlertAction *addAction = alert.actions.firstObject;
    addAction.enabled = name.length > 0;
}

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
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

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

- (void)saveTasks {
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self.tasks
                                                 requiringSecureCoding:YES
                                                                 error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"tasks"];
    NSLog(@"Saved tasks successfully");
}

- (void)loadTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];

    if (data) {
        NSArray<Task *> *savedTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], [Task class], nil]
                                                                          fromData:data
                                                                             error:nil];
        if (savedTasks) {
            self.tasks = [savedTasks mutableCopy];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchBar.placeholder = @"Search tasks...";

    NSString *trimmedText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger selectedIndex = self.segemntUI.selectedSegmentIndex;

    if (selectedIndex == 4) { // Priority segment
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        for (NSString *p in self.priorityOrder) {
            NSMutableArray *filtered = [NSMutableArray array];

            for (Task *task in self.tasks) {
                if (![task.pirority isEqualToString:p]) continue;

                if (trimmedText.length == 0 ||
                    [task.name.lowercaseString containsString:trimmedText.lowercaseString]) {
                    [filtered addObject:task];
                }
            }
            dict[p] = filtered;
        }
        self.tasksByPriority = [dict copy];

    } else if (selectedIndex == 0) { // All tasks
        [self.filteredTasks removeAllObjects];

        for (Task *task in self.tasks) {
            if (trimmedText.length == 0 ||
                [task.name.lowercaseString containsString:trimmedText.lowercaseString]) {
                [self.filteredTasks addObject:task];
            }
        }

    } else { // State segments: Todo / In Progress / Done
        NSString *state = [self stateSegmentTitle:selectedIndex];
        [self.filteredTasks removeAllObjects];

        for (Task *task in self.tasks) {
            if (![task.state isEqualToString:state]) continue;

            if (trimmedText.length == 0 ||
                [task.name.lowercaseString containsString:trimmedText.lowercaseString]) {
                [self.filteredTasks addObject:task];
            }
        }
    }

    [self.tableView reloadData];
    [self updateEmptyState];
}

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
                                                                   message:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
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

    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.text = [NSString stringWithFormat:@"Creation Date: %@", task.dateOfCreation];
    dateLabel.font = [UIFont systemFontOfSize:14];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:dateLabel];

    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"Update"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Confirm Update"
                                                                         message:@"Are you sure you want to save changes to this task?"
                                                                  preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
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

                [self saveTasks];
                [self applySegmentFilter]; // rebuilds + reloads correctly
                [self updateEmptyState];
            }
        }];

        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [confirm addAction:yesAction];
        [confirm addAction:noAction];
        [self presentViewController:confirm animated:YES completion:nil];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    updateAction.enabled = (task.name.length > 0);

    [alert addAction:updateAction];
    [alert addAction:cancelAction];

    [NSLayoutConstraint activateConstraints:@[
        [priorityLabel.topAnchor constraintEqualToAnchor:alert.view.topAnchor constant:130],
        [priorityLabel.leadingAnchor constraintEqualToAnchor:alert.view.leadingAnchor constant:20],

        [priorityControl.topAnchor constraintEqualToAnchor:priorityLabel.bottomAnchor constant:10],
        [priorityControl.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor],
        [priorityControl.widthAnchor constraintEqualToConstant:220],

        [stateLabel.topAnchor constraintEqualToAnchor:priorityControl.bottomAnchor constant:15],
        [stateLabel.leadingAnchor constraintEqualToAnchor:alert.view.leadingAnchor constant:20],

        [stateControl.topAnchor constraintEqualToAnchor:stateLabel.bottomAnchor constant:8],
        [stateControl.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor],
        [stateControl.widthAnchor constraintEqualToConstant:220],

        [dateLabel.topAnchor constraintEqualToAnchor:stateControl.bottomAnchor constant:20],
        [dateLabel.centerXAnchor constraintEqualToAnchor:alert.view.centerXAnchor]
    ]];

    [self presentViewController:alert animated:YES completion:^{
        UITextField *nameField = alert.textFields[0];
        [nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
}

- (void)textFieldDidChange:(UITextField *)textField {
    UIAlertController *alert = (UIAlertController *)self.presentedViewController;
    if (!alert) return;
    UIAlertAction *updateAction = alert.actions.firstObject;
    updateAction.enabled = textField.text.length > 0;
}

- (NSString *)getCurrentDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

@end
