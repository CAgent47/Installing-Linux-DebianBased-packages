import omnimadule

pkg_Managers_2 = omnimadule.loadJson('core/distroPKG.json')

user_package_Manager = omnimadule.loopInDICT(pkg_Managers_2)

print(pkg_Managers_2[user_package_Manager]["update"])