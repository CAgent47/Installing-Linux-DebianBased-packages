import shutil
import json
import os

def detectPackageManager(package_Manager):
    return shutil.which(package_Manager)

def loopInDICT(dict):
    for key, value in dict.items():
        if detectPackageManager(key):
            return key

def loadJson(file):
    with open(file, 'r') as loadJson:
        return json.load(loadJson)

def createJsonFile(file, list):
    with open(file, "w") as savePackages:
        json.dump(list, savePackages, indent=4)
    print(" ")
    print("[ Python Message ]: The json file did not exist and was created. Edit the config.json file to edit the installable packages.")
    print(" ")

def createJsonFileIFNotExists(file, creater, val):
    if not os.path.exists(file):
        createJsonFile(creater, val)
    else:
        print("[ Python Message ]: Success")