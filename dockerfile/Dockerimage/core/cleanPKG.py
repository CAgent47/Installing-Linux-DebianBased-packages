import omnimadule

detectSyntax = omnimadule.loadJson('core/distroPKG.json')

SyntaxcleanDetect = omnimadule.loopInDICT(detectSyntax)

print(detectSyntax[SyntaxcleanDetect]["clean"])