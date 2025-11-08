flutter build linux --release --split-debug-info=./debug-info --obfuscate --dart-define=ENABLE_VULKAN=true  --target-platform=linux-x64 --dart-define=OPTIMIZED_BUILD=true


strip ./build/linux/x64/release/bundle/hellow