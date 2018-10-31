/*
 * Created by Serhii on 31.10.2018.
 */
public class TerrUserChangeHandler {
    public static void TerrUserAfterUpdate(List<TerrUser__c> newTerrUser, Map<Id, TerrUser__c> oldMapTerrUser) {
        System.debug('newTerrUser = ' + newTerrUser[0]);
        List <Id> terID = new List<Id>();
        for (TerrUser__c t : oldMapTerrUser.values()) {
            terID.add(t.Territory__c);
            System.debug('TerrUser__c.Territory__c = ' + t.Territory__c);
        }
        System.debug('terID = ' + terID[0]);
        List <Reference__c> referenceListOld = [SELECT Name, Account__c, Contact__c
                FROM Reference__c
                WHERE Account__r.Territory__c in : terID];
        List<Account> accountListOld = [SELECT Name, Territory__c
                FROM Account
                WHERE Territory__c in : terID];
        List <Id> contactId = new List<Id>();
        for (Reference__c r : referenceListOld) {
            contactId.add(r.Contact__c);
            System.debug('Reference__c.Contact__c = ' + r.Contact__c);
        }
        List<Contact> contactListOld = [SELECT Name
                FROM Contact
                WHERE id in : contactId];

        //  List <Reference__Share> referenceListNew = new List<Reference__Share>();
        List<AccountShare> accountListNew = new List<AccountShare>();
        List<ContactShare> contactListNew = new List<ContactShare>();
        List<AccountShare> oldAccountShare = [SELECT Id FROM AccountShare
                WHERE AccountId IN :accountListOld AND (RowCause = :Schema.AccountShare.RowCause.Manual)];

        for (TerrUser__c terUser : newTerrUser) {
            //   if (terUser.Territory_User__c != oldMapTerrUser.get(terUser.Id).Territory_User__c) {
            id newUser = terUser.Territory_User__c;
            // Create new sharing object for the custom object Job.
            for (Account acc : accountListOld) {
                AccountShare accShare = new AccountShare();
                // Set the ID of record being shared.
                accShare.AccountId = acc.id;
                // Set the ID of user or group being granted access.
                accShare.UserOrGroupId = newUser;
                // Set the access level.
                accShare.AccountAccessLevel = 'Edit';
                accShare.OpportunityAccessLevel = 'Edit';
                // Set rowCause to 'manual' for manual sharing.
                // This line can be omitted as 'manual' is the default value for sharing objects.
                accShare.RowCause = Schema.AccountShare.RowCause.Manual;
                accountListNew.add(accShare);
            }
            //         }
        }
        delete oldAccountShare;
        List < Database.SaveResult > sres = Database.insert(accountListNew, false);
        validationSave(sres);
    }

    public static void TerrUserAfterInsert
            (List < TerrUser__c > newTerrUser)
        {

        }

    public static void TerrUseronAfterDel
            (List < TerrUser__c > oldTerrUser)
        {

        }

    public static void validationSave(List <Database.SaveResult> sres) {
        for (Database.SaveResult sr : sres) {
            if (!sr.isSuccess()) {
                // Indicates success
                Database.Error err = sr.getErrors()[0];
                // Check if the error is related to trival access level.
                // Access level must be more permissive than the object's default.
                // These sharing records are not required and thus an insert exception is acceptable.
                if (!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&
                        err.getMessage().contains('AccessLevel'))) {
                    // Indicates failure.
                    throw new DmlException ();
                }
            }

        }
    }
}