import json
from github import Github

def get_unfollowers(github_instance, username):
    followers = github_instance.get_user(username).get_followers()
    following = github_instance.get_user(username).get_following()
    followers_set = set([follower.login for follower in followers])
    following_set = set([followee.login for followee in following])
    unfollowers = following_set - followers_set
    return list(unfollowers)

def unfollow_users(github_instance, users_to_unfollow):
    for user in users_to_unfollow:
        try:
            github_instance.get_user().remove_from_following(user)
            print("Unfollowed:", user)
        except Exception as e:
            print("Error unfollowing", user, ":", str(e))

def save_to_json(filename, data):
    with open(filename, 'w') as f:
        json.dump(data, f)

def load_from_json(filename):
    try:
        with open(filename, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return []

def main():
    # GitHub credentials
    token = input("Enter your GitHub personal access token: ")
    username = input("Enter your GitHub username: ")

    # Initialize PyGithub instance
    github_instance = Github(token)

    # Get unfollowers
    unfollowers = get_unfollowers(github_instance, username)
    print("People who don't follow you back:", unfollowers)

    # Save unfollowers to JSON file
    save_to_json("unfollowers.json", unfollowers)

    # Load unfollowers from JSON file
    unfollowers_from_file = load_from_json("unfollowers.json")

    # Unfollow unfollowers
    if unfollowers_from_file:
        unfollow_users(github_instance, unfollowers_from_file)
    else:
        print("No unfollowers found in the JSON file.")

if __name__ == "__main__":
    main()
