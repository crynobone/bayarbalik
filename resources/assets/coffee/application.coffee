# Models
DebtModel = Backbone.Model.extend
    defaults:
        created_at: Date.now()
        updated_at: Date.now()
    initialize: ->
        return @

# Collection
DebtsCollection = Backbone.Collection.extend
    model: DebtModel
    lawnchair: new Lawnchair({name: "Hutangs"}, new Function())
    initialize: ->
        @fetch
            success: ->
                $(document).trigger 'dataready'
        return @

debts = window.debts = new DebtsCollection

# Views
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
    collection: debts
    events:
        'change .recalculate': 'recalculate'
        'submit': (e) ->
            e.preventDefault();
            $.notify 'New debt created', 'success'
            this.collection.create @recalculate()
            false
    recalculate: (e) ->
        payment_interval = $('[name=payment_interval]:checked', @el).val()
        if payment_interval == 'Someday'
            $('.not-someday').hide()
        else 
            $('.not-someday').show()
        loan_amount   = parseInt $('[name=loan_amount]', @el).val(), 10
        intervals     = parseInt $('[name=intervals]', @el).val(), 10
        $('#nomonths').text(intervals)
        $('.unit').text(payment_interval)
        $('#monthly').text(numeral(loan_amount / intervals).format '0,0.00')
        id               : lil.uuid()
        loan_amount      : loan_amount
        payment_interval : payment_interval
        intervals        : intervals
        per_interval     : loan_amount / intervals
        loan_from        : $('[name=loan_from]', @el).val()
        additional_notes : $('[name=additional_notes]', @el).val()
    templateData: ->
        monthly: @collection.where({payment_interval: 'Month'}).reduce (prev, current) ->
                prev + current.get('per_interval')
            , 0
        weekly: @collection.where({payment_interval: 'Week'}).reduce (prev, current) ->
                prev + current.get('per_interval')
            , 0
        someday: @collection.where({payment_interval: 'Someday'}).reduce (prev, current) ->
                prev + current.get('loan_amount')
            , 0
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
        @listenTo @collection, 'add update remove', @render
        @on 'subroute', (type) ->
            @renderDetails type
        @on 'resetstate', () ->
            @showForm()
    hash: 'iou'
    name: 'IOUIndexView'

IOUDetailView = Backbone.View.extend
    collection: debts
    templateData: ->
        type: @type
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
    initialize: ->
        @render()
    hash: 'uome'
    name: 'UOMEIndexView'

base = new BaseView
    el: '#output'

# Router
HutangRouter = Backbone.Router.extend
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

$(document).on 'dataready', ->
    router = new HutangRouter
    Backbone.history.start()