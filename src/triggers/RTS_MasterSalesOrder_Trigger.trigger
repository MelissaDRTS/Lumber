trigger RTS_MasterSalesOrder_Trigger on Sales_Order__c (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                // Call class logic here!

                Map<String, User> userMapping = new Map<String, User>();
                List<User> userList = [SELECT Id, Vendor_Number__c FROM User WHERE Vendor_Number__c != NULL];
                for (User u : userList){
                    userMapping.put(u.Vendor_Number__c, u);
                }
                System.debug(userMapping);
                System.debug(Trigger.new);
                for (Sales_Order__c so : Trigger.new) {

                    If (so.VNumber__c != null) {
                        so.Assigned__c = userMapping.get(so.VNumber__c).Id;
                    }
                }
            } 
            if (Trigger.isUpdate) {

                // Call class logic here!
                for (Sales_Order__c so : Trigger.new){
                    if(so.Name != so.SalesOrderNumber__c){
                        so.Name = so.SalesOrderNumber__c;
                    }
                }
                Map<String, User> userMap = new Map<String, User>();
                List<User>  userList = [SELECT Id, Vendor_Number__c FROM User WHERE Vendor_Number__c != NULL];
                for (User us : userList){
                    userMap.put(us.Vendor_Number__c, us);
                }
                for (Sales_Order__c so : Trigger.new){
                    if(so.VNumber__c != null){
                        so.Assigned__c = userMap.get(so.VNumber__c).Id;
                    }
                }

            }
            if (Trigger.isDelete) {
                // Call class logic here!
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                // Call class logic here!
            } 
            if (Trigger.isUpdate) {
                List<Service_Request__c> serviceRequests = new List<Service_Request__c>();
                Id installRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Install_Order' LIMIT 1].Id;
                Id measureRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Measure_Order' LIMIT 1].Id;
                
                for (Sales_Order__c so : Trigger.new) {

                    Service_Request__c parentServiceRequest = [SELECT Id, Estimated_Completion__c, Installation_Completed__c, Installation_Scheduled__c, Measure_Scheduled__c FROM Service_Request__c WHERE Id = :so.Service_Request__c];
                    
                    if (so.RecordTypeId == measureRecTypeId && !(so.MeasureScheduled__c == null)) {
                        parentServiceRequest.Measure_Scheduled__c = date.newInstance(so.MeasureScheduled__c.year(), so.MeasureScheduled__c.month(), so.MeasureScheduled__c.day());
                    } else if (so.RecordTypeId == measureRecTypeId && so.MeasureScheduled__c == null) {
                        parentServiceRequest.Measure_Scheduled__c = null;
                    } else if (so.RecordTypeId == installRecTypeId && !(so.InstallationScheduled__c == null)) {
                        parentServiceRequest.Estimated_Completion__c = so.EstimatedCompletion__c;
                    	parentServiceRequest.Installation_Completed__c = so.InstallationCompleted__c;
                    	parentServiceRequest.Installation_Scheduled__c = date.newInstance(so.InstallationScheduled__c.year(), so.InstallationScheduled__c.month(), so.InstallationScheduled__c.day());
                    } else if (so.RecordTypeId == installRecTypeId && so.InstallationScheduled__c == null) {
                        parentServiceRequest.Estimated_Completion__c = so.EstimatedCompletion__c;
                    	parentServiceRequest.Installation_Completed__c = so.InstallationCompleted__c;
                    	parentServiceRequest.Installation_Scheduled__c = null;
                    }
                    
                    
                    serviceRequests.add(parentServiceRequest);
                }
                update serviceRequests;
                
                
                
            }
            if (Trigger.isDelete) {
                // Call class logic here!
            }
        }
    }