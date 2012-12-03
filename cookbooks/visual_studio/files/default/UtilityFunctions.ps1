# ----------------------------------
# Functions
# ----------------------------------
function DownloadFile()
{
	param(
		[parameter(Mandatory=$true)] $url,
		[parameter(Mandatory=$true)] $threads = 5
	)
	
	# Set application filename
	$filename = "c:\aria2\aria2c.exe"
	
	# Set arguments
	$arguments=@(
		"--check-certificate=false",
		"--split=$threads",
		"--file-allocation=none",
		"--allow-overwrite=true",
		"$url"
		)
	
	$arguments = [string]::Join(' ',$arguments)
	
	# Create command from filename and arguments
	$cmd = "$filename $arguments"
	
	# Log Start Time
	$startTime = Get-Date
	Write-Log "Starting download: $url"
	
	# Download File
	Invoke-Expression $cmd

	# Quit if error was generated
	if (!$?)
	{
		Write-Log "Error, Could not download $url"
		Write-Error Error[0]
		#Exit 1
	}
	else
	{
		# Log end time
		$endTime = Get-Date
		$timeTaken = ($endTime-$startTime)
		
		$logMessage ="Finished download.`n"`
						+ "Time taken: "`
						+ $timeTaken.Days + " Days "`
						+ $timeTaken.Minutes + " minutes "`
						+ $timeTaken.Seconds + " seconds"
		Write-Log $logMessage
	}
}

function Write-Log()
{
	param(
		[parameter(Mandatory=$true)] $message
	)
	
	$timeStamp = Get-Date -Format "yyyy-MM-dd hh:m:ss"
	$logEntry = $timeStamp + " " + $message
	Write-Output $logEntry
	Write-EventLog -LogName RightScale -Source "RightLink Service" -EventId 1000 -Message $logEntry
}



# ------------------------
# Functions
# ------------------------


function LoadAwsSDK()
{
	try {
		$aws_sdk = "AWS SDK for .NET"

		#check to see if the package is already installed
		if (Test-Path (${env:programfiles(x86)}+"\"+$aws_sdk)) { 
		  $aws_sdk_path = ${env:programfiles(x86)}+"\"+$aws_sdk 
		} Elseif (Test-Path (${env:programfiles}+"\"+$aws_sdk)) { 
		  $aws_sdk_path = ${env:programfiles}+"\"+$aws_sdk 
		}

		if ($aws_sdk_path -eq $null) {
		  Write-Error "*** AWS SDK for .NET package is not installed on the system. Aborting."
		  exit 12
		}

		#use the AWS SDK dll
		Add-Type -Path "$aws_sdk_path\bin\AWSSDK.dll"
	}
	catch [Exception e]
	{
		Write-Error "Could not load AWS SDK assembly !"
		Exit 1
	}
}

function GetSignedUrl()
{
	param (
		[parameter(Mandatory=$true)] $bucketName,
		[parameter(Mandatory=$true)] $key,
		[parameter(Mandatory=$true)] $awsAccessKey,
		[parameter(Mandatory=$true)] $awsSecretKey
	)


	$s3Client = [Amazon.AWSClientFactory]::CreateAmazonS3Client($AwsAccessKey,$AWSSecretKey)

	$preSignedUrlRequest = New-Object Amazon.s3.Model.GetPreSignedUrlRequest
	$preSignedUrlRequest.BucketName = $bucketName;
	$preSignedUrlRequest.Key = $key;
	$preSignedUrlRequest.Expires = (get-date).AddMinutes(30)

	$preSignedUrl = $s3Client.GetPreSignedURL($preSignedUrlRequest)

	Write-Output $preSignedUrl
}



