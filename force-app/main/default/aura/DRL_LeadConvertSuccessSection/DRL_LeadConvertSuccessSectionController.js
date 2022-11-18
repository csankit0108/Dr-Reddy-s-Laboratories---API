({
    doInit : function(component, event, helper) {
        const list_columns = [
            {
                label: 'Name',
                fieldName: 'opportunityUrl',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    }
                }
            },
            {
                label: 'Stage',
                fieldName: 'StageName',
                type: 'Text'
            },
            {
                label: 'Owner',
                fieldName: 'Amount',
                type: 'currency'
            }
        ];
        console.log(component.get('v.list_Opportunities'));
        component.set('v.list_opportunityColumns',list_columns);
    }
})