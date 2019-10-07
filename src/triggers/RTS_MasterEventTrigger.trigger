trigger RTS_MasterEventTrigger on Event (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                // Call class logic here!
            } 
            if (Trigger.isUpdate) {
                // Call class logic here!
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
              /*  List <Sales_Order__c> relatedSalesOrders = new List<Sales_Order__c>();
                Map<Id, Datetime> soIds = new Map<Id, Datetime>();
                for (Event evt : Trigger.new) {
                    Event oldEvt = Trigger.oldMap.get(evt.Id);
                    Datetime oldStartDate = oldEvt.StartDateTime;
                    Datetime newStartDate = evt.StartDateTime;
                    
                    if (oldStartDate != newStartDate && (evt.Type == 'Installation' || evt.Type == 'Assessment')) {
                        soIds.put(evt.WhatId, newStartDate);
                    }
                }
                relatedSalesOrders = [SELECT Id, InstallationScheduled__c, MeasureScheduled__c, RecordTypeId, Cancellation__c FROM Sales_Order__c WHERE Id IN :soIds.keySet()];
                for (Sales_Order__c order : relatedSalesOrders) {
                    if (order.RecordTypeId == '012220000004ba7AAA' && order.Cancellation__c == null) {
                        order.MeasureScheduled__c = soIds.get(order.Id);
                    } else if (order.RecordTypeId == '012220000004ba2AAA' && order.Cancellation__c == null) {
                        order.InstallationScheduled__c = soIds.get(order.Id);
                    }
                }
                
                update relatedSalesOrders; */
                
            }
            if (Trigger.isDelete) {
                // Call class logic here!
            }
        } 
    }