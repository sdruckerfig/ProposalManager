/*
 * File: app/view/asset/BrowserViewController.js
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

Ext.define('ProposalManager.view.asset.BrowserViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.assetbrowser',

    reconfigureGrid: function(type) {
        var view = this.getView();
        var grid = view.down('grid');
        var columns = [];

        if (type == 1 || type == 2) {

            columns = [
                {
                     xtype: 'datecolumn',
                     dataIndex: 'updatedate',
                     text: 'Updated'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'title',
                    text: 'Title',
                    flex: 1
                },
                {
                    xtype: 'gridcolumn',
                    width: 90,
                    dataIndex: 'assettype',
                    text: 'Type'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'updateuser',
                    text: 'Updated By'
                }

            ];

        } else {

            columns = [
                {
                     xtype: 'datecolumn',
                     dataIndex: 'updatedate',
                     text: 'Updated'
                },
                {
                    xtype: 'datecolumn',
                    dataIndex: 'datedue',
                    text: 'Date Due'
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'title',
                    text: 'Title',
                    flex: 1
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'clientname',
                    text: 'Prospect / Client',
                    flex: 1
                },
                {
                    xtype: 'gridcolumn',
                    dataIndex: 'updateuser',
                    text: 'Updated By'
                }
            ];


        }

        columns.push(
        {
            xtype: 'actioncolumn',
            width: 60,
            menuDisabled: true,
            items: [
                {
                    handler: 'onViewAsset',
                    icon: 'resources/images/view.png',
                    tooltip: 'View'
                },
                {
                    handler: 'onEditAsset',
                    icon: 'resources/images/document_edit.png',
                    tooltip: 'Edit'
                },
                {
                    handler: 'onDownloadAsset',
                    icon: 'http://webapps.figleaf.com/PatientChart/resources/images/download.png',
                    tooltip: 'Download'
                }
            ]
        }

        );



        grid.reconfigure(grid.getStore(),columns);
    },

    onViewAsset: function(view, rowIndex, colIndex, item, e, record, row) {
        this.redirectTo('viewasset/' + record.get('id'));
    },

    onEditAsset: function(view, rowIndex, colIndex, item, e, record, row) {
        this.redirectTo('editasset/' + record.get('id'));
    },

    onDownloadAsset: function(view, rowIndex, colIndex, item, e, record, row) {

        Ext.Msg.alert("Not Available","Feature to be added later");
        this.redirectTo('downloadasset/' + record.get('id'));
    },

    onNewAsset: function(tool, e, owner, eOpts) {
        this.redirectTo('editasset/0');
    },

    onDeleteClick: function(tool, e, owner, eOpts) {
        var me = this;
        var rec = me.getViewModel().get('selectedRecord');
        var grid = tool.up('grid');
        Ext.Msg.confirm(
        "Delete Asset",
        "Are you sure that you want to delete " + rec.get('title'),
        function(b) {
            rec.erase({
                success: function() {
                    grid.getStore().load();
                },
                failure: function() {

                }
            });
        }
        );
    },

    onRefresh: function(tool, e, owner, eOpts) {
        tool.up('grid').getStore().load();
    },

    onGridpanelItemDblClick: function(dataview, record, item, index, e, eOpts) {
        this.redirectTo('viewasset/' + record.get('id'));
    }

});
