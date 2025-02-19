@isTest
public class CaseHandlerTest {
    @isTest
    static void testHandleBeforeInsert_withExistingContact() {
        // Create a contact
        Contact existingContact = new Contact(LastName = 'Doe', Email = 'johndoe@example.com', Phone = '1234567890');
        insert existingContact;

        // Create a case with existing contact's email
        Case newCase = new Case(SuppliedEmail = 'johndoe@example.com', SuppliedName = 'John Doe', SuppliedPhone = '1234567890', Subject = 'Test Case', Description = 'Testing Case Handler');
        
        // Insert case
        insert newCase;

        // Verify the case is associated with the existing contact
        newCase = [SELECT Id, ContactId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(existingContact.Id, newCase.ContactId, 'The case should be linked to the existing contact.');
    }

    @isTest
    static void testHandleBeforeInsert_withNewContact() {
        // Create a case with a new contact's details
        Case newCase = new Case(SuppliedEmail = 'janedoe@example.com', SuppliedName = 'Jane Doe', SuppliedPhone = '0987654321', Subject = 'New Case Test', Description = 'Testing New Contact Creation');

        // Insert case
        insert newCase;

        // Verify that the new contact was created
        Contact newContact = [SELECT Id, LastName, Email, Phone FROM Contact WHERE Email = 'janedoe@example.com' LIMIT 1];
        System.assertNotEquals(null, newContact, 'A new contact should have been created.');

        // Refresh the new case from the database
        newCase = [SELECT Id, ContactId FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(newContact.Id, newCase.ContactId, 'The case should be linked to the newly created contact.');

        // Verify that a follow-up task was created
       // List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId FROM Task WHERE WhatId = :newCase.Id];
        //System.assertEquals(1, tasks.size(), 'There should be one follow-up task created for the new contact.');
        //System.assertEquals('Follow up with new contact', tasks[0].Subject, 'The follow-up task should have the correct subject.');
        //System.assertEquals(newContact.Id, tasks[0].WhoId, 'The follow-up task should be linked to the created contact.');
    }
}