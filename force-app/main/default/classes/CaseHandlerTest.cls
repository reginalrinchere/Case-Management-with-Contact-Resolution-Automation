public class CaseHandler {
    
    // Main handler method for before insert operation
    public static void handleBeforeInsert(List<Case> newCases) {
        Set<String> phoneSet = extractPhoneNumbers(newCases);
        Set<String> emailSet = extractEmails(newCases);

        // Query for existing contacts based on email and phone
        Map<String, Contact> emailContactMap = getEmailContactMap(emailSet);
        Map<String, Contact> phoneContactMap = getPhoneContactMap(phoneSet);

        // Process and associate contacts or create new ones
        List<Contact> newContacts = new List<Contact>();
        processCases(newCases, emailContactMap, phoneContactMap, newContacts);

        // Insert new contacts if necessary
        if (!newContacts.isEmpty()) {
            insert newContacts;
            updateCasesWithNewContactIds(newCases, newContacts);
        }
    }

    // Extract phone numbers from cases
    private static Set<String> extractPhoneNumbers(List<Case> newCases) {
        Set<String> phoneSet = new Set<String>();
        for (Case newCase : newCases) {
            if (newCase.SuppliedPhone != null) {
                phoneSet.add(newCase.SuppliedPhone);
            }
        }
        return phoneSet;
    }

    // Extract emails from cases
    private static Set<String> extractEmails(List<Case> newCases) {
        Set<String> emailSet = new Set<String>();
        for (Case newCase : newCases) {
            if (newCase.SuppliedEmail != null) {
                emailSet.add(newCase.SuppliedEmail.toLowerCase());
            }
        }
        return emailSet;
    }

    // Query existing contacts by email
    private static Map<String, Contact> getEmailContactMap(Set<String> emailSet) {
        Map<String, Contact> emailContactMap = new Map<String, Contact>();
        for (Contact contact : [SELECT Id, Email FROM Contact WHERE Email IN :emailSet]) {
            if (contact.Email != null) {
                emailContactMap.put(contact.Email.toLowerCase(), contact);
            }
        }
        return emailContactMap;
    }

    // Query existing contacts by phone
    private static Map<String, Contact> getPhoneContactMap(Set<String> phoneSet) {
        Map<String, Contact> phoneContactMap = new Map<String, Contact>();
        for (Contact contact : [SELECT Id, Phone FROM Contact WHERE Phone IN :phoneSet]) {
            if (contact.Phone != null) {
                phoneContactMap.put(contact.Phone, contact);
            }
        }
        return phoneContactMap;
    }

    // Process each case and associate or create new contacts
    private static void processCases(List<Case> newCases, 
                                     Map<String, Contact> emailContactMap, 
                                     Map<String, Contact> phoneContactMap, 
                                     List<Contact> newContacts) {
        for (Case newCase : newCases) {
            Contact existingContact = findExistingContact(newCase, emailContactMap, phoneContactMap);
            
            if (existingContact != null) {
                // Associate the case with the existing contact
                newCase.ContactId = existingContact.Id;
            } else {
                // Create a new contact if none found
                createNewContact(newCase, newContacts);
            }
        }
    }

    // Find existing contact based on email or phone
    private static Contact findExistingContact(Case newCase, 
                                               Map<String, Contact> emailContactMap, 
                                               Map<String, Contact> phoneContactMap) {
        String normalizedEmail = newCase.SuppliedEmail != null ? newCase.SuppliedEmail.toLowerCase() : null;

        // Check for contact by email first
        if (normalizedEmail != null && emailContactMap.containsKey(normalizedEmail)) {
            return emailContactMap.get(normalizedEmail);
        }

        // Then check for contact by phone
        if (newCase.SuppliedPhone != null && phoneContactMap.containsKey(newCase.SuppliedPhone)) {
            return phoneContactMap.get(newCase.SuppliedPhone);
        }

        return null;
    }

    // Create a new contact based on the case
    private static void createNewContact(Case newCase, List<Contact> newContacts) {
        if (newCase.SuppliedEmail != null || newCase.SuppliedPhone != null) {
            Contact newContact = new Contact();
            newContact.LastName = newCase.SuppliedName;
            newContact.Phone = newCase.SuppliedPhone;
            newContact.Email = newCase.SuppliedEmail;
            newContacts.add(newContact);

            // Set the contact ID temporarily (will be updated after insert)
            newCase.ContactId = newContact.Id;
        }
    }

    // Update cases with the correct ContactId after contact insert
    private static void updateCasesWithNewContactIds(List<Case> newCases, List<Contact> newContacts) {
        // Create a map of newly inserted contacts by their email
        Map<String, Id> newContactMap = new Map<String, Id>();
        for (Contact newContact : newContacts) {
            newContactMap.put(newContact.Email != null ? newContact.Email.toLowerCase() : null, newContact.Id);
        }

        // Update cases with the new contact IDs
        for (Case newCase : newCases) {
            if (newCase.ContactId == null && newCase.SuppliedEmail != null) {
                newCase.ContactId = newContactMap.get(newCase.SuppliedEmail.toLowerCase());
            }
        }
    }
}
