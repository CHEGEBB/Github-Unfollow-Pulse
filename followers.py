import requests
import time
import sys
import os
from colorama import Fore, Style

def ui():
    print("\033c")  # Clear the screen
    animated_welcome()
    print("1. Follow users who are likely to follow back")
    print("2. List followers who are likely to follow back")
    print("3. List mutual connections")
    print("4. List random users based on location")
    print("5. Exit")
    choice = input("Enter your choice: ")
    return choice

def animated_welcome():
    welcome_message = "Welcome to the Github FollowPulse"
    for char in welcome_message:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(0.05)
    print("\nWritten by CHEGEBB\n")

def get_username():
    username = input("Enter your GitHub username: ")
    return username

def get_token():
    token = input("Enter your GitHub token: ")
    return token

def get_followers_info(username, token):
    followers_url = f"https://api.github.com/users/{username}/followers?per_page=100"
    followers_info = []
    followers_data = get_all_pages(followers_url, token)

    for follower in followers_data:
        follower_info = get_user_info(follower["login"], token)
        followers_info.append(follower_info)

    return followers_info

def get_user_info(username, token):
    user_url = f"https://api.github.com/users/{username}"
    response = requests.get(user_url, headers={"Authorization": f"token {token}"})
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error getting user info: {response.json().get('message', 'Unknown error')}")
        return {}

def get_following(username, token):
    following_url = f"https://api.github.com/users/{username}/following?per_page=100"
    following = get_all_pages(following_url, token)
    return following

def list_mutual_connections(username, token):
    followers = get_followers(username, token)
    following = get_following(username, token)
    mutual_connections = [user for user in followers if user in following]
    print("\nListing mutual connections:")

    if not mutual_connections:
        colored_print("No mutual connections found.", Fore.GREEN)
    else:
        for user in mutual_connections:
            user_to_follow = user["login"]
            print(user_to_follow)

def follow_likely_followers(username, token):
    followers_info = get_followers_info(username, token)
    following = get_following(username, token)
    not_followed_back = [user for user in following if user["login"] not in [follower["login"] for follower in followers_info]]
    likely_followers = [follower for follower in followers_info if follower.get("followers", 0) > 2 * follower.get("following", 0)]
    print("\nFollowing people who are likely to follow back:")

    if not likely_followers:
        colored_print("No likely followers found.", Fore.GREEN)
    else:
        for user in likely_followers:
            user_to_follow = user["login"]
            loading_animation(f"Following {user_to_follow}...")
            response = requests.put(f"https://api.github.com/user/following/{user_to_follow}", headers={"Authorization": f"token {token}"})
            if response.status_code == 204:
                print(f"Followed {user_to_follow}")
            else:
                colored_print(f"Failed to follow {user_to_follow}. Please check your credentials and try again.", Fore.RED)

def list_likely_followers(username, token):
    print("\nListing random users:")
    users = get_random_users(token)

    if not users:
        colored_print("No users found.", Fore.GREEN)
    else:
        for user in users:
            user_to_follow = user["login"]
            print(user_to_follow)

def list_random_users_based_on_location(username, token):
    user_to_check = input("Enter the username to check location: ")
    user_info = get_user_info(user_to_check, token)
    
    if "location" in user_info:
        location = user_info["location"]
        print(f"\nListing random users based on location '{location}':")
        users = get_users_based_on_location(location, token)
        
        if not users:
            colored_print("No users found.", Fore.GREEN)
        else:
            for user in users.get("items", []):
                user_to_follow = user["login"]
                print(user_to_follow)
    else:
        colored_print(f"Unable to fetch location for user {user_to_check}.", Fore.RED)

def get_random_users(token):
    query = "type:user"
    users_url = f"https://api.github.com/search/users?q={query}&order=desc"
    users = get_all_pages(users_url, token)
    return users.get("items", [])

def get_users_based_on_location(location, token):
    query = f"location:{location} type:user"
    users_url = f"https://api.github.com/search/users?q={query}"
    users = get_all_pages(users_url, token)
    return users

def get_all_pages(url, token):
    try:
        response = requests.get(url, headers={"Authorization": f"token {token}"})
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Error getting all pages: {response.json().get('message', 'Unknown error')}")
            return {}
    except Exception as e:
        print(f"Error getting all pages: {e}")
        return {}

def colored_print(text, color):
    print(f"{color}{text}{Style.RESET_ALL}")

def loading_animation(message):
    animation = "|/-\\"
    for i in range(100):
        time.sleep(0.05)
        sys.stdout.write("\r" + animation[i % len(animation)] + " " + message)
        sys.stdout.flush()
    print("\r", end="", flush=True)

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def exit_program():
    print("Exiting...")
    sys.exit()

def run():
    while True:
        choice = ui()
        if choice == "1":
            clear_screen()
            username = get_username()
            token = get_token()
            follow_likely_followers(username, token)
        elif choice == "2":
            clear_screen()
            username = get_username()
            token = get_token()
            list_likely_followers(username, token)
        elif choice == "3":
            clear_screen()
            username = get_username()
            token = get_token()
            list_mutual_connections(username, token)
        elif choice == "4":
            clear_screen()
            username = get_username()
            token = get_token()
            list_random_users_based_on_location(username, token)
        elif choice == "5":
            exit_program()
        else:
            print("Invalid choice")

if __name__ == "__main__":
    run()
