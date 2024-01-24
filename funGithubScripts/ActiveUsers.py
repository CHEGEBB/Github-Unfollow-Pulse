import requests

def get_potential_followers(username, token):
    base_url = "https://api.github.com/users/"
    user_url = base_url + username
    followers_url = user_url + "/followers"

    headers = {"Authorization": f"token {token}"}

    followers_response = requests.get(followers_url, headers=headers)
    followers_response.raise_for_status()
    followers_data = followers_response.json()

    potential_followers = [
        follower for follower in followers_data if
        is_active_user(follower['login'], token) and
        has_similar_interests(follower['login'], username, token) and
        has_favorable_follow_ratio(follower['login'], token) and
        is_engaged_user(follower['login'], token) and
        is_open_source_contributor(follower['login'], token)
    ]

    return potential_followers

def is_active_user(username, token):
    user_url = f"https://api.github.com/users/{username}"
    headers = {"Authorization": f"token {token}"}

    user_response = requests.get(user_url, headers=headers)
    user_response.raise_for_status()
    user_data = user_response.json()

    return 'pushed_at' in user_data and user_data['type'] == 'User'

def has_similar_interests(follower_username, target_username, token):
    follower_topics = get_user_topics(follower_username, token)
    target_topics = get_user_topics(target_username, token)
    
    return bool(set(follower_topics) & set(target_topics))

def has_favorable_follow_ratio(username, token):
    user_url = f"https://api.github.com/users/{username}"
    headers = {"Authorization": f"token {token}"}

    user_response = requests.get(user_url, headers=headers)
    user_response.raise_for_status()
    user_data = user_response.json()

    return user_data.get('followers', 0) >= 2 * user_data.get('following', 0)

def is_engaged_user(username, token):
    return True

def is_open_source_contributor(username, token):
    return True

def get_user_topics(username, token):
    base_url = f"https://api.github.com/users/{username}/repos"
    headers = {"Authorization": f"token {token}"}

    repos_response = requests.get(base_url, headers=headers)
    repos_response.raise_for_status()
    repos_data = repos_response.json()

    topics = set()
    for repo in repos_data:
        topics.update(repo.get("topics", []))

    return list(topics)

def main():
    github_username = input("Enter your GitHub username: ")
    github_token = input("Enter your GitHub personal access token: ")

    potential_followers = get_potential_followers(github_username, github_token)

    print("\nPotential Followers:")
    for follower in potential_followers:
        print(f"- {follower['login']}")

if __name__ == "__main__":
    main()

