"""Bzlmod extensions for Dart rules."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_DART_SDK_BUILD_FILE = """
package(default_visibility = [ "//visibility:public" ])

filegroup(
  name = "dart_vm",
  srcs = ["dart-sdk/bin/dart"],
)

filegroup(
  name = "dart2js",
  srcs = ["dart-sdk/bin/dart2js"],
)

filegroup(
  name = "dart2js_support",
  srcs = glob([
      "dart-sdk/bin/dart",
      "dart-sdk/bin/snapshots/dart2js.dart.snapshot",
      "dart-sdk/lib/**",
  ]),
)

filegroup(
  name = "pub",
  srcs = ["dart-sdk/bin/pub"],
)

filegroup(
  name = "pub_support",
  srcs = glob([
      "dart-sdk/version",
      "dart-sdk/bin/dart",
      "dart-sdk/bin/snapshots/pub.dart.snapshot",
  ]),
)
"""

def _dart_repositories_extension_impl(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for config in mod.tags.configure:
            registrations.update({
                "sdk_channel": config.sdk_channel,
                "sdk_version": config.sdk_version,
                "linux_x64_sha": config.linux_x64_sha,
                "macos_arm64_sha": config.macos_arm64_sha,
                "macos_x64_sha": config.macos_x64_sha,
            })

    # Use provided values or defaults
    sdk_channel = registrations.get("sdk_channel", "stable")
    sdk_version = registrations.get("sdk_version", "2.17.7")
    linux_x64_sha = registrations.get("linux_x64_sha", "ba8bc85883e38709351f78c527cbf72e22cd234b3678a1ec6a2e781f7984e624")
    macos_arm64_sha = registrations.get("macos_arm64_sha", "a4be379202cf731c7e33de20b4abc4ca1e2e726bc5973222b3a7ae5a0cabfce1")
    macos_x64_sha = registrations.get("macos_x64_sha", "ba258fff40822cb410c4f1f7916b63f0837903a6bae8f4bd83341053b10ecbe3")

    sdk_base_url = ("https://storage.googleapis.com/dart-archive/channels/" +
        sdk_channel + "/release/" +
        sdk_version + "/sdk/")

    http_archive(
        name = "dart_linux_x86_64",
        url = sdk_base_url + "dartsdk-linux-x64-release.zip",
        sha256 = linux_x64_sha,
        build_file_content = _DART_SDK_BUILD_FILE,
    )

    http_archive(
        name = "dart_darwin_arm64",
        url = sdk_base_url + "dartsdk-macos-arm64-release.zip",
        sha256 = macos_arm64_sha,
        build_file_content = _DART_SDK_BUILD_FILE,
    )

    http_archive(
        name = "dart_darwin_x86_64",
        url = sdk_base_url + "dartsdk-macos-x64-release.zip",
        sha256 = macos_x64_sha,
        build_file_content = _DART_SDK_BUILD_FILE,
    )

    return None

configure = tag_class(
    attrs = {
        "sdk_channel": attr.string(default = "stable"),
        "sdk_version": attr.string(default = "2.17.7"),
        "linux_x64_sha": attr.string(),
        "macos_arm64_sha": attr.string(),
        "macos_x64_sha": attr.string(),
    },
)

dart_repositories_extension = module_extension(
    implementation = _dart_repositories_extension_impl,
    tag_classes = {"configure": configure},
) 