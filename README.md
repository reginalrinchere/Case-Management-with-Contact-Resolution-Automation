Royal Caribbean International, a leading cruise line and vacation company, regularly receives cases from external sources. These cases contain essential information, including Subject, Description, Web Email, Web Name, and Web Phone. To streamline case management, an Apex trigger has to be developed to automate contact resolution. This trigger checks for existing contacts based on email or phone, associates cases with matched contacts, and creates new contacts if none are found. Additionally, it generates a follow-up task for the newly created contacts.

 

Automation Steps:

Case Creation: When a new case is created from an external source for Royal Caribbean International, it includes the following pre-populated fields: Subject, Description, Web Email, Web Name, Web Phone.

Contact Check: The automation checks if a contact with the same email (Web Email) or phone (Web Phone) already exists in your Salesforce Contacts.

Existing Contact: If a matching contact is found, the case is tagged with the existing contact, streamlining case management.

New Contact Creation: If no matching contact is found, a new contact is created with the following details:

Contact Last Name: Web Name
Contact Phone: Web Phone
Contact Email: Web Email
This automation not only facilitates efficient case handling for Royal Caribbean International but also helps enhance the overall customer support experience by promptly resolving cases and maintaining accurate contact records.
