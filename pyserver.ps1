param(
    [string]$type,
    [string]$title
)

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

if($type -eq $null -and $title -eq $null){
    Write-Error "command: type does not exist. Must contain either -type init or -title <name>".
}
elseif($type -eq "init"){
    mkdir templates, static
    mkdir static\css, static\images, static\scripts
    New-Item server.py, static\css\styles.css, templates\index.html, static\scripts\app.js
    $html | Set-Content 'templates\index.html'
    $py | Set-Content 'server.py'
}
elseif ($title -ne $null){
    mkdir $title
    mkdir $title\templates, $title\static
    mkdir $title\static\css, $title\static\images, $title\static\scripts
    New-Item $title\server.py, $title\static\css\styles.css, $title\templates\index.html,$title\static\scripts\app.js
    $html | Set-Content $title'\templates\index.html'
    $py | Set-Content $title'\server.py'
}