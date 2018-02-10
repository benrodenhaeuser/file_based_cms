# Requirements

- When a user views the index page, they should see a link that says "New Document" (below the list of files)
- When a user clicks the "New Document" link, they should be taken to a page with a text input labeled "Add a new document:" and a submit button labeled "Create".
- When a user enters a document name and clicks "Create", they should be redirected to the index page. The name they entered in the form should now appear in the file list. They should see a message that says "$FILENAME has been created.", where $FILENAME is the name of the document just created:
- If a user attempts to create a new document without a name, the form should be redisplayed and a message should say "A name is required."


# Plan

- Add a link with path '/document/new' to the index page. DONE
- Make a get route handler for 'document/new'
  - The get route handler displays the associated view DONE
- Make a view for '/document/new' DONE
  - Shows a form (for the document name) and a submit button DONE
  - The form posts to '/document/new' DONE
- Make a post route handler for '/document/new' DONE
  - The route handler creates a new document DONE
  - The router handler redirects to the index page DONE
