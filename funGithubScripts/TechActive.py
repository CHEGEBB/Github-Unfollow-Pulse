import os
import requests
from tabulate import tabulate
from datetime import datetime

# An options UI for the user to choose from
def show_menu():
    print("=== GitHub User Checker ===")
    print("1. Check if a user is active on GitHub")
    print("2. Search random users on GitHub by name")
    print("3. Exit")

# Checks if the user is active on GitHub
def check_github(username, token):
    url = f"https://api.github.com/users/{username}/events"
    headers = {"Authorization": f"token {token}"}
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        if data:
            last_active = data[0]['created_at']
            last_active = datetime.strptime(last_active, "%Y-%m-%dT%H:%M:%SZ")
            current_time = datetime.utcnow()
            time_difference = current_time - last_active
            return time_difference.days == 0
    return False

# Displays the data in a table format
def display_data(data):
    headers = ["Username", "Active"]
    print(tabulate(data.items(), headers, tablefmt="grid"))

# Search random users on GitHub by name
def search_random_users_by_name():
    name = input("Enter the name to search for: ")
    token = input("Enter your GitHub API token: ")

    url = "https://api.github.com/users?since=0"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        filtered_data = [user for user in data if name.lower() in user['login'].lower()]
        data_dict = {}

        for user in filtered_data:
            username = user['login']
            active = check_github(username, token)
            data_dict[username] = "Active" if active else "Inactive"

        display_data(data_dict)
    else:
        print(f"Error fetching random GitHub users: {response.status_code}")

# Main function to run the program
def main():
    while True:
        show_menu()
        option = input("Select an option (1/2/3): ")

        if option == "1":
            username = input("Enter the GitHub username to check: ")
            token = input("Enter your GitHub API token: ")
            active = check_github(username, token)
            status = "Active" if active else "Inactive"
            print(f"User is {status} on GitHub.\n")
        elif option == "2":
            search_random_users_by_name()
        elif option == "3":
            print("Exiting...")
            break
        else:
            print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()

