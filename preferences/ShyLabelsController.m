#include "ShyLabelsController.h"
#import <spawn.h>

@implementation ShyLabelsController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
    self.navigationItem.rightBarButtonItem = applyButton;
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }

    return _specifiers;
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/noisyflake"] options:@{} completionHandler:nil];
}

- (void)code {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/cbyrne/ShyLabels"] options:@{} completionHandler:nil];
}

- (void)bug {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/cbyrne/ShyLabels/issues"] options:@{} completionHandler:nil];
}

- (void)respring {
    pid_t pid;
    const char *args[] = {"killall", "-9", "backboardd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);
}

@end

