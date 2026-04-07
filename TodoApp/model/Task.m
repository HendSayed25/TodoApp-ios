//
//  Task.m
//  TodoApp
//
//  Created by Hend Sayed on 07/04/2026.
//

#import "Task.h"

#import <Foundation/Foundation.h>


@implementation Task

- (instancetype)initWithName:(NSString *)name
                        desc:(NSString *)desc
               dateOfCreation:(NSString *)dateOfCreation
                     pirority:(NSString *)pirority
                       state:(NSString *)state{
    self = [super init];
    if (self) {
        _name = name;
        _desc = desc;
        _dateOfCreation = dateOfCreation;
        _pirority = pirority;
        _state = state;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.desc forKey:@"desc"];
    [coder encodeObject:self.dateOfCreation forKey:@"dateOfCreation"];
    [coder encodeObject:self.pirority forKey:@"pirority"];
    [coder encodeObject:self.state forKey:@"state"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _desc = [coder decodeObjectOfClass:[NSString class] forKey:@"desc"];
        _dateOfCreation = [coder decodeObjectOfClass:[NSString class] forKey:@"dateOfCreation"];
        _pirority = [coder decodeObjectOfClass:[NSString class] forKey:@"pirority"];
        _state = [coder decodeObjectOfClass:[NSString class] forKey:@"state"];
    }
    return self;
}

@end
