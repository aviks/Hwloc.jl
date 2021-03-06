using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libhwloc"], :libhwloc),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Hwloc-v2.0.4+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/hwloc.v2.0.4.aarch64-linux-gnu.tar.gz", "64222a4cfa77635b98d06131b6504a8b437c98de9166117a4873ccf62bc9e3e8"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/hwloc.v2.0.4.aarch64-linux-musl.tar.gz", "1d40b704ffa977f96472ac514176ab4b1c06c1ad783442cb81c9bfb55a42d87a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/hwloc.v2.0.4.arm-linux-gnueabihf.tar.gz", "d3587982edd2eb1b89d27d39573b4835dce716d99e1638df9f827a076bf049f5"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/hwloc.v2.0.4.arm-linux-musleabihf.tar.gz", "5533aa0a7e0ed083dc3d6787da680272e507314ba993b9ebc563f32961ca2f75"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/hwloc.v2.0.4.i686-linux-gnu.tar.gz", "687ee32ec1b7538165eae669400f0006fa71ef0818b2e3044e26e9583ebebd3f"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/hwloc.v2.0.4.i686-linux-musl.tar.gz", "1e4e8bc23237f7db3adbeb481544a3a4d5b935cb3c04de62a67d5ae383ba5fbd"),
    Windows(:i686) => ("$bin_prefix/hwloc.v2.0.4.i686-w64-mingw32.tar.gz", "3f06b9ae0229d5b3ca00f0d0886b29a240763ba4d8e2c11432f66b74bfc2bf20"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/hwloc.v2.0.4.powerpc64le-linux-gnu.tar.gz", "44035d77569fd3006cc2582ec6152867f08eedfe7a564a2c54ac719bf2afc1de"),
    MacOS(:x86_64) => ("$bin_prefix/hwloc.v2.0.4.x86_64-apple-darwin14.tar.gz", "e565fc950268c278ffcf1f695ce08177b3d194176a00dbf59d356b902bcb4115"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/hwloc.v2.0.4.x86_64-linux-gnu.tar.gz", "50f0a52393d96741a2d9b7cc965143c2c659c77abc87d2721e9f932474eae6db"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/hwloc.v2.0.4.x86_64-linux-musl.tar.gz", "5cdc5f59a8bee5c7929da6e1038ab21e735f49c3f4721acace3565a8883113e8"),
    FreeBSD(:x86_64) => ("$bin_prefix/hwloc.v2.0.4.x86_64-unknown-freebsd11.1.tar.gz", "3045a1e77ad4fef5c73999e33314af7bbe4f13cd84e8d1f281b9650c78c472bf"),
    Windows(:x86_64) => ("$bin_prefix/hwloc.v2.0.4.x86_64-w64-mingw32.tar.gz", "530fc4425df9863eea1f7ebd90d192c6050b4f15b6b028cdcd572ddb0a745d80"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
