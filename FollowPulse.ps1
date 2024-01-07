<<<<<<< HEAD
#!/bin/bash

function get_all_pages {
    local url=$1
    local token=$2
    local result=()
    
    while [ "$url" ]; do
        response=$(curl -s -H "Authorization: token $token" "$url")
        if [ $? -ne 0 ]; then
            echo "Failed to retrieve data from $url. Exiting."
            exit 1
        fi
=======
function Check-GitHubRelationships {
    param (
        [string]$githubUsername,
        [string]$token
    )
>>>>>>> a3da973f04d584576597d92651f4d8df78825d34

        # Check for errors in the JSON response
        if [[ "$response" == *"message"* ]]; then
            echo "Error in JSON response: $response. Exiting."
            exit 1
        fi

<<<<<<< HEAD
        result+=( "$response" )
        url=$(echo "$response" | grep -oP '"next": "\K[^"]+' | sed 's/\\//g')
    done
    
    echo "${result[@]}"
=======
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
>>>>>>> a3da973f04d584576597d92651f4d8df78825d34
}

function loading_animation {
    local message=$1
    local delay=0.1
    local animation="|/-\\"

<<<<<<< HEAD
    for ((i = 0; i < 10; i++)); do
        sleep $delay
        printf "\r%s %s" "$message" "${animation:i % 4:1}"
    done
    printf "\r"
=======
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
>>>>>>> a3da973f04d584576597d92651f4d8df78825d34
}

function colored_print {
    local message=$1
    local color=$2

<<<<<<< HEAD
    echo -e "${color}${message}\033[0m"
}

function check_github_relationships {
    local username=$1
    local token=$2

    loading_animation "Loading followers and following..."
    
    followers_url="https://api.github.com/users/$username/followers?per_page=100"
    followers=( $(get_all_pages "$followers_url" "$token") )

    following_url="https://api.github.com/users/$username/following?per_page=100"
    following=( $(get_all_pages "$following_url" "$token") )

    not_followed_back=()
    for user in "${following[@]}"; do
        login=$(echo "$user" | grep -oP '"login": "\K[^"]+')
        if ! grep -q "\"login\": \"$login\"" <<< "${followers[@]}"; then
            not_followed_back+=( "$login" )
        fi
    done

    echo -e "\nPeople you follow but who don't follow you back:"
    for user in "${not_followed_back[@]}"; do
        colored_print "$user" "\033[91m"
    done

    echo "${not_followed_back[@]}"
=======
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
    1 { Check-GitHubRelationships -githubUsername $githubUsername -token $token }
    2 { Check-GitHubRelationships -githubUsername $githubUsername -token $token }
    3 { Unfollow-NonFollowers -githubUsername $githubUsername -token $token }
    4 { Follow-LikelyFollowers -githubUsername $githubUsername -token $token }
    default { Write-Host "Invalid choice. Exiting." }
>>>>>>> a3da973f04d584576597d92651f4d8df78825d34
}

function unfollow_non_followers {
    local username=$1
    local token=$2
    local not_followed_back=("${!3}")

    echo -e "\nUnfollowing people who don't follow you back:"
    if [ ${#not_followed_back[@]} -eq 0 ]; then
        colored_print "No one to unfollow." "\033[92m"
    else
        for user in "${not_followed_back[@]}"; do
            loading_animation "Attempting to unfollow $user..."
            # Uncomment the following line to perform the unfollow action
             curl -X DELETE -H "Authorization: token $token" "https://api.github.com/user/following/$user"
            echo -e "\nUnfollowed $user"
        done
    fi
}

function follow_likely_followers {
    local username=$1
    local token=$2

    loading_animation "Checking likely followers..."

    followers_url="https://api.github.com/users/$username/followers?per_page=100"
    followers=( $(get_all_pages "$followers_url" "$token") )

    following_url="https://api.github.com/users/$username/following?per_page=100"
    following=( $(get_all_pages "$following_url" "$token") )

    not_followed_back=()
    for user in "${following[@]}"; do
        login=$(echo "$user" | grep -oP '"login": "\K[^"]+')
        if ! grep -q "\"login\": \"$login\"" <<< "${followers[@]}"; then
            not_followed_back+=( "$login" )
        fi
    done

    likely_followers=()
    for user in "${followers[@]}"; do
        followers_count=$(echo "$user" | grep -oP '"followers": \K[^,]+')
        following_count=$(echo "$user" | grep -oP '"following": \K[^,]+')
        if [ "$followers_count" -gt 100 ] && [ "$following_count" -lt 100 ]; then
            likely_followers+=( "$user" )
        fi
    done

    echo -e "\nFollowing people who are likely to follow back:"
    if [ ${#likely_followers[@]} -eq 0 ]; then
        colored_print "No likely followers found." "\033[92m"
    else
        for user in "${likely_followers[@]}"; do
            login=$(echo "$user" | grep -oP '"login": "\K[^"]+')
            loading_animation "Attempting to follow $login..."
            # Uncomment the following line to perform the follow action
             curl -X PUT -H "Authorization: token $token" "https://api.github.com/user/following/$login"
            echo -e "\nFollowed $login"
        done
    fi
}

# ASCII art
echo -e "\033[1m"
cat << "EOF"
  _____   ___   _      _       ___   __    __         ____  __ __  _     _____   ___ 
 |     | /   \ | |    | |     /   \ |  |__|  |       |    \|  |  || |   / ___/  /  _]
 |   __||     || |    | |    |     ||  |  |  | _____ |  o  )  |  || |  (   \_  /  [_ 
 |  |_  |  O  || |___ | |___ |  O  ||  |  |  ||     ||   _/|  |  || |___\__  ||    _]
 |   _] |     ||     ||     ||     ||  `  '  ||_____||  |  |  :  ||     /  \ ||   [_ 
 |  |   |     ||     ||     ||     | \      /        |  |  |     ||     \    ||     |
 |__|    \___/ |_____||_____| \___/   \_/\_/         |__|   \__,_||_____|\___||_____|
                                                                                    
EOF
echo -e "\033[0m"

# Main loop
while true; do
    echo -e "\nFollowPulse - GitHub Relationship Manager"
    echo "1. Check Followers and Following"
    echo "2. List People Not Following You Back"
    echo "3. Unfollow Those Not Following You Back"
    echo "4. Follow People Likely to Follow Back"
    echo "5. Exit"

    read -p "Enter your choice (1-5): " choice

    case $choice in
        1)
            read -p "Enter your GitHub username: " github_username
            read -p "Enter your GitHub personal access token: " token
            check_github_relationships "$github_username" "$token"
            ;;
        2)
            read -p "Enter your GitHub username: " github_username
            read -p "Enter your GitHub personal access token: " token
            not_followed_back=($(check_github_relationships "$github_username" "$token"))
            ;;
        3)
            read -p "Enter your GitHub username: " github_username
            read -p "Enter your GitHub personal access token: " token
            unfollow_non_followers "$github_username" "$token" not_followed_back
            ;;
        4)
            read -p "Enter your GitHub username: " github_username
            read -p "Enter your GitHub personal access token: " token
            follow_likely_followers "$github_username" "$token"
            ;;
        5)
            echo "Exiting. Goodbye!"
            exit 0
            ;;
        *)
            colored_print "Invalid choice. Please enter a number from 1 to 5." "\033[91m"
            ;;
    esac
done
