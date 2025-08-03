#import <Foundation/Foundation.h>

NSBundle* llmfarm_core_cpp_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"llmfarm_core_llmfarm_core_cpp.bundle"];

    NSBundle *preferredBundle = [NSBundle bundleWithURL:bundleURL];
    if (preferredBundle == nil) {
      return [NSBundle bundleWithPath:@"/Users/ryofujimura/GitHub/AIChat-OpenAI/LocalPackages/llmfarm_core_fixed/.build/index-build/arm64-apple-macosx/debug/llmfarm_core_llmfarm_core_cpp.bundle"];
    }

    return preferredBundle;
}