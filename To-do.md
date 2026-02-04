# Ideas

## Short-term

- Rename the Views to something more clear

### Frontend

- If name gets small, then remove it
- If symbol gets small, then remove it
- Change initial BTC logo with a gif or something else that is not just Bitcoin

### Backend

- Make logger work
    - Add more logs
- Add unit tests
	- For services
	- For SwiftUI

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
- When the user has a lot of time to enter the app, it goes back to the loading screen for some reason. Shouldn't the data stay in the ModelContext?
Maybe I use wrongly the updateAmounts? IDK, but I should find out
- Add data in many small batches, not in two big ones
- Put the last fetch (for crypto and fiat) in settings somehow
- Put the merged/separated in settings, not as button in the topbar
- Make sure I fetch all the data, all the time. If the user quits before I load all the data, then the data will never get fetched again, since this happens only in the first launch. 
- Find what the colour themes work
- FInd how Maria can use the gifs 

