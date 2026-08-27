import os
import sys
import omnimadule

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

pkg_Managers_2 = omnimadule.loadJson(os.path.join(BASE_DIR, 'distroPKG.json'))

user_package_Manager = omnimadule.loopInDICT(pkg_Managers_2)

if user_package_Manager is None:
    print("[ Python Error ]: No supported package manager detected on this system", file=sys.stderr)
    sys.exit(1)

print(pkg_Managers_2[user_package_Manager]["update"])