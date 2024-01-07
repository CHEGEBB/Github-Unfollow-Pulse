require 'octokit'
require 'tty-prompt'
require 'pastel'

Octokit.auto_paginate = true

prompt = TTY::Prompt.new
pastel = Pastel.new

def loading_animation(message, delay = 0.1)
  animation = "|/-\\"
  10.times do |i|
    sleep(delay)
    print "\r#{message} #{animation[i % 4]}"
    $stdout.flush
  end
  print "\r"
end

def colored_print(message, color)
  puts pastel.decorate(message, color)
end

def get_all_pages(client, method, *args)
  result = []
  response = client.send(method, *args)
  result += response
  while (response.rels[:next])
    response = response.rels[:next].get
    result += response.data
  end
  result
end

# ASCII art
puts <<-'ASCII'
  _____   ___   _      _       ___   __    __         ____  __ __  _     _____   ___ 
 |     | /   \ | |    | |     /   \ |  |__|  |       |    \|  |  || |   / ___/  /  _]
 |   __||     || |    | |    |     ||  |  |  | _____ |  o  )  |  || |  (   \_  /  [_ 
 |  |_  |  O  || |___ | |___ |  O  ||  |  |  ||     ||   _/|  |  || |___\__  ||    _]
 |   _] |     ||     ||     ||     ||  `  '  ||_____||  |  |  :  ||     /  \ ||   [_ 
 |  |   |     ||     ||     ||     | \      /        |  |  |     ||     \    ||     |
 |__|    \___/ |_____||_____| \___/   \_/\_/         |__|   \__,_||_____|\___||_____|
ASCII

def check_github_relationships(client, username)
  loading_animation('Loading followers and following...')
  followers = get_all_pages(client, :followers, username)
  following = get_all_pages(client, :following, username)

  not_followed_back = following.reject { |user| followers.any? { |follower| follower.login == user.login } }

  puts "\nPeople you follow but who don't follow you back:"
  not_followed_back.each do |user|
    colored_print(user.login, :red)
  end

  not_followed_back
end

def unfollow_non_followers(client, not_followed_back)
  puts "\nUnfollowing people who don't follow you back:"
  if not_followed_back.empty?
    colored_print('No one to unfollow.', :green)
  else
    not_followed_back.each do |user|
      loading_animation("Attempting to unfollow #{user.login}...")
      client.unfollow(user.login)
      puts "Unfollowed #{user.login}"
    end
  end
end

def follow_likely_followers(client, username)
  loading_animation('Checking likely followers...')
  followers = get_all_pages(client, :followers, username)
  following = get_all_pages(client, :following, username)

  not_followed_back = following.reject { |user| followers.any? { |follower| follower.login == user.login } }
  likely_followers = followers.select { |follower| follower.followers > 100 && follower.following < 100 }

  puts "\nFollowing people who are likely to follow back:"
  if likely_followers.empty?
    colored_print('No likely followers found.', :green)
  else
    likely_followers.each do |user|
      loading_animation("Attempting to follow #{user.login}...")
      client.follow(user.login)
      puts "Followed #{user.login}"
    end
  end
end

# Main loop
client = Octokit::Client.new(access_token: prompt.ask('Enter your GitHub personal access token: ', echo: false))
username = prompt.ask('Enter your GitHub username: ')

while true
  puts "\nFollowPulse - GitHub Relationship Manager"
  puts "1. Check Followers and Following"
  puts "2. List People Not Following You Back"
  puts "3. Unfollow Those Not Following You Back"
  puts "4. Follow People Likely to Follow Back"
  puts "5. Exit"

  choice = prompt.ask('Enter your choice (1-5): ')

  case choice
  when '1'
    check_github_relationships(client, username)
  when '2'
    not_followed_back = check_github_relationships(client, username)
  when '3'
    unfollow_non_followers(client, not_followed_back || [])
  when '4'
    follow_likely_followers(client, username)
  when '5'
    puts 'Exiting. Goodbye!'
    break
  else
    colored_print('Invalid choice. Please enter a number from 1 to 5.', :red)
  end
end
