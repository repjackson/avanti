if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    
    Router.route '/food', (->
        @layout 'layout'
        @render 'food'
        ), name:'food'
    Template.food.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shop'
        @autorun => Meteor.subscribe 'model_docs', 'menu_item'
   
    Template.food.onRendered ->
    Template.food.helpers
        shops: ->
            Docs.find
                model:'shop'
        menu_items: ->
            Docs.find
                model:'menu_item'
