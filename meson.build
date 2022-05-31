# Project Declaration
#~ first statement must be a call to project()
project(
#~     app, # Project ID
    'clip-qrcode-share', # Project ID
    ['vala', 'c'], # Compilers
    version: '0.1' # Version
)

#~ app = 'clip-qrcode-share'

#~ 添加 vapi 搜索目录
vapi_dir = meson.current_source_dir()
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

lib_dependencies = [
    dependency('gtk4'),
    dependency('libadwaita-1'),
#~     dependency('libqrencode', version: '>=4.0.0'), # depend libqrencode-dev
    meson.get_compiler('vala').find_library('posix'),
#~ https://mesonbuild.com/Vala.html#adding-to-valas-search-path
#~ The standard maths functions are already bound in glib-2.0.vapi, but the GNU C library requires linking to the maths library separately.
#~     meson.get_compiler('c').find_library('m', required: false),
]

executable(
#~     app, # Binary Name
    meson.project_name(), # Binary Name
    # Source Files
    meson.project_name() + '.vala',
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
