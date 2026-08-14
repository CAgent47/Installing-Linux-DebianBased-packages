import dockermadule

SyntaxInstall = dockermadule.readJsonFile('engine-syntax/dockerinstall.json')

DetectSyntax = dockermadule.detectSyntax(SyntaxInstall)

print(dockermadule.getCommand(DetectSyntax, "Install"))