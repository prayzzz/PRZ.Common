properties {
    Import-Module psake-contrib/teamcity.psm1

    # Version
    $date = Get-Date -Format yyyy.MM.dd;
    $minutes = [math]::Round([datetime]::Now.TimeOfDay.TotalMinutes)
    $version = "1.0.0-$date.$minutes"

    # Project
    $config = Get-Value-Or-Default($env:CONFIGURATION, "Debug")
    
    $commonProjectDir = "src/prayzzz.Common";    
    $outputFolder = "dist/"

    # Teamcity
    $isTeamcity = $env:TEAMCITY_VERSION
    if ($isTeamCity) { TeamCity-SetBuildNumber $version }

    # Change to root directory
    Set-Location "../"

    Write-Host "Building $version"
}

FormatTaskName {
   ""
   ""
   Write-Host "Executing Task: $taskName" -foregroundcolor Cyan
}

# Alias

task Restore -depends Dotnet-Restore {
}

task Build -depends Dotnet-Build {
}

task Test -depends Dotnet-Test {
}

task Pack -depends Dotnet-Pack {
}

# Tasks

task Dotnet-Restore {
    exec { dotnet restore }
}

task Set-Version {
    Apply-Version("$commonProjectDir/project.json")
}

task Dotnet-Build -depends Dotnet-Restore, Set-Version {
    exec { dotnet build $commonProjectDir --configuration $config }
}

task Dotnet-Test -depends Dotnet-Build {
    #Run-Test("prayzzz.Common.Test")
}

task Dotnet-Pack -depends Dotnet-Build {
    Pack-Project("prayzzz.Common")
}

function Pack-Project($project){
    exec { dotnet pack "src/$project/" --configuration $config --no-build --output $outputFolder }

    $file = $outputFolder + "$project.$version.nupkg"
    exec { nuget push $file $env:NUGET_APIKEY -Source https://www.nuget.org/api/v2/package }
}

function Apply-Version ($file) {
    $project = ConvertFrom-Json -InputObject (Gc $file -Raw)
    $project.version = $version
    $project | ConvertTo-Json -depth 100 | Out-File $file
}

function Run-Test ($project) {
    if ($isTeamCity) {
        TeamCity-TestSuiteStarted $project
    }

    exec { dotnet test "test/$project/" --configuration $config --result "TestResult.$project.xml" }

    if ($isTeamCity) {
        TeamCity-TestSuiteFinished $project
    }
}

function Get-Value-Or-Default($value, $default) {
    if (!$value -or $value -eq "") {
        return $default
    }

    return $value;
}