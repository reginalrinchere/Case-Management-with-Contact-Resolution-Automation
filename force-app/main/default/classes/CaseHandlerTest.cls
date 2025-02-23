@isTest
public class CaseHandlerTest {
    
    @isTest
    static void testHandleBeforeInsert_withExistingContact() {
        Contact existingContact = createContact('johndoe@example.com', '1234567890');
        Case newCase = createCase('johndoe@example.com', 'John Doe', '1234567890');
        
        insert newCase;
        
        // Verify the case is linked to the existing contact
        newCase = [SELECT Id, ContactId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(existingContact.Id, newCase.ContactId, 'The case should be linked to the existing contact.');
    }

    @isTest
    static void testHandleBeforeInsert_withNewContact() {
        Case newCase = createCase('janedoe@example.com', 'Jane Doe', '0987654321');
        
        insert newCase;
        
        // Verify that a new contact was created and linked to the case
        Contact newContact = [SELECT Id, LastName, Email, Phone FROM Contact WHERE Email = 'janedoe@example.com' LIMIT 1];
        System.assertNotEquals(null, newContact, 'A new contact should have been created.');
        
        newCase = [SELECT Id, ContactId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(newContact.Id, newCase.ContactId, 'The case should be linked to the newly created contact.');
        
        // Verify the follow-up task is created for the new contact
        verifyFollowUpTask(newCase, newContact);
    }

    // Helper methods to reduce duplication and improve maintainability
    private static Contact createContact(String email, String phone) {
        Contact contact = new Contact(LastName = 'Doe', Email = email, Phone = phone);
        insert contact;
        return contact;
    }

    private static Case createCase(String email, String name, String phone) {
        Case newCase = new Case(SuppliedEmail = email, SuppliedName = name, SuppliedPhone = phone, Subject = 'Test Case', Description = 'Testing Case Handler');
        return newCase;
    }

    private static void verifyFollowUpTask(Case newCase, Contact newContact) {
        List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId FROM Task WHERE WhatId = :newCase.Id];
        System.assertEquals(1, tasks.size(), 'There should be one follow-up task created for the new contact.');
        System.assertEquals('Follow up with new contact', tasks[0].Subject, 'The follow-up task should have the correct subject.');
        System.assertEquals(newContact.Id, tasks[0].WhoId, 'The follow-up task should be linked to the created contact.');
    }
}
