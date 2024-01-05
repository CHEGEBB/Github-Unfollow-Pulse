#!/bin/bash

function get_all_pages() {
    local url=$1
    local token=$2
    local result=()

    while [ "$url" ]; do
        response=$(curl -s -H "Authorization: token $token" "$url")
        result+=($(echo "$response" | jq -c '.[]'))
        url=$(echo "$response" | jq -r '.[0].next // empty')
    done

    echo "${result[@]}"
}

function loading_animation() {
    local message=$1
    local delay=0.1
    local animation="|/-\\"

    for ((i = 0; i < 10; i++)); do
        sleep $delay
        printf "\r%s %s" "$message" "${animation:i % 4:1}"
    done

    printf "\r"
}

function colored_print() {
    local message=$1
    local color=$2
    echo -e "$color$message\e[0m"
}

function check_github_relationships() {
    local username=$1
    local token=$2

    loading_animation "Loading followers and following..."
    followers=$(get_all_pages "https://api.github.com/users/$username/followers?per_page=100" "$token")
    following=$(get_all_pages "https://api.github.com/users/$username/following?per_page=100" "$token")

    not_followed_back=()
    for user in $following; do
        login=$(echo "$user" | jq -r '.login')
        if [[ ! " ${followers[@]} " =~ " $login " ]]; then
            not_followed_back+=("$login")
        fi
    done

    echo -e "\nPeople you follow but who don't follow you back:"
    for user in "${not_followed_back[@]}"; do
        colored_print "$user" "\e[91m"  # Red color
    done

    echo "${not_followed_back[@]}"
}

function unfollow_non_followers() {
    local username=$1
    local token=$2
    local not_followed_back=("$@")

    echo -e "\nUnfollowing people who don't follow you back:"
    if [ ${#not_followed_back[@]} -eq 0 ]; then
        colored_print "No one to unfollow." "\e[32m"  # Green color
    else
        for user in "${not_followed_back[@]}"; do
            loading_animation "Attempting to unfollow $user..."
             curl -X DELETE -s -H "Authorization: token $token" "https://api.github.com/user/following/$user"
            echo -e "Unfollowed $user"
        done
    fi
}

function follow_likely_followers() {
    local username=$1
    local token=$2

    loading_animation "Checking likely followers..."
    followers=$(get_all_pages "https://api.github.com/users/$username/followers?per_page=100" "$token")
    following=$(get_all_pages "https://api.github.com/users/$username/following?per_page=100" "$token")

    not_followed_back=()
    likely_followers=()
    for user in $following; do
        login=$(echo "$user" | jq -r '.login')
        if [[ ! " ${followers[@]} " =~ " $login " ]]; then
            not_followed_back+=("$login")
            followers_count=$(echo "$user" | jq -r '.followers')
            following_count=$(echo "$user" | jq -r '.following')
            if [ "$followers_count" -gt 100 ] && [ "$following_count" -lt 100 ]; then
                likely_followers+=("$login")
            fi
        fi
    done

    echo -e "\nFollowing people who are likely to follow back:"
    if [ ${#likely_followers[@]} -eq 0 ]; then
        colored_print "No likely followers found." "\e[32m"  # Green color
    else
        for user in "${likely_followers[@]}"; do
            loading_animation "Attempting to follow $user..."
            # Uncomment the following line to perform the follow action
             curl -X PUT -s -H "Authorization: token $token" "https://api.github.com/user/following/$user"
            echo -e "Followed $user"
        done
    fi
}

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
    "1")
        read -p "Enter your GitHub username: " github_username
        read -p "Enter your GitHub personal access token: " token
        check_github_relationships "$github_username" "$token"
        ;;
    "2")
        read -p "Enter your GitHub username: " github_username
        read -p "Enter your GitHub personal access token: " token
        not_followed_back=($(check_github_relationships "$github_username" "$token"))
        ;;
    "3")
        read -p "Enter your GitHub username: " github_username
        read -p "Enter your GitHub personal access token: " token
        unfollow_non_followers "$github_username" "$token" "${not_followed_back[@]}"
        ;;
    "4")
        read -p "Enter your GitHub username: " github_username
        read -p "Enter your GitHub personal access token: " token
        follow_likely_followers "$github_username" "$token"
        ;;
    "5")
        echo "Exiting. Goodbye!"
        break
        ;;
    *)
        echo -e "\e[91mInvalid choice. Please enter a number from 1 to 5.\e[0m"
        ;;
    esac
done
