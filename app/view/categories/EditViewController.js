/*
 * File: app/view/categories/EditViewController.js
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

Ext.define('ProposalManager.view.categories.EditViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.categoriesedit',

    onAddNode: function(owner, tool, event) {
        var selectedNode = this.getViewModel().get('selectedNode');
        var treePanel = this.getView().down('treepanel');

        var n = Ext.create('ProposalManager.model.TaxonomyTerm', {
            text: 'New Term'
        });
        selectedNode.insertChild(0, n);
        selectedNode.expand();
        var cellEditor = treePanel.editingPlugin;
        cellEditor.cancelEdit();
        cellEditor.startEdit(n,0);
    },

    onDeleteNode: function(owner, tool, event) {
        Ext.Msg.confirm(
        "Delete Tree Node",
        "Are you sure that you want to delete this node and all of its children?",
        function(b) {
            if (b == 'yes') {
                var selectedNode = this.getViewModel().get('selectedNode');
                selectedNode.erase();
            }
        },
        this
        );

    },

    onSaveTaxonomy: function(owner, tool, event) {

        owner.setLoading(true);
        var rootNode = this.getView().down('treepanel').getRootNode();
        var nodeIds = [];

        // aggregate valid ids
        rootNode.cascadeBy(function(node) {
            if (Ext.isNumeric(node.id)) {
                nodeIds.push(node.id);
            }
        });


        Ext.Ajax.request({
            url: '/rest/ProposalManager/Taxonomy.json',
            jsonData: {
                nodes: rootNode.serialize(),
                nodeIds: nodeIds.join(',')
            },
            withCredentials: true,
            success: function() {
                // refresh tree
                owner.setLoading(false);
                owner.down('treepanel').getStore().load();

            },
            failure: function() {
                owner.setLoading(false);
                Ext.Msg.alert("Error", "An error occurred. RUN FOR YOUR LIVES!!!!");
            }
        });

    },

    onRefresh: function(owner, tool, event) {
        Ext.Msg.confirm(
        "Reload Data?",
        "Are you sure that you want to refresh the dataset? Any changes that you made will be lost.",
        function(b) {
            if (b == 'yes') {
                owner.down('treepanel').getStore().load();
            }
        }
        );

    },

    onNodeEdit: function(editor, context, eOpts) {
        var rec = context.record;

        rec.parentNode.sort(function(n1, n2) {
            n1 = n1.get('text');
            n2 = n2.get('text');
            if (n1 < n2) {
                return -1;
            } else if (n1 === n2) {
                return 0;
            }
            return 1;
        });
    },

    onWindowClose: function(panel, eOpts) {
        this.redirectTo('main');
    }

});
