function Get-GitHubRelationships {
    param (
        [string]$githubUsername,
        [string]$token
    )

    try {
        $followersUrl = "https://api.github.com/users/$githubUsername/followers?per_page=100"
        $followers = Invoke-RestMethod -Uri $followersUrl -Headers @{ Authorization = "token $token" }

        $followingUrl = "https://api.github.com/users/$githubUsername/following?per_page=100"
        $following = Invoke-RestMethod -Uri $followingUrl -Headers @{ Authorization = "token $token" }

        while ($followers.Links.'next' -ne $null) {
            $nextPageUrl = $followers.Links.'next'
            $nextPage = Invoke-RestMethod -Uri $nextPageUrl -Headers @{ Authorization = "token $token" }
            $followers += $nextPage
        }

        while ($following.Links.'next' -ne $null) {
            $nextPageUrl = $following.Links.'next'
            $nextPage = Invoke-RestMethod -Uri $nextPageUrl -Headers @{ Authorization = "token $token" }
            $following += $nextPage
        }

        $notFollowedBack = $following | Where-Object { $_.login -notin $followers.login }

        Write-Host "People you follow but who don't follow you back:"
        $notFollowedBack | ForEach-Object { Write-Host $_.login }
    } catch {
        Write-Host "Error checking GitHub relationships: $_"
    }
}

function Unfollow-NonFollowers {
    param (
        [string]$githubUsername,
        [string]$token
    )

    try {
        $followersUrl = "https://api.github.com/users/$githubUsername/followers?per_page=100"
        $followers = Invoke-RestMethod -Uri $followersUrl -Headers @{ Authorization = "token $token" }

        $followingUrl = "https://api.github.com/users/$githubUsername/following?per_page=100"
        $following = Invoke-RestMethod -Uri $followingUrl -Headers @{ Authorization = "token $token" }

        while ($followers.Links.'next' -ne $null) {
            $nextPageUrl = $followers.Links.'next'
            $nextPage = Invoke-RestMethod -Uri $nextPageUrl -Headers @{ Authorization = "token $token" }
            $followers += $nextPage
        }

        while ($following.Links.'next' -ne $null) {
            $nextPageUrl = $following.Links.'next'
            $nextPage = Invoke-RestMethod -Uri $nextPageUrl -Headers @{ Authorization = "token $token" }
            $following += $nextPage
        }

        $notFollowedBack = $following | Where-Object { $_.login -notin $followers.login }

        Write-Host "Unfollowing people who don't follow you back:"
        if ($notFollowedBack.Count -eq 0) {
            Write-Host "No one to unfollow."
        } else {
            $notFollowedBack | ForEach-Object {
                $userToUnfollow = $_.login
                Write-Host "Attempting to unfollow $userToUnfollow..."
                # Uncomment the following line to perform the unfollow action
                # Invoke-RestMethod -Uri "https://api.github.com/user/following/$userToUnfollow" -Method Delete -Headers @{ Authorization = "token $token" }
                Write-Host "Unfollowed $userToUnfollow"
            }
        }
    } catch {
        Write-Host "Error unfollowing non-followers: $_"
    }
}

function Follow-LikelyFollowers {
    param (
        [string]$githubUsername,
        [string]$token
    )

    try {
        $followersUrl = "https://api.github.com/users/$githubUsername/followers?per_page=100"
        $followers = Invoke-RestMethod -Uri $followersUrl -Headers @{ Authorization = "token $token" }

        $followingUrl = "https://api.github.com/users/$githubUsername/following?per_page=100"
        $following = Invoke-RestMethod -Uri $followingUrl -Headers @{ Authorization = "token $token" }

        while ($followers.Links.'next' -ne $null) {
            $nextPageUrl = $followers.Links.'next'
            $nextPage = Invoke-RestMethod -Uri $nextPageUrl -Headers @{ Authorization = "token $token" }
            $followers += $nextPage
        }

        while ($following.Links.'next' -ne $null) {
            $nextPageUrl = $following.Links.'next'
            $nextPage = Invoke-RestMethod -Uri $nextPageUrl -Headers @{ Authorization = "token $token" }
            $following += $nextPage
        }

        $notFollowedBack = $following | Where-Object { $_.login -notin $followers.login }
        $likelyFollowers = $followers | Where-Object { $_.followers -gt 100 -and $_.following -lt 100 }

        Write-Host "Following people who are likely to follow back:"
        if ($likelyFollowers.Count -eq 0) {
            Write-Host "No likely followers found."
        } else {
            $likelyFollowers | ForEach-Object {
                $userToFollow = $_.login
                Write-Host "Attempting to follow $userToFollow..."
                # Uncomment the following line to perform the follow action
                # Invoke-RestMethod -Uri "https://api.github.com/user/following/$userToFollow" -Method Put -Headers @{ Authorization = "token $token" }
                Write-Host "Followed $userToFollow"
            }
        }
    } catch {
        Write-Host "Error following likely followers: $_"
    }
}

Write-Host @"
  _____   ___   _      _       ___   __    __         ____  __ __  _     _____   ___ 
 |     | /   \ | |    | |     /   \ |  |__|  |       |    \|  |  || |   / ___/  /  _]
 |   __||     || |    | |    |     ||  |  |  | _____ |  o  )  |  || |  (   \_  /  [_ 
 |  |_  |  O  || |___ | |___ |  O  ||  |  |  ||     ||   _/|  |  || |___\__  ||    _]
 |   _] |     ||     ||     ||     ||  `  '  ||_____||  |  |  :  ||     /  \ ||   [_ 
 |  |   |     ||     ||     ||     | \      /        |  |  |     ||     \    ||     |
 |__|    \___/ |_____||_____| \___/   \_/\_/         |__|   \__,_||_____|\___||_____|
"@ -ForegroundColor Green

Write-Host "FollowPulse - GitHub Relationship Manager"
Write-Host "1. Check Followers and Following"
Write-Host "2. List People Not Following You Back"
Write-Host "3. Unfollow Those Not Following You Back"
Write-Host "4. Follow People Likely to Follow Back"
$choice = Read-Host "Enter your choice (1-4):"

$githubUsername = Read-Host "Enter your GitHub username:"
$token = Read-Host "Enter your GitHub personal access token:"

switch ($choice) {
    1 { Get-GitHubRelationships -githubUsername $githubUsername -token $token }
    2 { Get-GitHubRelationships -githubUsername $githubUsername -token $token }
    3 { Unfollow-NonFollowers -githubUsername $githubUsername -token $token }
    4 { Follow-LikelyFollowers -githubUsername $githubUsername -token $token }
    default { Write-Host "Invalid choice. Exiting." }
}
