import os
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

def create_markdown_file(filename, unfollowers):
    with open(filename, 'w') as f:
        f.write("## List of Unfollowers\n")
        for user in unfollowers:
            f.write(f"```bash\n{user}\n```\n")

def main():
    # GitHub credentials
    token = input("Enter your GitHub personal access token: ")
    username = input("Enter your GitHub username: ")

    # Initialize PyGithub instance
    github_instance = Github(token)

    # Check if JSON file exists
    json_filename = "unfollowers.json"
    if os.path.exists(json_filename):
        print("JSON file found. Loading data...")
        unfollowers_from_file = load_from_json(json_filename)
    else:
        print("JSON file not found. Finding unfollowers...")
        # Get unfollowers
        unfollowers_from_file = get_unfollowers(github_instance, username)
        # Save unfollowers to JSON file
        save_to_json(json_filename, unfollowers_from_file)
        print("Unfollowers saved to JSON file.")

    # Menu
    while True:
        print("\nMenu:")
        print("1. List people who don't follow back")
        print("2. Unfollow users who don't follow back")
        print("3. Create Markdown file with unfollowers list")
        print("4. Exit")

        choice = input("Enter your choice (1-4): ")

        if choice == "1":
            print("People who don't follow back:")
            for user in unfollowers_from_file:
                print(f"{user}")
        elif choice == "2":
            if unfollowers_from_file:
                unfollow_users(github_instance, unfollowers_from_file)
                unfollowers_from_file = []  # Empty the list after unfollowing
                save_to_json(json_filename, unfollowers_from_file)  # Update JSON file
            else:
                print("No unfollowers found in the JSON file.")
        elif choice == "3":
            if unfollowers_from_file:
                create_markdown_file("unfollowers.md", unfollowers_from_file)
                print("Markdown file 'unfollowers.md' created successfully.")
            else:
                print("No unfollowers found in the JSON file.")
        elif choice == "4":
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please enter a number from 1 to 4.")

if __name__ == "__main__":
    main()
