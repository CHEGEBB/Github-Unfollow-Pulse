function showLoading(buttonId) {
    const loadingElement = document.getElementById('loading');
    loadingElement.style.display = 'inline-block';

    // Add a class to highlight the clicked button
    document.getElementById(buttonId).classList.add('clicked');
}

function hideLoading() {
    const loadingElement = document.getElementById('loading');
    loadingElement.style.display = 'none';

    // Remove the highlight class from all buttons
    document.querySelectorAll('.clicked').forEach(btn => btn.classList.remove('clicked'));
}

function checkGitHubRelationships(username, token) {
    return new Promise((resolve, reject) => {
        fetch(`https://api.github.com/users/${username}/followers?per_page=100`, {
            headers: { 'Authorization': `token ${token}` }
        })
        .then(response => {
            if (!response.ok) {
                reject(`Failed to retrieve data. Status code: ${response.status}`);
            }
            return response.json();
        })
        .then(followers => {
            fetch(`https://api.github.com/users/${username}/following?per_page=100`, {
                headers: { 'Authorization': `token ${token}` }
            })
            .then(response => {
                if (!response.ok) {
                    reject(`Failed to retrieve data. Status code: ${response.status}`);
                }
                return response.json();
            })
            .then(following => {
                const notFollowedBack = following.filter(user => !followers.some(follower => follower.login === user.login));
                resolve(notFollowedBack);
            })
            .catch(error => reject(`Error checking GitHub relationships: ${error}`));
        })
        .catch(error => reject(`Error checking GitHub relationships: ${error}`));
    });
}

function unfollowNonFollowers() {
    showLoading('unfollowBtn');
    const username = document.getElementById('githubUsername').value;
    const token = document.getElementById('githubToken').value;

    fetch(`https://api.github.com/users/${username}/following?per_page=100`, {
        headers: { 'Authorization': `token ${token}` }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`Failed to retrieve data. Status code: ${response.status}`);
        }
        return response.json();
    })
    .then(following => {
        const promises = following.map(user => {
            return fetch(`https://api.github.com/user/following/${user.login}`, {
                method: 'DELETE',
                headers: { 'Authorization': `token ${token}` }
            })
            .then(response => {
                if (response.ok) {
                    return `Unfollowed ${user.login}`;
                } else {
                    return `Error unfollowing ${user.login}`;
                }
            });
        });

        Promise.all(promises)
            .then(results => {
                results.forEach(result => console.log(result));
            })
            .catch(error => console.error(`Error unfollowing non-followers: ${error}`))
            .finally(() => hideLoading());
    })
    .catch(error => {
        console.error(`Error unfollowing non-followers: ${error}`);
    })
    .finally(() => hideLoading());
}

function followLikelyFollowers() {
    showLoading('followBtn');
    const username = document.getElementById('githubUsername').value;
    const token = document.getElementById('githubToken').value;

    fetch(`https://api.github.com/users/${username}/followers?per_page=100`, {
        headers: { 'Authorization': `token ${token}` }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`Failed to retrieve data. Status code: ${response.status}`);
        }
        return response.json();
    })
    .then(followers => {
        const likelyFollowers = followers.filter(user => user.followers > 100 && user.following < 100);

        const promises = likelyFollowers.map(user => {
            return fetch(`https://api.github.com/user/following/${user.login}`, {
                method: 'PUT',
                headers: { 'Authorization': `token ${token}` }
            })
            .then(response => {
                if (response.ok) {
                    return `Followed ${user.login}`;
                } else {
                    return `Error following ${user.login}`;
                }
            });
        });

        Promise.all(promises)
            .then(results => {
                results.forEach(result => console.log(result));
            })
            .catch(error => console.error(`Error following likely followers: ${error}`))
            .finally(() => hideLoading());
    })
    .catch(error => {
        console.error(`Error following likely followers: ${error}`);
    })
    .finally(() => hideLoading());
}

function onCheckRelationships() {
    const githubUsername = document.getElementById('githubUsername').value;
    const token = document.getElementById('githubToken').value;
    showLoading('checkBtn');

    checkGitHubRelationships(githubUsername, token)
        .then(notFollowedBack => {
            displayResult(notFollowedBack);
        })
        .catch(error => {
            console.error(error);
        })
        .finally(() => hideLoading());
}

function displayResult(users) {
    const resultText = document.getElementById('resultText');
    resultText.value = ''; // Clear existing content

    if (users.length === 0) {
        resultText.value = 'No one is not following back.';
    } else {
        users.forEach(user => {
            resultText.value += `${user.login}\n`;
        });
    }
    
    // Animate the result display
    resultText.style.opacity = 0;
    resultText.style.transition = 'opacity 0.5s';
    setTimeout(() => {
        resultText.style.opacity = 1;
    }, 100);
}
