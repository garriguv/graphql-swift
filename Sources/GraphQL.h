#include <TargetConditionals.h>

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
@import UIKit;
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for GraphQL.
FOUNDATION_EXPORT double GraphQLVersionNumber;

//! Project version string for GraphQL.
FOUNDATION_EXPORT const unsigned char GraphQLVersionString[];
