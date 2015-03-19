/*
 * File: app/view/admin/users/UsersViewController.js
 *
 * This file was generated by Sencha Architect version 3.2.0.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 5.1.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 5.1.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('ProposalManager.view.admin.users.UsersViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.adminusersusers',

    onCompanyIdChange: function(field, newValue, oldValue, eOpts) {
        var rec = this.getViewModel().get('selectedRecord');
        rec.set('companyname',field.getRawValue());
    },

    onRoleIdChange: function(field, newValue, oldValue, eOpts) {
        var rec = this.getViewModel().get('selectedRecord');
        rec.set('role',field.getRawValue());
    },

    onRowEditingCancelEdit: function(editor, context, eOpts) {

        var rec = context.record;
        if (rec.phantom) {
            context.grid.getStore().remove(rec);
        }
    },

    onRowEditingEdit: function(editor, context, eOpts) {
        var rec = context.record;
        var me = this;

        rec.save({
            success: function(record, operation) {

                if (operation.action == 'create') {
                    var pk = Ext.decode(operation.getResponse().responseText).id;
                    record.set('id', pk);
                }
                record.set('updatedate', new Date());
                record.set('updateuser', sessionStorage.getItem('userName'));

                record.commit();
                me.lookupReference('statusToolbar').getEl().highlight();
            },
            failure: function(record, operation) {
                Ext.Msg.alert('Operation failed', "Please try again later.");

            }
        });
    },

    onSendPasswordReminder: function(view, rowIndex, colIndex, item, e, record, row) {
        Ext.Ajax.request({
            url: 'webservices/User.cfc?method=maillogin',
            jsonData: {
                id: record.get('id')
            },
            success: function() {
                Ext.toast("Email Sent!");
            },
            failure: function() {
                Ext.Msg.alert("Failure","Failed to send notification email");
            }
        });
    },

    onAddRecord: function(owner, tool, event) {
        var grid = this.lookupReference('grid');
        var gridStore = grid.getStore();
        var rec = Ext.create(gridStore.model, {});
        var rowEditor = grid.editingPlugin;
        rowEditor.cancelEdit();
        gridStore.insert(0, rec);
        rowEditor.startEdit(rec, 0);
    },

    onDeleteRecord: function(tool, e, owner, eOpts) {
        var grid = this.lookupReference('grid');
        var gridStore = grid.getStore();
        var rowEditor = grid.editingPlugin;
        var sm = grid.getSelectionModel();
        var selections = grid.getSelectionModel().getSelection();

        var labels = Ext.Array.pluck(selections, 'data.label');

        Ext.Msg.confirm(
        "Delete " + Ext.util.Format.plural(selections.length, "Allergy Record"),
        "Delete " + Ext.util.Format.plural(selections.length, " record?", " records?"),
        function(b) {

            grid.setLoading(true);
            rowEditor.cancelEdit();

            for (var i = 0; i < selections.length; i++) {
                rec = selections[i];
                rec.erase({
                    scope: this,
                    success: function(record, operation) {
                        grid.setLoading(false);
                    },
                    failure: function(record, operation) {
                        grid.setLoading(false);
                        Ext.Msg.alert("Operation Failed", "Please try again later or contact your system administrator");
                    }
                });
            }

        }
        );
    },

    onRefresh: function(tool, e, owner, eOpts) {
        var grid = this.lookupReference('grid');
        var gridStore = grid.getStore();
        var rowEditor = grid.editingPlugin;
        rowEditor.cancelEdit();
        gridStore.load();
    },

    onWindowBeforeRender: function(component, eOpts) {
        Ext.getStore('Companies').load();
    },

    onWindowClose: function(panel, eOpts) {
        this.redirectTo('main');
    }

});
