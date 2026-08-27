import os
import sys
import omnimadule

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

detectSyntax = omnimadule.loadJson(os.path.join(BASE_DIR, 'distroPKG.json'))

SyntaxInstallDetect = omnimadule.loopInDICT(detectSyntax)

if SyntaxInstallDetect is None:
    print("[ Python Error ]: No supported package manager detected on this system", file=sys.stderr)
    sys.exit(1)

print(detectSyntax[SyntaxInstallDetect]["install"])