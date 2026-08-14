import json, os, shutil


def readJsonFile(file):
    with open(file, 'r') as ReadJson:
        return json.load(ReadJson)

def detectSyntax(list):
    for index, syntax in list.items():
        if shutil.which(index):
            return syntax

def createJsonFile(file, list):
    if not os.path.exists('engine-syntax/dockerinstall.json'):
        with open(file, 'w') as CJson:
            json.dump(list, CJson, indent=4)

def getCommand(manager, action):
    mode = "root" if os.geteuid() == 0 else "sudo"
    return manager[mode][action]