({
    getObjectType : function(component, event, helper) {
        var recId = component.get('v.recordId');
        var help = this;
        //console.log(recId);
        this.sendRequest(component, 'c.isSalesOrder', {'recId' : recId})
        .then($A.getCallback(function(isSalesOrder) {
            //console.log(isSalesOrder);
            if(isSalesOrder) {
                //console.log('is Sales Order');
                component.set('v.isSalesOrder', true);
                help.getRecordType(component, recId);
            } else {
                //console.log('is not Sales Order');
                component.set('v.isSalesOrder', false);
            } 
        }))
        .catch(function(errors) {
            console.error('get object type error: ' + errors);
            component.set('v.isSalesOrder', false);
        });
        
    },
    
    
    getRecordType : function(component, recId) {
        var help = this;
        this.sendRequest(component, 'c.getRecordType', {'recId' : recId})
        .then($A.getCallback(function(recordType) {
            var options = [];
            console.log(recordType);
            if(recordType == 'Install_Order') {
                options = [ {"label" : "All Documents with Change Request", "value" : "All_Doc_WITH_CO"}, {"label" : "All Documents without Change Request", "value" : "All_Doc_WITO_CO"}, {"label" : "Customer Completion Form", "value" : "CustCompletion"}, {"label" : "Installation Change Authorization", "value" : "InstallChangeAuth"}, {"label" : "Installation Change Order", "value" : "ChangeOrder"}, {"label" : "Lien Waiver", "value" : "InstLienWaiver"}, {"label" : "Moisture Reading", "value" : "MoistureReading"}, {"label" : "Work Order", "value" : "InstWorkOrder"}];
            } else if (recordType == 'Measure_Order') {
                options = [{"label" : "Project Assessment Form", "value" : "IPProjectAssess"}];
            }
            component.set('v.fileOptions', options);
            help.getParentServiceRequest(component, recId)
        }))
        .catch(function(errors) {
            console.error('get record type error: ' + errors);
            
        });
    },
    
    getParentServiceRequest : function(component, recId) {
        this.sendRequest(component, 'c.getParentServiceRequest', {'recId' : recId})
        .then($A.getCallback(function(srId) {
            console.log(srId);
            component.set('v.recId', srId);
        }))
        .catch(function(errors) {
            console.error('get service request id error: ' + errors);
            
        });
    },
    
    renameFile : function(component, fileObj) {
        console.log('renaming file');
        var jsonFileData = JSON.stringify(fileObj);
        this.sendRequest(component, 'c.renameFile', {'fileObject' : jsonFileData})
        .then($A.getCallback(function(success) {
            console.log(success);
            
        }))
        .catch(function(errors) {
            console.error('rename file error: ' + errors);
            
        });
    },
    
    updateSalesOrder : function(component, fileType) {
        var recId = component.get('v.recordId');
        this.sendRequest(component, 'c.updateSalesOrderFileCheckboxes', {'fileType' : fileType, "salesOrderId" : recId})
        .then($A.getCallback(function(success) {
            console.log(success);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(errors) {
            console.error('update sales order file checkboxes error: ' + errors);
            
        });
    },
    
    
    sendRequest : function(component, methodName, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get(methodName);
            if (params) {
                action.setParams(params);
            }
            
            action.setCallback(self, function(res) {
                var state = res.getState();
                if(state === 'SUCCESS') {
                    resolve(res.getReturnValue());
                } else if(state === 'ERROR') {
                    console.log(res.getReturnValue());
                    reject(action.getError());
                }
            });
            $A.enqueueAction(action);
        }));
    },
})