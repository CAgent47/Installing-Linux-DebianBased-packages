import omnimodule

detectSyntax = omnimodule.loadJson('core/distroPKG.json')

SyntaxInstallDetect = omnimodule.loopInDICT(detectSyntax)

print(detectSyntax[SyntaxInstallDetect]["install"])