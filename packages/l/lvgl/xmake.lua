package("lvgl")

    set_homepage("https://lvgl.io")
    set_description("Light and Versatile Graphics Library")
    set_license("MIT")

    add_urls("https://github.com/lvgl/lvgl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lvgl/lvgl.git")
    add_versions("v8.0.2", "7136edd6c968b60f0554130c6903f16870fa26cda11a2290bc86d09d7138a6b4")

    add_configs("shared",      {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("color_depth", {description = "Set color depth.", default = "32", type = "string", values = {"1", "8", "16", "32"}})
    add_configs("use_log",     {description = "Enable the log module.", default = false, type = "boolean"})

    add_deps("cmake")
    on_install(function (package)
        os.mv("lv_conf_template.h", "src/lv_conf.h")
        io.replace("src/lv_conf.h", "#if 0", "#if 1")
        io.replace("src/lv_conf.h", "#define LV_BUILD_EXAMPLES -1", "#define LV_BUILD_EXAMPLES 0")
        io.replace("src/lv_conf.h", "#define LV_COLOR_DEPTH -16", "#define LV_COLOR_DEPTH " .. package:config("color_depth"))
        io.replace("src/lv_conf.h", "#define LV_USE_LOG -0", "#define LV_USE_LOG " .. (package:config("use_log") and "1" or "0"))
        io.replace("CMakeLists.txt", "add_library(lvgl STATIC ${SOURCES})", "add_library(lvgl STATIC ${SOURCES})\ninstall(TARGETS lvgl)\ninstall(FILES lvgl.h DESTINATION include)\ninstall(DIRECTORY src DESTINATION include FILES_MATCHING PATTERN \"*.h\")", {plain = true})
        io.replace("CMakeLists.txt", "if(ESP_PLATFORM)", "cmake_minimum_required(VERSION 3.15)\nif(ESP_PLATFORM)", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lv_version_info", {includes = "lvgl.h"}))
    end)
