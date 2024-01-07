function ui {
    Write-Host "Welcome to the Github FollowPulse"
    Write-Host "1. Follow users who are likely to follow back"
    Write-Host "2. List followers who are likely to follow back"
    Write-Host "3. List mutual connections"
    Write-Host "4. List random users based on location"
    Write-Host "5. Exit"
    $choice = Read-Host "Enter your choice"
    return $choice
}

function animated_welcome {
    $welcomeMessage = "Welcome to the Github FollowPulse"
    $welcomeMessage.ToCharArray() | ForEach-Object {
        Write-Host -NoNewline $_
        Start-Sleep -Milliseconds 50
    }
    Write-Host "`nWritten by CHEGEBB"
}

function get_username {
    $username = Read-Host "Enter your GitHub username"
    return $username
}

function get_token {
    $token = Read-Host "Enter your GitHub token"
    return $token
}

function get_followers_info {
    param (
        [string]$username,
        [string]$token
    )

    $followersUrl = "https://api.github.com/users/$username/followers?per_page=100"
    $followersInfo = @()
    $followersData = get_all_pages $followersUrl $token

    foreach ($follower in $followersData) {
        $followerInfo = get_user_info $follower.login $token
        $followersInfo += $followerInfo
    }

    return $followersInfo
}

function get_user_info {
    param (
        [string]$username,
        [string]$token
    )

    $userUrl = "https://api.github.com/users/$username"
    $response = Invoke-RestMethod -Uri $userUrl -Headers @{ Authorization = "token $token" }

    if ($response.StatusCode -eq 200) {
        return $response
    } else {
        Write-Host "Error getting user info: $($response.message)"
        return @{}
    }
}

function get_followers {
    param (
        [string]$username,
        [string]$token
    )

    $followersUrl = "https://api.github.com/users/$username/followers?per_page=100"
    $followers = get_all_pages $followersUrl $token
    return $followers
}

function get_following {
    param (
        [string]$username,
        [string]$token
    )

    $followingUrl = "https://api.github.com/users/$username/following?per_page=100"
    $following = get_all_pages $followingUrl $token
    return $following
}

function list_mutual_connections {
    param (
        [string]$username,
        [string]$token
    )

    $followers = get_followers $username $token
    $following = get_following $username $token
    $mutualConnections = $followers | Where-Object { $_ -in $following }

    Write-Host "`nListing mutual connections:`n"

    if (-not $mutualConnections) {
        colored_print "No mutual connections found." "Green"
    } else {
        $mutualConnections | ForEach-Object {
            $userToFollow = $_.login
            Write-Host $userToFollow
        }
    }
}

function follow_likely_followers {
    param (
        [string]$username,
        [string]$token
    )

    $followersInfo = get_followers_info $username $token
    $following = get_following $username $token
    $notFollowedBack = $following | Where-Object { $_.login -notin $followersInfo.login }
    $likelyFollowers = $followersInfo | Where-Object { $_.followers -gt 100 -and $_.following -lt 100 }

    Write-Host "`nFollowing people who are likely to follow back:`n"

    if (-not $likelyFollowers) {
        colored_print "No likely followers found." "Green"
    } else {
        $likelyFollowers | ForEach-Object {
            $userToFollow = $_.login
            loading_animation "Attempting to follow $userToFollow..."
            $response = Invoke-RestMethod -Uri "https://api.github.com/user/following/$userToFollow" -Method Put -Headers @{ Authorization = "token $token" }

            if ($response.StatusCode -eq 204) {
                Write-Host "Followed $userToFollow"
            } else {
                colored_print "Failed to follow $userToFollow. Please check your credentials and try again." "Red"
            }
        }
    }
}

function list_likely_followers {
    param (
        [string]$username,
        [string]$token
    )

    Write-Host "`nListing random users:`n"
    $users = get_random_users $token

    if (-not $users) {
        colored_print "No users found." "Green"
    } else {
        $users | ForEach-Object {
            $userToFollow = $_.login
            Write-Host $userToFollow
        }
    }
}

function list_random_users_based_on_location {
    param (
        [string]$username,
        [string]$token
    )

    $userToCheck = Read-Host "Enter the username to check location"
    $userInfo = get_user_info $userToCheck $token
    
    if ($userInfo.location) {
        $location = $userInfo.location
        Write-Host "`nListing random users based on location '$location':`n"
        $users = get_users_based_on_location $location $token

        if (-not $users) {
            colored_print "No users found." "Green"
        } else {
            $users.items | ForEach-Object {
                $userToFollow = $_.login
                Write-Host $userToFollow
            }
        }
    } else {
        colored_print "Unable to fetch location for user $userToCheck." "Red"
    }
}

function get_random_users {
    param (
        [string]$token
    )

    $query = "type:user"
    $usersUrl = "https://api.github.com/search/users?q=$query&order=desc"
    $users = get_all_pages $usersUrl $token
    return $users.items
}

function get_users_based_on_location {
    param (
        [string]$location,
        [string]$token
    )

    $query = "location:$location type:user"
    $usersUrl = "https://api.github.com/search/users?q=$query"
    $users = get_all_pages $usersUrl $token
    return $users
}

function get_all_pages {
    param (
        [string]$url,
        [string]$token
    )

    try {
        $response = Invoke-RestMethod -Uri $url -Headers @{ Authorization = "token $token" }

        if ($response.StatusCode -eq 200) {
            return $response
        } else {
            Write-Host "Error getting all pages: $($response.message)"
            return @{}
        }
    } catch {
        Write-Host "Error getting all pages: $_"
        return @{}
    }
}

function colored_print {
    param (
        [string]$text,
        [string]$color
    )

    Write-Host $text -ForegroundColor $color
}

function loading_animation {
    param (
        [string]$message
    )

    $animation = "|/-\"
    for ($i = 0; $i -lt 100; $i++) {
        Start-Sleep -Milliseconds 100
        Write-Host -NoNewline ($animation[$i % $animation.Length] + " " + $message)
    }

    Write-Host "`r" -NoNewline
}

function clear_screen {
    Clear-Host
}

function exit_program {
    Write-Host "Exiting..."
    Exit
}

function run {
    animated_welcome
    while ($true) {
        $choice = ui
        switch ($choice) {
            "1" {
                clear_screen
                $username = get_username
                $token = get_token
                follow_likely_followers $username $token
            }
            "2" {
                clear_screen
                $username = get_username
                $token = get_token
                list_likely_followers $username $token
            }
            "3" {
                clear_screen
                $username = get_username
                $token = get_token
                list_mutual_connections $username $token
            }
            "4" {
                clear_screen
                $username = get_username
                $token = get_token
                list_random_users_based_on_location $username $token
            }
            "5" {
                exit_program
            }
            default {
                Write-Host "Invalid choice"
            }
        }
    }
}

run
