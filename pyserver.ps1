param(
    [string]$type,
    [string]$title
)
$ErrorActionPreference = "Stop"
$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="{{ url_for('static', filename='css/styles.css')}}">
    <script src="{{ url_for('static', filename='scripts/app.js')}}" type="text/javascript"></script>
    <title>Document</title>
</head>
<body>
</body>
</html>
"@

$py = @"
from flask import Flask, render_template

server = Flask(__name__)

@server.route('/')
def index():
    return render_template('index.html')

server.run(debug=True)
"@

$helpTxt = @"

pyserver -type <types> [-title <titles>]

types available:
    init: loads default flask files in specified directory
    js: loads default flask files and js with jQuery in specified directory
    help: loads list of commands in commandline

titles available:
    [any]: When using -title command it creates a directory under that name and loads all default flask files
           if type is not set, init is the default

"@

$jsConfig = @"
{
    "typeAcquisition": {
        "include": [
            "jquery"
        ]
    }
}
"@

$jsHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="{{ url_for('static', filename='css/styles.css')}}">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>    
    <script src="{{ url_for('static', filename='scripts/app.js')}}" type="text/javascript"></script>
    <title>Document</title>
</head>
<body>
</body>
</html>
"@

if(!$title){
    $title = (Resolve-Path .\).Path
    Write-Host $title
}

if($type.equals("init")){
    try{
        Write-Host "Building..." -NoNewline
        mkdir $title\templates, $title\static > $null
        mkdir $title\static\css, $title\static\images, $title\static\scripts > $null
        New-Item $title\server.py, $title\static\css\styles.css, $title\templates\index.html,$title\static\scripts\app.js > $null
        $html | Set-Content $title'\templates\index.html' > $null
        $py | Set-Content $title'\server.py' > $null
        Write-Host " Build finished! All filed loaded successfully."
    }catch{
        Write-Host " Build Failed! Some files may already exist! To avoid overwriting, those files were skipped"
    }
}
if($type.equals("js")){
    try{
        Write-Host "Building..." -NoNewline
        mkdir $title\templates, $title\static > $null
        mkdir $title\static\css, $title\static\images, $title\static\scripts > $null
        New-Item $title\server.py, $title\static\css\styles.css, $title\templates\index.html,$title\static\scripts\app.js, $title\static\scripts\jsconfig.json  > $null
        $jsHtml | Set-Content $title'\templates\index.html' > $null
        $py | Set-Content $title'\server.py' > $null
        $jsConfig | Set-Content $title'\static\scripts\jsconfig.json' > $null
        Write-Host " Build finished! All filed loaded successfully."
    }catch{
        Write-Host " Build Failed! Some files may already exist! To avoid overwriting, those files were skipped"
    }
}
elseif($type.equals("help")){
    Write-Host $helpTxt
}
else{
    Write-Host "command type does not exist. Must contain either -type <types> or -title <titles>. Write pyserver help to look at commands list"
}