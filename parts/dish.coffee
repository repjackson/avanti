if Meteor.isClient

    Router.route '/menu_item/:doc_id/view', (->
        @layout 'layout'
        @render 'menu_item_view'
        ), name:'menu_item_view'
    Template.menu_item_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
   
    Router.route '/menu_item/:doc_id/edit', (->
        @layout 'layout'
        @render 'menu_item_edit'
        ), name:'menu_item_edit'

    Template.menu_item_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.menu_item_edit.onRendered ->


    Template.menu_item_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_menu', @_id, =>
                    Router.go "/menu/#{@_id}/view"
