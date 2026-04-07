//
//  Task.h
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import <Foundation/Foundation.h>


@interface Task : NSObject <NSSecureCoding>
@property NSString * name;
@property NSString * desc;
@property NSString * dateOfCreation;
@property NSString * pirority;
@property NSString * state;

- (instancetype)initWithName:(NSString *)name
                        desc:(NSString *)desc
               dateOfCreation:(NSString *)dateOfCreation
                     pirority:(NSString *)pirority
                       state:(NSString *)state;
@end
