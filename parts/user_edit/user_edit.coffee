if Meteor.isClient
    Router.route '/user/:username/edit/', (->
        @layout 'user_edit_layout'
        @render 'user_edit_account'
        ), name:'user_edit_home'
    Router.route '/user/:username/edit/info', (->
        @layout 'user_edit_layout'
        @render 'user_edit_info'
        ), name:'user_edit_info'
    Router.route '/user/:username/edit/badges', (->
        @layout 'user_edit_layout'
        @render 'user_edit_badges'
        ), name:'user_edit_badges'
    Router.route '/user/:username/edit/payment', (->
        @layout 'user_edit_layout'
        @render 'user_edit_payment'
        ), name:'user_edit_payment'
    Router.route '/user/:username/edit/account', (->
        @layout 'user_edit_layout'
        @render 'user_edit_account'
        ), name:'user_edit_account'
    Router.route '/user/:username/edit/food', (->
        @layout 'user_edit_layout'
        @render 'user_edit_food'
        ), name:'user_edit_food'

    Template.user_edit_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.user_id

    Template.user_edit_layout.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 2000

    Template.registerHelper 'current_user', () -> Meteor.users.findOne username:Router.current().params.username

    # Template.phone_editor.helpers
    #     'newNumber': ->
    #         Phoneformat.formatLocal 'US', Meteor.user().profile.phone

    Template.user_edit_layout.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"

        "change input[name='profile_image']": (e) ->
            files = e.currentTarget.files
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        user = Meteor.users.findOne username:Router.current().params.username
                        Meteor.users.update user._id,
                            $set: "image_id": res.public_id
                    return


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/user/#{new_username}")




    Template.password_edit.events
        'click .change_password': (e, t) ->
            Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
                if err
                    alert err.reason
                else
                    alert 'password changed'
                    # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, ->
                alert "password set to #{new_password}."

        'click .send_password_reset_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_password_reset_email', current_user._id, @address, ->
                alert 'password reset email sent'


        'click .send_enrollment_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'send_enrollment_email', current_user._id, @address, ->
                alert 'enrollment email sent'


    Template.emails_edit.helpers

    Template.emails_edit.events
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            current_user = Meteor.users.findOne username:Router.current().params.username

            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)

            if valid_email
                Meteor.call 'add_email', current_user._id, new_email, (error, result) ->
                    if error
                        alert "error adding email: #{error.reason}"
                    else
                        # alert result
                        $('#new_email').val('')
                    return

        'click .remove_email': ->
            if confirm 'remove email?'
                current_user = Meteor.users.findOne username:Router.current().params.username
                Meteor.call 'remove_email', current_user._id, @address, (error,result)->
                    if error
                        alert "error removing email: #{error.reason}"


        'click .send_verification_email': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'verify_email', current_user._id, @address, ->
                alert 'verification email sent'
