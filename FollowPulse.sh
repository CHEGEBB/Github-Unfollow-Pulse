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

        # Check for errors in the JSON response
        if [[ "$response" == *"message"* ]]; then
            echo "Error in JSON response: $response. Exiting."
            exit 1
        fi

        result+=( "$response" )
        url=$(echo "$response" | grep -oP '"next": "\K[^"]+' | sed 's/\\//g')
    done
    
    echo "${result[@]}"
}

function loading_animation {
    local message=$1
    local delay=0.1
    local animation="|/-\\"

    for ((i = 0; i < 10; i++)); do
        sleep $delay
        printf "\r%s %s" "$message" "${animation:i % 4:1}"
    done
    printf "\r"
}

function colored_print {
    local message=$1
    local color=$2

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
