#!/bin/bash

# Function to display colored output
function print_color {
    case $2 in
        "success") echo -e "\e[32m$1\e[0m";;
        "error") echo -e "\e[31m$1\e[0m";;
        *) echo $1;;
    esac
}

# Function to fetch GitHub followers with pagination
function get_followers {
    username=$1
    token=$2
    page=1
    followers=""

    while true; do
        data=$(curl -s -H "Authorization: token $token" "https://api.github.com/users/$username/followers?page=$page")
        page_followers=$(echo "$data" | jq -r '.[].login')

        if [ -z "$page_followers" ]; then
            break
        fi

        followers="$followers$page_followers "
        ((page++))
    done

    echo "$followers"
}

# Function to fetch GitHub users you follow with pagination
function get_following {
    username=$1
    token=$2
    page=1
    following=""

    while true; do
        data=$(curl -s -H "Authorization: token $token" "https://api.github.com/users/$username/following?page=$page")
        page_following=$(echo "$data" | jq -r '.[].login')

        if [ -z "$page_following" ]; then
            break
        fi

        following="$following$page_following "
        ((page++))
    done

    echo "$following"
}

# Function to unfollow users who don't follow back
function unfollow_non_followers {
    username=$1
    token=$2

    followers=$(get_followers "$username" "$token")
    following=$(get_following "$username" "$token")

    non_followers=$(comm -23 <(echo "$following" | tr ' ' '\n' | sort) <(echo "$followers" | sort))

    if [ -z "$non_followers" ]; then
        print_color "You follow everyone who follows you. No one to unfollow!" "success"
    else
        for user in $non_followers; do
            response=$(curl -s -X DELETE -H "Authorization: token $token" "https://api.github.com/user/following/$user")
            
            if [ "$(echo "$response" | jq -r '.message')" == "Not Found" ]; then
                print_color "Failed to unfollow $user. User not found or already unfollowed." "error"
            elif [ -z "$(echo "$response" | jq -r '.message')" ]; then
                print_color "Successfully unfollowed $user." "success"
            else
                print_color "Error unfollowing $user. $(echo "$response" | jq -r '.message')" "error"
            fi
        done
    fi
}

# Function to display users you follow but who don't follow you back
function display_non_followers {
    username=$1
    token=$2

    followers=$(get_followers "$username" "$token")
    following=$(get_following "$username" "$token")

    non_followers=$(comm -23 <(echo "$following" | tr ' ' '\n' | sort) <(echo "$followers" | sort))

    if [ -z "$non_followers" ]; then
        print_color "You follow everyone who follows you. No one is left out!" "success"
    else
        echo -e "\n\e[36mUsers You Follow But Don't Follow You Back:\e[0m"
        echo "$non_followers"
    fi
}

# Function to display users you are following but who don't follow you back
function display_non_following_back {
    username=$1
    token=$2

    followers=$(get_followers "$username" "$token")
    following=$(get_following "$username" "$token")

    non_following_back=$(comm -23 <(echo "$followers" | tr ' ' '\n' | sort) <(echo "$following" | sort))

    if [ -z "$non_following_back" ]; then
        print_color "Everyone you follow is also following you back!" "success"
    else
        echo -e "\n\e[36mUsers You Follow But Who Don't Follow You Back:\e[0m"
        echo "$non_following_back"
    fi
}

# Main script
clear
echo -e "\e[34mGitHub Follower Manager\e[0m"

read -p "Enter your GitHub username: " username
read -s -p "Enter your GitHub token: " token

while true; do
    clear
    echo -e "\e[34mGitHub Follower Manager\e[0m"

    echo -e "\e[33m1. Show GitHub Followers\e[0m"
    echo -e "\e[33m2. Show Users You Follow\e[0m"
    echo -e "\e[33m3. Unfollow Users Who Don't Follow Back\e[0m"
    echo -e "\e[33m4. Show Users You Follow But Don't Follow You Back\e[0m"
    echo -e "\e[33m5. Show Users You Follow But Who Don't Follow You Back\e[0m"
    echo -e "\e[33m6. Exit\e[0m"

    read -p "Select an option (1/2/3/4/5/6): " choice

    case $choice in
        1)
            echo -e "\n\e[36mGitHub Followers:\e[0m"
            get_followers "$username" "$token"
            ;;
        2)
            echo -e "\n\e[36mUsers You Follow:\e[0m"
            get_following "$username" "$token"
            ;;
        3)
            unfollow_non_followers "$username" "$token"
            ;;
        4)
            display_non_followers "$username" "$token"
            ;;
        5)
            display_non_following_back "$username" "$token"
            ;;
        6)
            print_color "Exiting. Have a great day!" "success"
            exit 0
            ;;
        *)
            print_color "Invalid option. Please select a valid option." "error"
            sleep 2
            ;;
    esac

    read -p "Press enter to continue..."
done
