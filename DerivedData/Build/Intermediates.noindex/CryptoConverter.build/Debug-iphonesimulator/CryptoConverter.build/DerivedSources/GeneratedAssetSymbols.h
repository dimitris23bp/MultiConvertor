#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "btc" asset catalog image resource.
static NSString * const ACImageNameBtc AC_SWIFT_PRIVATE = @"btc";

/// The "eth" asset catalog image resource.
static NSString * const ACImageNameEth AC_SWIFT_PRIVATE = @"eth";

/// The "litecoin" asset catalog image resource.
static NSString * const ACImageNameLitecoin AC_SWIFT_PRIVATE = @"litecoin";

/// The "logo app" asset catalog image resource.
static NSString * const ACImageNameLogoApp AC_SWIFT_PRIVATE = @"logo app";

#undef AC_SWIFT_PRIVATE
