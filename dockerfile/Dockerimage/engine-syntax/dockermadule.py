import json, os, shutil


def readJsonFile(file):
    with open(file, 'r') as ReadJson:
        return json.load(ReadJson)

def detectSyntax(list):
    for index, syntax in list.items():
        if shutil.which(index):
            return syntax
    return None

def createJsonFile(file, list):
    if not os.path.exists(file):
        with open(file, 'w') as CJson:
            json.dump(list, CJson, indent=4)
        print("[ Docker-Engine ]: command db Created.")
    else:
        print("[ Docker-Engine ]: command db checked.")

def getCommand(manager, action):
    mode = "root" if os.geteuid() == 0 else "sudo"
    return manager[mode][action]

def commandPrefix():
    return "" if os.geteuid() == 0 else "sudo"

def readDockerfile(file):
    with open(file, 'r') as CDFile:
        return CDFile.read()

def exists(file):
    return os.path.exists(file)