import omnimodule

detectSyntax = omnimodule.loadJson('core/distroPKG.json')

SyntaxcleanDetect = omnimodule.loopInDICT(detectSyntax)

print(detectSyntax[SyntaxcleanDetect][omnimodule.userMod()]["clean"])