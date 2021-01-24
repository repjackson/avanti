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

    Template.food.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shop'
   
   
    Template.food.onRendered ->


    Template.food.helpers
        shops: ->
            Docs.find
                model:'shop'
    Template.food.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_shop', @_id, =>
                    Router.go "/shop/#{@_id}/view"

    Template.shop_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
   
    Template.shop_view.onRendered ->


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