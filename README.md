### Usage

Add pkg-config repository in WORKSPACE

```
http_archive(
    name = "bazel_pkg_config",
    strip_prefix = "bazel_pkg_config-macos2",
    urls = ["https://github.com/yangxin0/bazel_pkg_config/archive/refs/tags/macos2.zip"],
    sha256 = "6e4bff63a5cadd6fc790cf4c3c93b9b4418fcb7c023c98caf610ba141774b94d
)

load("@bazel_pkg_config//:pkg_config.bzl", "pkg_config_shared")

pkg_config_shared(name = "pkg-config library")
```

Add deps into cc_library

```
cc_binary(
    name = "your library",
    srcs = ["your source file"],
    deps = [
        "@pkg_config library//:shared_lib",
    ]
)
```



