package(default_visibility = ["//visibility:private"])

libs = "%{pkg_libs}".split(",")
deps = [lib.replace("/", "_") for lib in libs]
[cc_import(name = lib.replace("/", "_"), shared_library = lib) for lib in libs]

cc_library(
    name = "shared_lib",
    hdrs = glob(["%{pkg_include}/**/*.h"]),
    deps = deps,
    strip_include_prefix = "%{pkg_include}",
    visibility = ["//visibility:public"],
)