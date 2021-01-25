if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    
    Router.route '/food', (->
        @layout 'layout'
        @render 'food'
        ), name:'food'
    Template.food.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shop'
        @autorun => Meteor.subscribe 'model_docs', 'menu_item'
        @autorun => Meteor.subscribe 'model_docs', 'drink'
   
    Template.food.onRendered ->
    Template.food.helpers
        drinks: ->
            Docs.find
                model:'drink'
        shops: ->
            Docs.find
                model:'shop'
        menu_items: ->
            Docs.find
                model:'menu_item'
