# Ideas

## Short-term

- Rename the Views to something more clear

### Frontend

- Change initial BTC logo with a gif or something else that is not just Bitcoin
- Remove a category in the separated if there are no items on that list
- When no items are present, the system displays an empty content view
- When I have selected something to be removed, then I go out of the menu of editing and then I go back to the menu. I do not want the items to continue to be selected. 
- Make the last update date of the fiat currencies to work. 

### Backend

- Add unit tests
	- For services
	- For SwiftUI
- Don't update the fiat currencies every day but only once per day. 

## Long-term

### Frontend

- On the very beginning, ask what to include (crypto or/and currencies)
- Add max amount of items that can be favourited 
- Add option for purchase
	- Unlocks higher refresh rate
	- More cryptos
	- No ads
- Ads
- Add certain information about each crypto when they press on them
- Better keyboard for the numbers (and add + - * / and options like this)
- Create a widget that show the value of a currency based on the main currency (USD by default?)

### Backend

- Fix the error: BUG IN CLIENT OF CLOUDKIT: CloudKit push notifications require the 'remote-notification' background mode in your info plist.
By doing that, I can fetch data from cloudkit automatically, with a subscription, without the need for manual fetching with a timer.
- Add data in many small batches, not in two big ones
- Find what the colour themes work
