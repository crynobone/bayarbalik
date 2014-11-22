# Models
BaseModel = Backbone.Model.extend
    defaults:
        created_at: Date.now()
        updated_at: Date.now()
    initialize: ->
        return @

# Collections
PaymentsCollection = Backbone.Collection.extend
    model: BaseModel
    lawnchair: new Lawnchair({name: "Payments"}, new Function())
    initialize: ->
        @fetch
            success: ->
                $(document).trigger 'dataready'
        return @

PaymentSchedulesCollection = Backbone.Collection.extend
    model: BaseModel
    lawnchair: new Lawnchair({name: "PaymentSchedules"}, new Function())
    initialize: ->
        @fetch
            success: ->
                $(document).trigger 'dataready'
        return @

LendersCollection = Backbone.Collection.extend
    model: BaseModel
    lawnchair: new Lawnchair({name: "Lenders"}, new Function())
    initialize: ->
        @fetch
            success: ->
                $(document).trigger 'dataready'
        return @

payments = window.payments = new PaymentsCollection
lenders = window.lenders = new LendersCollection
schedules = window.schedules = new PaymentSchedulesCollection

# Views

LendersView = Backbone.View.extend
    collection: lenders
    render: ->
        options = @collection
            .pluck 'name'
            .sort (a, b) ->
                a > b ? 1 : -1
            .map (name) ->
                '<option value="' + name + '">'
            .join ''
        @$el.html(options)
    initialize: ->
        @render()
        @listenTo @collection, 'all', @render

lendersView = new LendersView
    el: '#lenders'

NavbarView = Backbone.View.extend
    template: _.template $('#navbar-template').html()
    setActive: (id) ->
        $('[href=#' + id + ']').parent().addClass 'active'
    hide: ->
        if !@$el.is ':hidden'
            @$el.hide()
    show: ->
        if @$el.is ':hidden'
            @$el.show()
    render: ->
        @$el.html @template()
    initialize: ->
        @render()

navbar = new NavbarView
    el: '#navbar'

BaseView = Backbone.View.extend
    render: (childView) ->
        if @child
            if @child.name == childView.prototype.name
                return @child.trigger 'resetstate'
            @child.undelegateEvents()
            @child.remove()
        div = $ '<div/>'
        child = @child = new childView
            el: div
        @$el.html div
        if child.hash
            $('.navbar-nav li').removeClass 'active'
            navbar.setActive child.hash
        child.trigger 'rendered'
        child
    initialize: ->
        @on 'subroute', (args) ->
            if(!@child || @child.name != args[1].prototype.name)
                @render args[1]
                    .trigger 'subroute', args[0]
            else if @child
                @child.trigger 'subroute', args[0]
        @render HomeView

HomeView = Backbone.View.extend
    template: _.template $('#output').html()
    render: ->
        @$el.html @template()
        navbar.hide()
    initialize: ->
        @render()
    hash: 'home'
    name: 'HomeView'

