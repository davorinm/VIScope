//
//  SwiftChart.h
//  SwiftChart
//
//  Created by Davorin Mađarić on 17/04/2019.
//  Copyright © 2019 Davorin Mađarić. All rights reserved.
//

#include <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_OS_TV || TARGET_IPHONE_SIMULATOR
    #import <UIKit/UIKit.h>
#else
    #import <Cocoa/Cocoa.h>
#endif

//! Project version number for SwiftChart.
FOUNDATION_EXPORT double SwiftChartVersionNumber;

//! Project version string for SwiftChart.
FOUNDATION_EXPORT const unsigned char SwiftChartVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftChart/PublicHeader.h>


