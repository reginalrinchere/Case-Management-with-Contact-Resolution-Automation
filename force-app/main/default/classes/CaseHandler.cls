public class CaseHandler {
    public static void handleBeforeInsert(List<Case> newCases) {
        Set<String> phoneSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
       
        // Collect emails and phone numbers from the incoming cases
        for (Case newCase : newCases) {
            if (newCase.SuppliedEmail != null) {
                emailSet.add(newCase.SuppliedEmail.toLowerCase()); // Normalize to lower case
            }
            if (newCase.SuppliedPhone != null) {
                phoneSet.add(newCase.SuppliedPhone); // Assuming phone does not need normalization
            }
        }

        // Query existing contacts based on email and phone
        Map<String, Contact> emailContactMap = new Map<String, Contact>();
        Map<String, Contact> phoneContactMap = new Map<String, Contact>();

        // Fetching existing contacts
        for (Contact contact : [SELECT Id, Email, Phone, LastName FROM Contact
                                 WHERE Email IN :emailSet OR Phone IN :phoneSet]) {
            if (contact.Email != null) {
                emailContactMap.put(contact.Email.toLowerCase(), contact); // Normalize to lower case
            }
            if (contact.Phone != null) {
                phoneContactMap.put(contact.Phone, contact);
            }
        }

        // Process cases and associate contacts or create new ones
        List<Contact> newContacts = new List<Contact>();

        for (Case newCase : newCases) {
            Contact existingContact = null;

            // Normalize to lower case for email matching
            String normalizedEmail = newCase.SuppliedEmail != null ? newCase.SuppliedEmail.toLowerCase() : null;

            // Check for existing contact by email or phone
            if (normalizedEmail != null && emailContactMap.containsKey(normalizedEmail)) {
                existingContact = emailContactMap.get(normalizedEmail);
            } else if (newCase.SuppliedPhone != null && phoneContactMap.containsKey(newCase.SuppliedPhone)) {
                existingContact = phoneContactMap.get(newCase.SuppliedPhone);
            }

            if (existingContact != null) {
                // Associate the case with the existing contact
                newCase.ContactId = existingContact.Id;
            } else {
                // Create a new contact if none found, use either email or phone
                if (newCase.SuppliedEmail != null || newCase.SuppliedPhone != null) {
                    Contact newContact = new Contact();
                    newContact.LastName = newCase.SuppliedName; // Ensure you're using an appropriate field
                    newContact.Phone = newCase.SuppliedPhone;
                    newContact.Email = newCase.SuppliedEmail;
                    newContacts.add(newContact);

                    // Set the contact ID on the case to the new contact's ID after creation
                    newCase.ContactId = newContact.Id; // Set the contact ID here (will be corrected post-insert)
                }
            }
        }

        // Insert the new contacts
        if (!newContacts.isEmpty()) {
            insert newContacts;

            // Now that we have the new contacts, we can assign their IDs back to the cases
            Map<String, Id> newContactMap = new Map<String, Id>();

            for (Contact newContact : newContacts) {
                newContactMap.put(newContact.Email != null ? newContact.Email.toLowerCase() : null,
                                   newContact.Id);
            }

            // Update cases with the correct ContactId after insertion
            for (Case newCase : newCases) {
                if (newCase.ContactId == null) {
                    // Get the relevant contact from the newContactMap based on email
                    newCase.ContactId = newContactMap.get(newCase.SuppliedEmail != null
                                                            ? newCase.SuppliedEmail.toLowerCase()
                                                            : null);
                }
            }
        }
    }
}