IOUIndexView = Backbone.View.extend
    collection: payments
    events:
        'change .recalculate': 'recalculate',
        'mousemove .recalculate': 'recalculate'
        'submit': (e) ->
            e.preventDefault()
            data = @recalculate()

            # Get Lender uuid or create if does not exist
            lender = lenders.findWhere
                name: data.lender
            if(!lender)
                lender = lenders.create
                    id   : lil.uuid()
                    name : data.lender
            data.lender_id = lender.id
            delete data.lender

            #create payment schedules
            due_amount = numeral().unformat data.due_amount
            delete data.due_amount
            switch data.recurrence
                when 'weekly'
                    due_date = moment().startOf 'week'
                when 'next_week'
                    due_date = moment().endOf('week').add 1, 'second'
                when 'monthly'
                    due_date = moment().startOf 'month'
                when 'next_month'
                    due_date = moment().endOf('month').add 1, 'second'
                when 'someday'
                    due_date = moment()
            for i in [1 .. data.recurrence_number]
                schedules.create
                    payment_id  : data.id
                    due_amount  : due_amount
                    due_date    : due_date.format "YYYY-MM-DD HH:mm:ss"
                    paid_date   : null
                    payment_ref : null
                switch data.recurrence
                    when 'weekly'
                        due_date = due_date.add 1, 'week'
                    when 'monthly'
                        due_date = due_date.add 1, 'month'

            # create debt
            $.notify 'New debt created', 'success'
            data.active = true
            this.collection.create data
            false
    recalculate: (e) ->
            
        # Get Input Vals            
        type                = 'debt'
        lender              = $('[name=lender]', @$el).val().trim()
        amount              = parseInt $('[name=amount]', @$el).val(), 10
        recurrence          = $('[name=recurrence]:checked', @$el).val()
        recurrence_number   = parseInt $('[name=recurrence_number]', @$el).val(), 10
        interest_percentage = parseFloat $('[name=interest_percentage]', @$el).val()
        interest_recurrance = $('[name=interest_recurrance]:checked', @$el).val()
        notes               = $('[name=notes]', @$el).val().trim()

        total_owed = amount
        total_interest_percentage = 0
        if ((['next_week', 'next_month', 'someday'].indexOf recurrence) > -1)
            $('.not-someday').hide()
            recurrence_number = 1
            interest_percentage = 0
        else 
            $('.not-someday').show()
            if interest_percentage > 0
                switch interest_recurrance
                    when 'weekly'
                        if recurrence == 'weekly'
                            total_interest_percentage = recurrence_number * interest_percentage
                        else
                            total_interest_percentage = recurrence_number * 4 * interest_percentage
                    when 'monthly'
                        if recurrence == 'weekly'
                            total_interest_percentage = recurrence_number / 4 * interest_percentage
                        else
                            total_interest_percentage = recurrence_number * interest_percentage
                    when 'annually'
                        if recurrence == 'weekly'
                            total_interest_percentage = recurrence_number / 52 * interest_percentage
                        else
                            total_interest_percentage = recurrence_number / 12 * interest_percentage

        # Calculate Loan
        total_owed = total_owed + (total_interest_percentage / 100 * total_owed);
        due_amount = total_owed / recurrence_number

        # Update Output
        $('#recurring_payment').text numeral(due_amount).format '0,0.00'
        $('#chosen_interest_percentage').text numeral(interest_percentage).format '0.00'
        $('#chosen_recurrence_number').text recurrence_number
        if recurrence == 'weekly'
            $('.chosen_recurrence').text 'Week'
        else 
            $('.chosen_recurrence').text 'Month'
        id                  : lil.uuid()
        type                : type
        lender              : lender
        amount              : amount
        recurrence          : recurrence
        recurrence_number   : recurrence_number
        interest_percentage : interest_percentage
        interest_recurrance : interest_recurrance
        notes               : notes
        due_amount          : Math.round(due_amount * 100) / 100
    templateData: ->
        weekly = @collection
            .where({active: true, type: 'debt'})
            .filter (model) ->
                return (model.get 'active') && ['weekly', 'next_week'].indexOf(model.get 'recurrence') > -1
            .reduce (prev, current) ->
                    prev + schedules.where({payment_id: current.id})
                        .filter (schedule) ->
                            (moment().isAfter moment schedule.get 'due_date') && !schedule.get 'paid_date'
                        .reduce (prev, current) ->
                                prev + current.get 'due_amount'
                            , 0
                , 0
        monthly = @collection
            .where({active: true, type: 'debt'})
            .filter (model) ->
                return (model.get 'active') && ['monthly', 'next_month'].indexOf(model.get 'recurrence') > -1
            .reduce (prev, current) ->
                    prev + schedules.where({payment_id: current.id})
                        .filter (schedule) ->
                            (moment().isAfter moment schedule.get 'due_date') && !schedule.get 'paid_date'
                        .reduce (prev, current) ->
                                prev + current.get 'due_amount'
                            , 0
                , 0
        someday = @collection
            .where({active: true, type: 'debt', recurrence: 'someday'})
            .reduce (prev, current) ->
                    prev + schedules.where({payment_id: current.id})
                        .filter (schedule) ->
                            (moment().isAfter moment schedule.get 'due_date') && !schedule.get 'paid_date'
                        .reduce (prev, current) ->
                                prev + current.get 'due_amount'
                            , 0
                , 0
        weekly  : weekly
        monthly : monthly
        someday : someday
    detailsTemplateData: ->
        {}
    template: _.template $('#iou-index-template').html()
    render: ->
        @$el.html @template @templateData()
        navbar.show()
    renderDetails: (type) ->
        @removeChild
        div = $('<div/>')
        @child = new IOUDetailView
            el: div
            type: type
        @showDetails()
        $('#iou-details').html div
    showDetails: ->
        $('#new-iou')
            .removeClass 'animated bounceInRight'
        $('#iou-details')
            .addClass 'animated bounceInRight'
    showForm: ->
        $('#new-iou')
            .addClass 'animated bounceInRight'
        $('#iou-details')
            .removeClass 'animated bounceInRight'
    remove: ->
        @removeChild
        Backbone.View.prototype.remove.apply(this, arguments);
    removeChild: ->
        if @child
            @child.undelegateEvents()
            @child.remove()
    initialize: ->
        @render()
        @listenTo @collection, 'add change update delete remove insert', @render
        @on 'subroute', (type) ->
            @renderDetails type
        @on 'resetstate', () ->
            @showForm()
    hash: 'iou'
    name: 'IOUIndexView'

