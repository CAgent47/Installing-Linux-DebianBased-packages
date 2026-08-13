import json
import shutil

def readJsonFile(file):
    with open(file, 'r') as ReadJson:
        return json.load(ReadJson)

SyntaxInstall = readJsonFile('dockerinstall.json')

for index, syntax in SyntaxInstall.items():
    if shutil.which(index):
        DetectSyntax = syntax
        break

print(DetectSyntax["sudo"]["autoremove"])