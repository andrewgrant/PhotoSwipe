# PhotoSwipe

A SwiftUI-based iOS photo browsing application that allows users to browse their photo library with fullscreen viewing and batch photo management capabilities.

## Features

- Browse all photos in your photo library
- Fullscreen photo viewing with swipe navigation
- Batch photo management (favorite, keep, delete)
- Confirmation dialog for changes
- Responsive toolbar with SF Symbols icons
- Date filtering (All Photos, Last 30 Days, Custom Date Range)
- Always-visible filter button

## Prompts

This app was built using the following prompts:

1. "add a button underneath the 'Hello World' string that changes the text to 'Goodbye!'"
2. "make the button toggle between the two text strings"
3. "replace this view with one that allows me to scroll through my photos"
4. "not a grid layout. Photos should be fullscreen like a carousel where I can swipe through them"
5. "convert spaces to tabs in this project"
6. "I want to be able to scroll through all the photos in my library without first selecting them"
7. "I want a toolbar at the bottom that has three buttons. Favorite, Keep, Trash. Use icons from SFSymbols for the button images."
8. "The buttons should not favorite or delete them immediately, but kept in a list that contains the image and the action to apply. The button image should be filled if the image is in the relevant list or unfilled if not. Add a new button on the right called 'Apply' that will go through the lists and favorite or delete the images"
9. "on the keep button show the number of photos in all lists in parentheses. E.g. (3) when there are 3 images in all lists"
10. "i made a mistake. show the total count next to the apply button, not the keep button"
11. "show the count to the right of the image, not under it"
12. "When the apply button is clicked it should show a confirmation dialog. The confirmation dialog should ask the user to confirm they want to make changes to their photo library and list the number of favorites and deletions that will be made"
13. "update the git ignore to exclude .DS_Store files"
14. "add a section to README.md called 'Prompts', and list all prompts I've used so far for this app"
15. "At the top left add a filter button. This button should bring up a filter that allows the user to select a date range that will be used to filter the photos shown in the main view"
16. "the filter button should be there at all times, not just when images are loaded. By default the filter should show all images. It should have a predefined option for the last 30 days."
17. "nothing happens when I tap on the filter button"
18. "add a reset function that clears all pending actions. It should reload images based on the current filter. Call this reset function whenever the filter options have changed"
19. "the photos aren't being filtered"
20. "maybe I made a mistake. Filtering seems to be working now"
21. "update the readme with prompts I've used"

## Requirements

- iOS 18.5+
- Xcode 16.4+
- Swift 5.0+

## Permissions

The app requires photo library access to display and manage your photos. Permission is requested automatically on first launch.
