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

function getSignedUrl()
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


#-----------------------
# MAIN
#-----------------------

# Load the AWS SDK for .NET assembly
LoadAwsSDK

# Get the signed URL from S3
$myUrl = getSignedUrl `
			-bucketName "$env:BUCKET_NAME" `
			-key "$env:KEY" `
			-awsAccessKey "$env:AWS_ACCESS_KEY_ID" `
			-awsSecretKey "$env:AWS_SECRET_ACCESS_KEY"

# Output URL
Write-Output "My url is: $myUrl"

mkdir -force c:\temp
Add-Content -path c:\temp\url.txt -value $myUrl