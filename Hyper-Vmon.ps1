#Hyper-V Replicas report script
#This script requires Powershell 3.0

#Servers to check
$hosts = @("Server01","Server02","Server03","Server04")

#SMTP Server (Unauthenticated)
$smtpServer = smtp.provider.com

#From
$from = "From@your-email.com" 

#Recipient for the report
[string[]]$recipients = "your@email.com","another@email.com"

$message_body = @("<html><body>","Hyper-V Replica daily report","")

#Retrieves information from servers in $hosts variable
foreach ($element in $hosts) { $message_body += "=============================";
    $message_body += "Status for $element VMs";
    $message_body += "=============================";
    $message_body += Invoke-Command -ComputerName $element -Scriptblock { Get-VMReplication | format-table | Out-String | ForEach-Object { $_ -replace "Warning","<font color='FF0000'>Warning</font>" } } 
    
    }

$message_body += "</body></html>"

#Formats the $message_body content
$message_body2 = $message_body -replace "(?m)$","<br/>"

$body = [string]::Join([Environment]::NewLine,$message_body2);

#Sends out the e-mail
Send-MailMessage -From $from -Subject "Hyper-V VMs Replication Reports" -To $recipients -SmtpServer $smtpServer -BodyAsHtml $body