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
from mysqlconnection import MySQLConnector

server = Flask(__name__)
mysql = MySQLConnector(server, 'mydb')

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

$dbpy = @"
""" import the necessary modules """
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.sql import text
# Create a class that will give us an object that we can use to connect to a database
class MySQLConnection(object):
    def __init__(self, app, db):
        config = {
                'host': 'localhost',
                'database': db, # we got db as an argument
                'user': 'root',
                'password': 'root',
                'port': '3306' # change the port to match the port your SQL server is running on
        }
        # this will use the above values to generate the path to connect to your sql database
        DATABASE_URI = "mysql://{}:{}@127.0.0.1:{}/{}".format(config['user'], config['password'], config['port'], config['database'])
        app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URI
        app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
        # establish the connection to database
        self.db = SQLAlchemy(app)
    # this is the method we will use to query the database
    def query_db(self, query, data=None):
        result = self.db.session.execute(text(query), data)
        if query[0:6].lower() == 'select':
            # if the query was a select
            # convert the result to a list of dictionaries
            list_result = [dict(r) for r in result]
            # return the results as a list of dictionaries
            return list_result
        elif query[0:6].lower() == 'insert':
            # if the query was an insert, return the id of the
            # commit changes
            self.db.session.commit()
            # row that was inserted
            return result.lastrowid
        else:
            # if the query was an update or delete, return nothing and commit changes
            self.db.session.commit()
# This is the module method to be called by the user in server.py. Make sure to provide the db name!
def MySQLConnector(app, db):
    return MySQLConnection(app, db)
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
        New-Item $title\server.py, $title\static\css\styles.css, $title\templates\index.html,$title\static\scripts\app.js, $title\mysqlconnection.py  > $null
        $html | Set-Content $title'\templates\index.html' > $null
        $py | Set-Content $title'\server.py' > $null
        $dbpy | Set-Content $title'\mysqlconnection.py' > $null
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