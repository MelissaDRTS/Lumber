/*
* Author: Alicia Chafee, RTS Labs.
* Date: 10/2019
* Description: This class is the controller for the RTS_Portal_AllTasks_Cmp
* 				
* 
* 
*/

public class RTS_Portal_AllTasks {
    
    public static Id getUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static List<Task> getAllTasks() {
        Id userId = getUserId();
        List<Task> allTasks = [SELECT Id, Subject FROM Task WHERE OwnerId = :userId AND Status = 'Open'];
        System.debug(allTasks);
        return allTasks;
    }
}