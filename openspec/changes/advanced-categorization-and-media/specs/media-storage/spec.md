# Media Storage and Categorization Specs

## MODIFIED Requirements

### Requirement: Notification Processing
The native listener SHALL extract images and sender details.
   
#### Scenario: Capturing a notification with an image
Given the NotificationListener receives a notification with an `EXTRA_PICTURE` Bitmap
When processing the notification in Kotlin
Then the Bitmap is compressed and saved to `filesDir/media/`
And the resulting relative path is saved to `NotificationRevision.mediaPath`.

#### Scenario: Extracting sender name
Given the NotificationListener receives a MessagingStyle notification
When extracting the extras
Then the latest sender's name is saved to `NotificationRecord.senderName`.

## ADDED Requirements

### Requirement: Filtering by Category
Users SHALL be able to filter history by App or Sender.
   
#### Scenario: Filtering by sender
Given the user is on the History screen
When the user selects the "People" tab
Then the UI displays a grouped list of notifications categorized by `senderName`.