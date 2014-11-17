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
        @fetch()
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
    initialize: ->
        @render HomeView

HomeView = Backbone.View.extend
    template: _.template $('#output').html()
    render: ->
        @$el.html @template()
        navbar.hide()
    initialize: ->
        @render()
    hash: 'home'

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
    template: _.template $('#iou-index-template').html()
    render: ->
        @$el.html @template @templateData()
        navbar.show()
    initialize: ->
        @render()
        @listenTo @collection, 'add update remove', @render
    hash: 'iou'

UOMEIndexView = Backbone.View.extend
    template: _.template $('#uome-index-template').html()
    render: ->
        @$el.html @template()       
        navbar.show()
    initialize: ->
        @render()
    hash: 'uome'

base = new BaseView
    el: '#output'

# Router
HutangRouter = Backbone.Router.extend
    routes:
        'iou'     : 'iouIndex'
        'iou:id'  : 'iouDetails'
        'uome'    : 'uomeIndex'
        'uome:id' : 'uomeDetails'
        '*path'   : 'defaultRoute'
    iouIndex: ->
        base.render IOUIndexView
    uomeIndex: ->
        base.render UOMEIndexView
    defaultRoute: ->
        base.render HomeView

router = new HutangRouter
Backbone.history.start()