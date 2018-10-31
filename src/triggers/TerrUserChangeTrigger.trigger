trigger TerrUserChangeTrigger on TerrUser__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            //            ActivityDataHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
            TerrUserChangeHandler.TerrUserAfterUpdate(Trigger.new,Trigger.oldMap);
        }
        if (Trigger.isInsert) {
            TerrUserChangeHandler.TerrUserAfterInsert(Trigger.new);
        }
        if (Trigger.isDelete) {
            //            ActivityDataHandler.onAfterDelete(Trigger.old);
            TerrUserChangeHandler.TerrUseronAfterDel(Trigger.old);
        }
    }
}