# buildifier: disable=module-docstring
def _execute_command(ctx, cmd):
    result = ctx.execute(cmd)
    if result.return_code != 0:
        return None
    else:
        return result.stdout

def _homebrew_prefix(ctx, pkg_name):
    return _execute_command(ctx, ["brew", "--prefix", pkg_name])

def _execute_pkg_config(ctx, pkg_name, options):
    return _execute_command(ctx, ["pkg-config", pkg_name] + options)

def _pkg_config_include(ctx, pkg_name):
    result = _execute_pkg_config(ctx, pkg_name, ["--cflags-only-I"])
    return result.strip()[len("-I"):]

def _pkg_config_linkdir(ctx, pkg_name):
    result = _execute_pkg_config(ctx, pkg_name, ["--libs-only-L"])
    return result.strip()[len("-L"):]

def _pkg_config_linkopts(ctx, pkg_name):
    result = _execute_pkg_config(ctx, pkg_name, ["--libs-only-l"])
    linkopts = []
    for opt in result.strip().split(" "):
        linkopts.append(opt[len("-l"):])
    return linkopts

def _get_pkg_include(ctx, pkg_name, include):
    external = ctx.path("dep_hdrs_" + pkg_name)
    ctx.symlink(ctx.path(include), external)
    return external.basename

def _get_pkg_libs(ctx, pkg_name, linkdir, linkopts):
    external = ctx.path("dep_libs_" + pkg_name)
    ctx.symlink(ctx.path(linkdir), external)
    libs = []
    for opt in linkopts:
        libs.append(external.basename + "/lib" + opt + ".dylib")
    return libs

def _render_pkg_template(ctx, pkg_include, pkg_libs):
    ctx.template("BUILD", Label("//:BUILD.tpl"), substitutions = {
        "%{pkg_include}": pkg_include,
        "%{pkg_libs}": ",".join(pkg_libs)
    })

# buildifier: disable=module-docstring
def _pkg_config_shared_impl(ctx):
    if ctx.which("pkg-config") == None:
        fail("pkg-config not found\n")
    
    pkg_name = ctx.attr.name
    if _execute_pkg_config(ctx, pkg_name, ["--exists"]) == None:
        fail("pkg-config '%s' not found" % (pkg_name))

    include = _pkg_config_include(ctx, pkg_name)
    linkdir = _pkg_config_linkdir(ctx, pkg_name)
    linkopts = _pkg_config_linkopts(ctx, pkg_name)
    pkg_include = _get_pkg_include(ctx, pkg_name, include)
    pkg_libs = _get_pkg_libs(ctx, pkg_name, linkdir, linkopts)
    _render_pkg_template(ctx, pkg_include, pkg_libs)

def _homebrew_shared_impl(ctx):
    if ctx.which("brew") == None:
        fail("homebrew is not installed")
    
    pkg_name = ctx.attr.name
    prefix = _homebrew_prefix(ctx, pkg_name)
    prefix = prefix.strip()
    if prefix == None:
        fail("homebrew prefix '%s' not found" % (pkg_name))

    linkopts = []
    for opt in ctx.attr.linkopts.split(","):
        linkopts.append(opt[len("-l"):])
    include = prefix + "/include"
    linkdir = prefix + "/lib"
    pkg_include = _get_pkg_include(ctx, pkg_name, include)
    pkg_libs = _get_pkg_libs(ctx, pkg_name, linkdir, linkopts)
    _render_pkg_template(ctx, pkg_include, pkg_libs)

pkg_config_shared = repository_rule(
    attrs = {},
    local = True,
    implementation = _pkg_config_shared_impl
)

homebrew_shared = repository_rule(
    attrs = {
        "linkopts": attr.string(doc = "linkopts")
    },
    local = True,
    implementation = _homebrew_shared_impl
)
