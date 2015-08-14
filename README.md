<h1 align="center">
	<img src="http://i.imgur.com/1BcGiMe.png" alt="SGR-Overview">
</h1>

### Overview
SGR Overwatch reads raw messages from tote via the SGR Datafile and performs a variety of checks to ensure valid and complete information for each track.

By default it reads the tail end of the selected SGR-logfile every 4 mins. Typically TVG_TGP01 and NJ_TGP01
Assumes all races are over by 1:00 AM. If overnight wants to monitor Tote's file before that time; restart the application to use the current date (after midnight).
 
Track data is read and alerts WagerOps of any potential problems. Including:
- Missing willPay & probable Data
- Missing post times
- Missing RI messages
- Missing finisher / official flag
- Unexpected track codes
- Delayed post times


### Example Use
SGR Overview is left in auto-update mode on the wallboard. Track data is read and alerts WagerOps of any problems visually.

   Ignoring Tracks
In some cases Tote may stop sending messages for a specific track or send incomplete message. The track may have cancelled racing, been included in the SDL by accident, or had other issues that SGR Overview is reporting as a problem. If the problem is understood and acceptable; a track can be double clicked to have it marked as "ignore". Ignored tracks will still have comments on their problem; but be moved below normal tracks and colored a dark grey. Double clicking an ignored track will remove it from the ignored track list on the next update cycle. These tracks are saved in ...\Data\DB\[TodaysDate][…]IgnoredDB.json, a file that can be safely deleted.


### Settings
**Auto-Update:** User definable number of mins to refresh reading of SGR data. When set on the wallboard the is recommended to be set at 4-10 mins. Requires Checkmark to be active. On by default


### Warnings & Troubleshooting
Trying to adjust the column size on the wallboard typically results in freezing or crashing the application. Task manager may be required to force close it. WALLBOARD ISSUE


### Dev Brief
- ..\Data\SGR_Locations.txt is read for options.
- When a TGP is selected, the corresponding **log file** is read for information periodically. Tote is not queried or connected to directly.
- Information on each track is displayed and colored according to extrapolated information.
- Tracks will not be remembered between 11:00 PM and 5:00 AM.
- 

### Detailed Execution
The last 2000 lines for the selected SGR-logfile are read into memory. This is not network intensive. Copying the entire logfile; even under 50MB was.

Each line it iterated through a sorting algorithm that puts each track's messages together; extracting relevant information.
Logic is applied to the sorted tracks determining if they are about to hit post time; and if any track is in a warning or critical state. Coloring of each track is determined here

The GUI list is cleared and updated to the current status of each track

The sorted tracks are saved to a .json file to be re-loaded on the next update. This file can be deleted anytime safely.

| Required Message Types | Used For |
| ------------- | ----------- |
| ALL      | Track Code
Track Name|
| RI (Race Information)     | Current Race
Next Post Time     |
| PB (Feature Probables)     | Probable Type
Current Race     |
| RN (Scratched Runners)     | Total Races     |
| PS (Scratched Pools)     |      |
| RN (Scratched Runners)     |      |
| PT (Pool Totals)     |      |
| SP (WPS Probables)     |      |
| WO (Win Odds)     |      |
| WR (WPS Totals)     |      |
| Optional Message Types | Typically empty or not sent |
| ------------- | ----------- |
| WP (WillPay)     | Willpays     |
| Unhandled Message Types | Typically empty or not sent |
| ------------- | ----------- |
| BI (Race Betting Information)     | NOT DECRYPTED     |
| CF (Cashing File)     | NOT MONITORED     |


### Technical Details
Latest version is 0.3.7 (05.31.15)
