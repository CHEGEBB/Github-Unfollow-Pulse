import requests
import time
from colorama import Fore, Style

# Install colorama using: pip install colorama

def get_all_pages(url, token):
    result = []
    while url:
        response = requests.get(url, headers={"Authorization": f"token {token}"})
        if response.status_code != 200:
            raise Exception(f"Failed to retrieve data from {url}. Status code: {response.status_code}")
        result += response.json()
        url = response.links.get("next", {}).get("url")
    return result

def loading_animation(message, delay=0.1):
    animation = "|/-\\"
    for i in range(10):
        time.sleep(delay)
        print(f"\r{message} {animation[i % len(animation)]}", end="", flush=True)
    print("\r", end="", flush=True)

def colored_print(message, color):
    print(color + message + Style.RESET_ALL)

def check_github_relationships(username, token):
    try:
        loading_animation("Loading followers and following...")
        followers_url = f"https://api.github.com/users/{username}/followers?per_page=100"
        followers = get_all_pages(followers_url, token)

        following_url = f"https://api.github.com/users/{username}/following?per_page=100"
        following = get_all_pages(following_url, token)

        not_followed_back = [user for user in following if user["login"] not in [follower["login"] for follower in followers]]

        print("\nPeople you follow but who don't follow you back:")
        for user in not_followed_back:
            colored_print(user["login"], Fore.RED)
        
        return not_followed_back
    except Exception as e:
        print(f"Error checking GitHub relationships: {e}")
        return []

def unfollow_non_followers(username, token, not_followed_back):
    try:
        print("\nUnfollowing people who don't follow you back:")
        if not not_followed_back:
            colored_print("No one to unfollow.", Fore.GREEN)
        else:
            for user in not_followed_back:
                user_to_unfollow = user["login"]
                loading_animation(f"Attempting to unfollow {user_to_unfollow}...")
                # Uncomment the following line to perform the unfollow action
                requests.delete(f"https://api.github.com/user/following/{user_to_unfollow}", headers={"Authorization": f"token {token}"})
                print(f"Unfollowed {user_to_unfollow}")
    except Exception as e:
        print(f"Error unfollowing non-followers: {e}")

def follow_likely_followers(username, token):
    try:
        loading_animation("Checking likely followers...")
        followers_url = f"https://api.github.com/users/{username}/followers?per_page=100"
        followers = get_all_pages(followers_url, token)

        following_url = f"https://api.github.com/users/{username}/following?per_page=100"
        following = get_all_pages(following_url, token)

        not_followed_back = [user for user in following if user["login"] not in [follower["login"] for follower in followers]]
        likely_followers = [follower for follower in followers if follower["followers"] > 100 and follower["following"] < 100]

        print("\nFollowing people who are likely to follow back:")
        if not likely_followers:
            colored_print("No likely followers found.", Fore.GREEN)
        else:
            for user in likely_followers:
                user_to_follow = user["login"]
                loading_animation(f"Attempting to follow {user_to_follow}...")
                # Uncomment the following line to perform the follow action
                requests.put(f"https://api.github.com/user/following/{user_to_follow}", headers={"Authorization": f"token {token}"})
                print(f"Followed {user_to_follow}")
    except Exception as e:
        print(f"Error following likely followers: {e}")

# Main loop
while True:
    print("\nFollowPulse - GitHub Relationship Manager")
    print("1. Check Followers and Following")
    print("2. List People Not Following You Back")
    print("3. Unfollow Those Not Following You Back")
    print("4. Follow People Likely to Follow Back")
    print("5. Exit")

    choice = input("Enter your choice (1-5): ")

    if choice == "1":
        github_username = input("Enter your GitHub username: ")
        token = input("Enter your GitHub personal access token: ")
        check_github_relationships(github_username, token)
    elif choice == "2":
        github_username = input("Enter your GitHub username: ")
        token = input("Enter your GitHub personal access token: ")
        not_followed_back = check_github_relationships(github_username, token)
    elif choice == "3":
        github_username = input("Enter your GitHub username: ")
        token = input("Enter your GitHub personal access token: ")
        unfollow_non_followers(github_username, token, not_followed_back)
    elif choice == "4":
        github_username = input("Enter your GitHub username: ")
        token = input("Enter your GitHub personal access token: ")
        follow_likely_followers(github_username, token)
    elif choice == "5":
        print("Exiting. Goodbye!")
        break
    else:
        colored_print("Invalid choice. Please enter a number from 1 to 5.", Fore.RED)