PaymentModalView = Backbone.View.extend
    template: _.template $('#payment-modal-template').html()
    render: ->
        $('.bootbox-form').prepend @template @data
    initialize: (options) ->
        data = schedules.get(options.id).toJSON()
        data.payment = payments.get(data.payment_id).toJSON()
        data.lender = lenders.get(data.payment.lender_id).toJSON()
        @data = data
        @render()

IOUDetailView = Backbone.View.extend
    collection: payments
    include_paid: false
    events: 
        'click #make-payment': (e) ->
            model = schedules.get $(e.currentTarget).data 'id'
            el = bootbox.prompt 'Make Debt Payment', (res) ->
                if res && res.trim()
                    res = res.trim()
                    model.set
                            paid_date: moment().format 'YYYY-MM-DD HH:mm:ss'
                            payment_ref: res
                        .save()
                    payments.trigger 'change'

                else if typeof res == 'string'
                    $.notify 'Payment reference cannot be blank', 'error'
            new PaymentModalView
                el: el
                id: model.id
        'click #view-payment': (e) ->
            model = schedules.get $(e.currentTarget).data 'id'
            el = bootbox.prompt 'View Debt Payment', new Function()
            $('.bootbox-input-text').hide();
            new PaymentModalView
                el: el
                id: model.id
        'click #toggle-include-paid': ->
            @include_paid = !@include_paid
            @render()
    templateData: ->
        switch @type
            when 'weekly'
                title = 'Debts Due This Week'
                types = ['weekly', 'next_week']
            when 'monthly'
                title = 'Debts Due This Month'
                types = ['monthly', 'next_month']
            when 'someday'
                title = 'Debts To Be Paid Someday'
                types = ['someday']
        include_paid = @include_paid
        due_payments = @collection
            .where({active: true, type: 'debt'})
            .filter (model) ->
                return (model.get 'active') && types.indexOf(model.get 'recurrence') > -1
            .reduce (prev, current) ->
                    dues = schedules.where({payment_id: current.id})
                        .filter (schedule) ->
                            if !include_paid
                                return (moment().isAfter moment schedule.get 'due_date') && !schedule.get('paid_date')
                            return moment().isAfter moment schedule.get 'due_date'
                    if dues
                        dues.forEach (due) ->
                            data = due.toJSON()
                            data.payment = current.toJSON()
                            data.lender = lenders.get(data.payment.lender_id).toJSON()
                            prev.push data
                    prev
                , []
        title: title
        payments: due_payments
        include_paid: include_paid
    template: _.template $('#iou-details-template').html()
    render: ->
        @$el.html @template @templateData()
        navbar.show()
    initialize: (options) ->
        @type = options.type
        @render()

UOMEIndexView = Backbone.View.extend
    template: _.template $('#uome-index-template').html()
    render: ->
        @$el.html @template()    
        navbar.show()   
    initialize: ->
        @render()
    hash: 'uome'
    name: 'UOMEIndexView'

base = new BaseView
    el: '#output'

# Router
AppRouter = Backbone.Router.extend
    routes:
        'iou'     : 'iouIndex'
        'iou/:type'  : 'iouDetails'
        'uome'    : 'uomeIndex'
        'uome/:type' : 'uomeDetails'
        '*path'   : 'defaultRoute'
    iouIndex: ->
        base.render IOUIndexView
    iouDetails: (type) ->
        base.trigger 'subroute', [type, IOUIndexView]
    uomeIndex: ->
        base.render UOMEIndexView
    defaultRoute: ->
        base.render HomeView

dataready = 0
$(document).on 'dataready', ->
    dataready++
    if dataready == 3
        router = new AppRouter
        Backbone.history.start()