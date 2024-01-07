#!/bin/bash

ui() {
    echo "Welcome to the Github FollowPulse"
    echo "1. Follow users who are likely to follow back"
    echo "2. List followers who are likely to follow back"
    echo "3. List mutual connections"
    echo "4. List random users based on location"
    echo "5. Exit"
    read -p "Enter your choice: " choice
    echo $choice
}

animated_welcome() {
    welcome_message="Welcome to the Github FollowPulse"
    for ((i=0; i<${#welcome_message}; i++)); do
        echo -n "${welcome_message:$i:1}"
        sleep 0.05
    done
    echo -e "\nWritten by CHEGEBB\n"
}

get_username() {
    read -p "Enter your GitHub username: " username
    echo $username
}

get_token() {
    read -p "Enter your GitHub token: " token
    echo $token
}

get_followers_info() {
    local username=$1
    local token=$2
    local followers_url="https://api.github.com/users/${username}/followers?per_page=100"
    local followers_info=()
    local followers_data=$(get_all_pages "${followers_url}" "${token}")

    for follower in $(echo "${followers_data}" | jq -c '.[]'); do
        local follower_info=$(get_user_info "$(echo "${follower}" | jq -r '.login')" "${token}")
        followers_info+=("${follower_info}")
    done

    echo "${followers_info[@]}"
}

get_user_info() {
    local username=$1
    local token=$2
    local user_url="https://api.github.com/users/${username}"
    local response=$(curl -s "${user_url}" -H "Authorization: token ${token}")

    if [ "$(echo "${response}" | jq -r '.message')" == "Not Found" ]; then
        echo "{}"
    else
        echo "${response}"
    fi
}

get_followers() {
    local username=$1
    local token=$2
    local followers_url="https://api.github.com/users/${username}/followers?per_page=100"
    local followers=$(get_all_pages "${followers_url}" "${token}")
    echo "${followers}"
}

get_following() {
    local username=$1
    local token=$2
    local following_url="https://api.github.com/users/${username}/following?per_page=100"
    local following=$(get_all_pages "${following_url}" "${token}")
    echo "${following}"
}

list_mutual_connections() {
    local username=$1
    local token=$2
    local followers=$(get_followers "${username}" "${token}")
    local following=$(get_following "${username}" "${token}")
    local mutual_connections=()
    echo -e "\nListing mutual connections:"

    for user in ${followers}; do
        if [[ "${following}" == *"${user}"* ]]; then
            local user_to_follow=$(echo "${user}" | jq -r '.login')
            echo "${user_to_follow}"
            mutual_connections+=("${user_to_follow}")
        fi
    done

    if [ ${#mutual_connections[@]} -eq 0 ]; then
        colored_print "No mutual connections found." "${Fore_GREEN}"
    fi
}

follow_likely_followers() {
    local username=$1
    local token=$2
    local followers_info=$(get_followers_info "${username}" "${token}")
    local following=$(get_following "${username}" "${token}")
    local not_followed_back=()
    local likely_followers=()
    echo -e "\nFollowing people who are likely to follow back:"

    for user in ${following}; do
        local user_login=$(echo "${user}" | jq -r '.login')
        if ! [[ "${followers_info}" == *"${user_login}"* ]]; then
            not_followed_back+=("${user_login}")
        fi
    done

    for follower_info in ${followers_info}; do
        local followers=$(echo "${follower_info}" | jq -r '.followers // 0')
        local following_count=$(echo "${follower_info}" | jq -r '.following // 0')

        if [ "${followers}" -gt 100 ] && [ "${following_count}" -lt 100 ]; then
            local user_login=$(echo "${follower_info}" | jq -r '.login')
            likely_followers+=("${user_login}")
        fi
    done

    if [ ${#likely_followers[@]} -eq 0 ]; then
        colored_print "No likely followers found." "${Fore_GREEN}"
    fi

    for user_to_follow in ${likely_followers[@]}; do
        loading_animation "Attempting to follow ${user_to_follow}..."
        local response=$(curl -s -X PUT "https://api.github.com/user/following/${user_to_follow}" -H "Authorization: token ${token}")

        if [ "$(echo "${response}" | jq -r '.message')" == "Not Found" ]; then
            colored_print "Failed to follow ${user_to_follow}. Please check your credentials and try again." "${Fore_RED}"
        else
            colored_print "Followed ${user_to_follow}" "${Fore_GREEN}"
        fi
    done
}

list_likely_followers() {
    local username=$1
    local token=$2
    echo -e "\nListing random users:"
    local users=$(get_random_users "${token}")

    if [ -z "${users}" ]; then
        colored_print "No users found." "${Fore_GREEN}"
    fi

    for user in ${users}; do
        local user_to_follow=$(echo "${user}" | jq -r '.login')
        echo "${user_to_follow}"
    done
}

list_random_users_based_on_location() {
    read -p "Enter the username to check location: " user_to_check
    local user_info=$(get_user_info "${user_to_check}" "${token}")

    if [ "$(echo "${user_info}" | jq -r '.location')" != "null" ]; then
        local location=$(echo "${user_info}" | jq -r '.location')
        echo -e "\nListing random users based on location '${location}':"
        local users=$(get_users_based_on_location "${location}" "${token}")

        if [ -z "${users}" ]; then
            colored_print "No users found." "${Fore_GREEN}"
        fi

        for user in ${users}; do
            local user_to_follow=$(echo "${user}" | jq -r '.login')
            echo "${user_to_follow}"
        done
    else
        colored_print "Unable to fetch location for user ${user_to_check}." "${Fore_RED}"
    fi
}

get_random_users() {
    local token=$1
    local query="type:user"
    local users_url="https://api.github.com/search/users?q=${query}&order=desc"
    local users=$(get_all_pages "${users_url}" "${token}")
    echo "${users}"
}

get_users_based_on_location() {
    local location=$1
    local token=$2
    local query="location:${location} type:user"
    local users_url="https://api.github.com/search/users?q=${query}"
    local users=$(get_all_pages "${users_url}" "${token}")
    echo "${users}"
}

get_all_pages() {
    local url=$1
    local token=$2
    local response=$(curl -s "${url}" -H "Authorization: token ${token}")

    if [ "$(echo "${response}" | jq -r '.message')" == "Not Found" ]; then
        echo "{}"
    else
        echo "${response}"
    fi
}

colored_print() {
    local text=$1
    local color=$2
    echo -e "${color}${text}${Style_RESET_ALL}"
}

loading_animation() {
    local message=$1
    local animation="|/-\\"

    for ((i=0; i<100; i++)); do
        sleep 0.1
        echo -ne "\r${animation:$i%${#animation}:1} ${message}"
        printf "\033[0K"  # Clear the line
        printf "\033[1A"  # Move the cursor up
    done

    echo -e "\r${Style_RESET_ALL}"
}

clear_screen() {
    clear
}

exit_program() {
    echo "Exiting..."
    exit
}

run() {
    animated_welcome
    while true; do
        choice=$(ui)
        if [ "${choice}" == "1" ]; then
            clear_screen
            username=$(get_username)
            token=$(get_token)
            follow_likely_followers "${username}" "${token}"
        elif [ "${choice}" == "2" ]; then
            clear_screen
            username=$(get_username)
            token=$(get_token)
            list_likely_followers "${username}" "${token}"
        elif [ "${choice}" == "3" ]; then
            clear_screen
            username=$(get_username)
            token=$(get_token)
            list_mutual_connections "${username}" "${token}"
        elif [ "${choice}" == "4" ]; then
            clear_screen
            username=$(get_username)
            token=$(get_token)
            list_random_users_based_on_location "${username}" "${token}"
        elif [ "${choice}" == "5" ]; then
            exit_program
        else
            echo "Invalid choice"
        fi
    done
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    run
fi
