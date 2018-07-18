"""This module contains j2cl_transpile helper function."""

def j2cl_transpile(ctx, java_provider):
    """ Takes Java provider and translates it into Closure style JS in a zip bundle."""

    native_files = ctx.files.native_srcs
    js_files = ctx.files.js_srcs

    # Using source_jars of the java_library since that includes APT generated src.
    src_jars = java_provider.source_jars
    java_deps = java_provider.compilation_info.compilation_classpath

    # convert files to paths
    deps_paths = [j.path for j in java_deps]
    src_paths = [j.path for j in src_jars + native_files + js_files]

    compiler_args = ["-output", ctx.outputs.zip_file.path]
    compiler_args += ["-classpath", ctx.configuration.host_path_separator.join(deps_paths)]

    # Generate readable_maps
    if ctx.attr.readable_source_maps:
        compiler_args += ["-readablesourcemaps"]

    # Emit goog.module.declareLegacyNamespace(). This is a temporary measure
    # while onboarding Docs, do not use.
    if ctx.attr.declare_legacy_namespace:
        compiler_args += ["-declarelegacynamespaces"]

    if ctx.var.get("GROK_ELLIPSIS_BUILD", None):
        compiler_args += ["-generatekytheindexingmetadata"]

    # The transpiler expects each file path as a separate argument.
    compiler_args += src_paths

    # Create an action to write the flag file
    compiler_args_file = ctx.new_file(ctx.label.name + "_compiler.args")
    ctx.actions.write(
        output = compiler_args_file,
        content = "\n".join(compiler_args),
    )

    inputs = []
    inputs += src_jars
    inputs += js_files
    inputs += native_files
    inputs += list(java_deps)
    inputs += [compiler_args_file]

    ctx.action(
        progress_message = "Transpiling to JavaScript %s" % ctx.label,
        inputs = inputs,
        outputs = [ctx.outputs.zip_file],
        executable = ctx.executable.transpiler,
        arguments = ["@" + compiler_args_file.path],
        env = dict(LANG = "en_US.UTF-8"),
        execution_requirements = {"supports-workers": "1"},
        mnemonic = "J2clTranspile",
    )

# Private Args:
#   transpiler: J2CL compiler jar to use.
J2CL_TRANSPILE_ATTRS = {
    "native_srcs": attr.label_list(allow_files = [".native.js", ".zip"]),
    "js_srcs": attr.label_list(allow_files = [".js", ".zip"]),
    "readable_source_maps": attr.bool(default = False),
    "declare_legacy_namespace": attr.bool(default = False),
    "transpiler": attr.label(
        cfg = "host",
        executable = True,
        allow_files = True,
        default = Label("//internal_do_not_use:BazelJ2clBuilder"),
    ),
}
