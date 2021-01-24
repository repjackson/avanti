if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    
    Router.route '/food', (->
        @layout 'layout'
        @render 'food'
        ), name:'food'
    Router.route '/food/:doc_id/view', (->
        @layout 'layout'
        @render 'shop_view'
        ), name:'shop_view'
    Router.route '/food/:doc_id', (->
        @layout 'layout'
        @render 'shop_view'
        ), name:'shopview'
    Router.route '/menu_item/:doc_id/view', (->
        @layout 'layout'
        @render 'menu_item_view'
        ), name:'menu_item_view'

    Template.food.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shop'
        @autorun => Meteor.subscribe 'model_docs', 'menu_item'
   
   
    Template.food.onRendered ->


    Template.shop_view.helpers
        shops: ->
            Docs.find
                model:'shop'
        menu_items: ->
            Docs.find
                model:'menu_item'
    Template.shop_view.events
        'click .add_item': ->
            new_id = 
                Docs.insert 
                    model:'menu_item'
            Router.go "/menu_item/#{new_id}/edit"        

        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_shop', @_id, =>
                    Router.go "/shop/#{@_id}/view"

    Template.menu_item_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
   
    Template.shop_view.onRendered ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'menu_item'


    Template.shop_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_shop', @_id, =>
                    Router.go "/shop/#{@_id}/view"


    Template.shop_view.helpers
    Template.shop_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_shop: (shop_id)->
        #     shop = Docs.findOne shop_id
        #     target = Meteor.users.findOne shop.recipient_id
        #     gifter = Meteor.users.findOne shop._author_id
        #
        #     console.log 'sending shop', shop
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: shop.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -shop.amount
        #     Docs.update shop_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Router.route '/shop/:doc_id/edit', (->
        @layout 'layout'
        @render 'shop_edit'
        ), name:'shop_edit'

    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shop_edit.onRendered ->


    Template.shop_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_shop', @_id, =>
                    Router.go "/shop/#{@_id}/view"



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


    Template.shop_edit.helpers
    Template.shop_edit.events

if Meteor.isServer
    Meteor.methods
        reward_shop: (shop_id, target_id)->
            shop = Docs.findOne shop_id
            target = Meteor.users.findOne target_id

            console.log 'rewarding shop', shop
            Meteor.users.update target._id,
                $addToSet:
                    rewarded_shop_ids: shop._id