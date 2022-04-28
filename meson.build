# Project Declaration
#~ first statement must be a call to project()
project(
#~     app, # Project ID
    'clip2qrcode', # Project ID
    ['vala', 'c'], # Compilers
    version: '0.1' # Version
)

app = 'clip2qrcode'

lib_dependencies = [
    dependency('gtk4'),
    dependency('libadwaita-1'),
    meson.get_compiler('vala').find_library('posix'),
]

executable(
    app, # Binary Name
#~     'clip2qrcode', # Binary Name
    # Source Files
    app + '.vala',
    dependencies: lib_dependencies,
    install: false
)
#~ Package `glib-2.0' not found in specified Vala API directories
#~ ⭕ pf build-ess*
#~ 正在列表... 完成
#~ build-essential/jammy,now 12.9ubuntu3 amd64 [已安装，自动]
#~ ⭕  valac --version
#~ Vala 0.56.0
#~ ⭕ pi valac-0.56-vapi
#~ meson.build:8:0: ERROR: Dependency "libadwaita-1" not found, tried pkgconfig and cmake
#~ ⭕ pi libadwaita-1-dev
