import omnimodule

pkg_Managers_2 = omnimodule.loadJson('core/distroPKG.json')

user_package_Manager = omnimodule.loopInDICT(pkg_Managers_2)

print(pkg_Managers_2[user_package_Manager]["update"])