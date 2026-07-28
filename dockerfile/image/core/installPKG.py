import omnimadule

detectSyntax = omnimadule.loadJson('core/distroPKG.json')

SyntaxInstallDetect = omnimadule.loopInDICT(detectSyntax)

print(detectSyntax[SyntaxInstallDetect]["install"])