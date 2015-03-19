/*
 * File: app/store/AssetTypes.js
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

Ext.define('ProposalManager.store.AssetTypes', {
    extend: 'Ext.data.Store',

    requires: [
        'Ext.data.field.Field'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            storeId: 'AssetTypes',
            data: [
                {
                    id: 1,
                    text: 'Proposal'
                },
                {
                    id: 2,
                    text: 'Stock'
                },
                {
                    id: 3,
                    text: 'RFP'
                }
            ],
            fields: [
                {
                    name: 'id'
                },
                {
                    name: 'text'
                }
            ]
        }, cfg)]);
    }
});