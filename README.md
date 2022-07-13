### Usage

Add pkg-config repository in WORKSPACE

```
http_archive(
    name = "bazel_pkg_config",
    strip_prefix = "bazel_pkg_config-macos",
    urls = ["https://github.com/yangxin0/bazel_pkg_config/archive/refs/tags/macos.zip"],
    sha256 = "2a5c95af3486aae32861abc0b642c766f171216e23b8ee297dbf8432c0832f7e"
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



