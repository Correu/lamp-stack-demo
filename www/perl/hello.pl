#!/usr/bin/perl

print "Content-type: text/html\n\n";
print <<HTML;
<html>
<head>
    <title>Hello from Local WWW Folder</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            line-height: 1.6;
        }
        h1 { color: #4a5568; }
        .info { background: #edf2f7; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Hello from your local www folder!</h1>
    <div class="info">
        <p>This Perl script is running from your mounted volume.</p>
        <p>Current time: @{[scalar localtime]}</p>
        <p>Server hostname: @{[`hostname`]}</p>
    </div>
</body>
</html>
HTML
