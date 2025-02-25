package("nlohmann_json")

    set_homepage("https://nlohmann.github.io/json/")
    set_description("JSON for Modern C++")

    add_urls("https://github.com/nlohmann/json/archive/$(version).tar.gz",
             "https://github.com/nlohmann/json.git")
    add_versions("v3.10.0", "eb8b07806efa5f95b349766ccc7a8ec2348f3b2ee9975ad879259a371aea8084")
    add_versions("v3.9.1", "4cf0df69731494668bdd6460ed8cb269b68de9c19ad8c27abc24cd72605b2d5b")

    add_configs("cmake", {description = "Use cmake buildsystem", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {"-DJSON_BuildTests=OFF"}
            import("package.tools.cmake").install(package, configs)
        else
            if os.isdir("include") then
                os.cp("include", package:installdir())
            else
                os.cp("*", package:installdir("include"))
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using json = nlohmann::json;
            void test() {
                json data;
                data["name"] = "world";
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"nlohmann/json.hpp"}}))
    end)
