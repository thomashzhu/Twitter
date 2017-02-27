# Project 4 - Twitter

Twitter is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: 17 hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can sign in using OAuth login flow
- [X] User can view last 20 tweets from their home timeline
- [X] The current signed in user will be persisted across restarts
- [X] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- [X] Retweeting and favoriting should increment the retweet and favorite count.

The following **optional** features are implemented:

- [X] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
- [X] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [X] User can pull to refresh.

The following **additional** features are implemented:

- [X] User session is persisted even after they restarted the app
- [X] Keychain is used to store access token (instead of UserDefaults) for higher security
- [X] Launch screen is added
- [X] Customized the login button
- [X] User can log in and log out of his/her Twitter account
- [X] Added twitter logo onto the navigation bar
- [X] Twitter logo on the navigation bar shows fade-in animation
- [X] User can compose new tweets
- [X] Animations have been added to new/reply message window
- [X] Character limitation has been implemented for the new/reply functionality
- [X] User can constantly see how many characters he/she has left
- [X] Timestamp has been formatted in s/m/h/d/M/y
- [X] User can see who retweeted a tweet
- [X] User can reply to existing tweets
- [X] User can see if he/she retweeted or favorited a tweet even after restarting the app
- [X] Miscellaneous UI changes (blue navigation bar, white status bar, and no status bar in launch screen, etc.)
- [X] If a new tweet or a reply is successfully submitted, the tweet list will be automatically refreshed

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Authentication and authorization
2. ReSTful API

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/uUDiIO8.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

- Authentication and authorization
- Twitter API limitations
- Keychain access issue

## License

    Copyright [2017] [Thomas Zhu]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.



# Project 5 - Twitter

Time spent: **X** hours spent in total

## User Stories

The following **required** functionality is completed:

- [ ] Tweet Details Page: User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [ ] Profile page:
   - [ ] Contains the user header view
   - [ ] Contains a section with the users basic stats: # tweets, # following, # followers
- [ ] Home Timeline: Tapping on a user image should bring up that user's profile page
- [X] Compose Page: User can compose a new tweet by tapping on a compose button.

The following **optional** features are implemented:

- [X] When composing, you should have a countdown in the upper right for the tweet limit.
- [X] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [ ] Profile Page
   - [ ] Implement the paging view for the user description.
   - [ ] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [ ] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. 
2. 

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/file.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
