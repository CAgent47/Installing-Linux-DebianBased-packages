import os
import sys
import dockermadule

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

SyntaxInstall = dockermadule.readJsonFile(os.path.join(BASE_DIR, 'dockerinstall.json'))

DetectSyntax = dockermadule.detectSyntax(SyntaxInstall)

if DetectSyntax is None:
    print("[ Docker-Engine ]: No supported package manager detected", file=sys.stderr)
    sys.exit(1)

print(dockermadule.getCommand(DetectSyntax, "Install"))