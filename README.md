### Usage

Add pkg-config repository in WORKSPACE

```
http_archive(
    name = "bazel_pkg_config",
    strip_prefix = "bazel_pkg_config-main",
    urls = ["https://github.com/yangxin0/bazel_pkg_config/archive/refs/heads/main.zip"],
    # update to main.zip sha256
    sha256 = "6f1041545e29f5c2419fd1655f928c34f99f248e7a4e886d1c7044f67d6c7940"
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



