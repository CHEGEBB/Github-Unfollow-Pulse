import requests
from tabulate import tabulate
import random

def get_random_users(token, count=5):
    # Fetch a list of random GitHub users
    endpoint = "https://api.github.com/users"
    headers = {"Authorization": f"token {token}"}
    params = {"since": random.randint(1, 500000)}

    users_response = requests.get(endpoint, headers=headers, params=params)

    if users_response.status_code == 200:
        users_data = users_response.json()
        return random.sample(users_data, min(count, len(users_data)))
    else:
        print(f"Error fetching random users: {users_response.status_code}")
        return []

def track_github_activity(username, token):
    base_url = "https://api.github.com/users/"
    user_url = base_url + username
    repos_url = user_url + "/repos"
    events_url = user_url + "/events"

    headers = {"Authorization": f"token {token}"}

    # Fetch user information
    user_response = requests.get(user_url, headers=headers).json()
    print(f"\nGitHub Activity for User: {username}")
    print(f"Name: {user_response['name']}")
    print(f"Followers: {user_response['followers']} | Following: {user_response['following']}")
    print(f"Public Repositories: {user_response['public_repos']} | Public Gists: {user_response['public_gists']}")

    # Fetch repositories
    repos_response = requests.get(repos_url, headers=headers).json()
    print("\nRepositories created:")
    for repo in repos_response:
        print(f"- {repo['name']}")

    # Fetch events (commits, issues, etc.)
    events_response = requests.get(events_url, headers=headers).json()
    print("\nRecent Events:")
    for event in events_response:
        print(f"- {event['type']} on {event['repo']['name']}")

def main():
    # Get user input for GitHub username and personal access token
    github_username = input("Enter your GitHub username: ")
    github_token = input("Enter your GitHub personal access token: ")

    # Fetch random GitHub users
    random_users = get_random_users(github_token)

    # Display users and their activity
    for user in random_users:
        track_github_activity(user['login'], github_token)
        print("\n" + "-" * 50)

if __name__ == "__main__":
    main()

