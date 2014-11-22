@extends('layouts.default')
@section('content')
    <div id="navbar"></div>
    <div id="output">
        <div class="text-center">
            <h1 class="lead">BayarBalik.com</h1>
            <p class="text-muted">Pay me back ma moneh</p>
            <div class="lead-buttons">
                <a href="#iou" class="btn btn-primary btn-lg">
                    I Owe Someone
                </a>
                <a href="#uome" class="btn btn-primary btn-lg">
                    Someone Owes Me
                </a>
            </div>
        </div>
    </div>
    <datalist id="lenders"></datalist>
    <div class="text-center">
    </div>

<script type="text/template" id="navbar-template">
    <div class="navbar navbar-default navbar-static-top navbar-inverse">
        <div class="container">
            <div class="navbar-header">
                <a type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse"></a>
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <a class="navbar-brand" href="#home">BayarBalik.com</a>
            </div>
            <div class="collapse navbar-collapse navbar-ex1-collapse">
                <ul class="nav navbar-nav navbar-right">
                    <li>
                        <a href="#iou">I Owe Someone</a>
                    </li>
                    <li>
                        <a href="#uome">Someone Owes Me</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</script>

<script type="text/template" id="iou-index-template">
    <div class="container">
        <div class="row">
            <div class="col-sm-4 text-right debts-summary animated bounceInLeft">
                <h3>Due This Week</h3>
                <h2><a href="#iou/weekly"><%-numeral(weekly).format('0,0.00')%></a></h2>
                <h3>Due This Month</h3>
                <h2><a href="#iou/monthly"><%-numeral(monthly).format('0,0.00')%></a></h2>
                <h3>Due Someday</h3>
                <h2><a href="#iou/someday"><%-numeral(someday).format('0,0.00')%></a></h2>
            </div>
            <div id="new-iou" class="col-sm-8 animated bounceInRight">
                <br>
                <form role="form">
                    <div class="form-group">
                        <label class="control-label lead" for="lender">I Owe</label>
                        <input list="lenders" class="form-control" name="lender" id="lender" placeholder="Person" required>
                    </div>
                    <div class="form-group">
                        <label class="control-label lead" for="amount">The Sum Of</label>
                        <input class="form-control recalculate" name="amount" id="amount" placeholder="Sum Owed" type="number" required value="1000">
                    </div>
                    <div class="form-group">
                        <label class="control-label lead" for="recurrence">Which I Plan To Repay</label>
                        <div>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate" name="recurrence" id="inlineRadio1" value="weekly"> Weekly
                            </label>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate" name="recurrence" id="inlineRadio2" value="monthly" checked> Monthly
                            </label>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate oneoff" name="recurrence" id="inlineRadio3" value="next_week"> Next Week
                            </label>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate oneoff" name="recurrence" id="inlineRadio4" value="next_month"> Next Month
                            </label>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate oneoff" name="recurrence" id="inlineRadio5" value="someday"> Someday
                            </label>
                        </div>
                    </div>
                    <div class="form-group not-someday">
                        <label class="control-label lead" for="interest_percentage">With <span id="chosen_interest_percentage">0.00</span>% Interest</label>
                        <input class=" recalculate" id="interest_percentage" name="interest_percentage" min="0" max="100" step="0.05" type="range" value="0" required>
                        <br>
                        <label class="radio-inline">
                            <input type="radio" class="recalculate" name="interest_recurrance" id="inlineRadio1" value="weekly"> Weekly
                        </label>
                        <label class="radio-inline">
                            <input type="radio" class="recalculate" name="interest_recurrance" id="inlineRadio2" value="monthly" checked> Monthly
                        </label>
                        <label class="radio-inline">
                            <input type="radio" class="recalculate" name="interest_recurrance" id="inlineRadio6" value="annually" checked> Annually
                        </label>
                    </div>
                    <div class="form-group not-someday">
                        <label class="control-label lead" for="recurrence_number">Over</label>
                        <input class=" recalculate" id="recurrence_number" name="recurrence_number" min="1" max="240" type="range" value="6" required>
                        <h3><span id="chosen_recurrence_number">6</span> <span class="chosen_recurrence">Month</span>s @<span id="recurring_payment">166.67</span>/<span class="chosen_recurrence">Month</span></h3>
                    </div>
                    <div class="form-group">
                        <label class="control-label lead" for="notes">Additional Notes</label>
                        <input class="form-control" name="notes" id="notes" placeholder="Account Number" type="text">
                    </div>
                    <button type="submit" class="btn btn-default btn-lg btn-primary col-sm-4">Save</button>
                </form>
            </div>
            <div class="col-sm-8" id="iou-details"></div>
        </div>
    </div>
</script>

<script type="text/template" id="iou-details-template">
    <h1><%-title%></h1>
    <a href="#iou">← Back</a>
    <div class="clearfix"></div>
    <br>
    <table class="lead table-striped table-hover table-bordered table">
        <thead>
            <tr>
                <th>-</th>
                <th>Due Date</th>
                <th>Lender</th>
                <th>Amount</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% var sum = 0; var i = 1; payments.forEach(function(payment){ %>
            <tr>
                <td><%-i%></td>
                <td><%-moment(payment.due_date).fromNow()%></td>
                <td><%-payment.lender.name%></td>
                <td>
                    <%-numeral(payment.due_amount).format('0,0.00')%>
                </td>
                <td>
                    <% if(payment.paid_date) { %>
                        <button id="view-payment" class="btn btn-success btn-xs" data-id="<%-payment.id%>">View Payment</button>
                    <% } else { %>
                        <button id="make-payment" class="btn btn-primary btn-xs" data-id="<%-payment.id%>">Pay</button>
                    <% } %>
                    <!-- <button id="" class="btn btn-info btn-xs" data-id="<%-payment.id%>">Info</button> -->
                </td>
            </tr>
            <% sum = sum + payment.due_amount; i++; }) %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="3"></td>
                <td><%-numeral(sum).format('0,0.00')%></td>
                <td></td>
            </tr>
        </tfoot>
    </table>
    <% if (include_paid) { %>
        <button id="toggle-include-paid" class="btn btn-primary active">Hide Paid</button>
    <% } else { %>
        <button id="toggle-include-paid" class="btn btn-primary">Show Paid</button>
    <% } %>
</script>

<script type="text/template" id="uome-index-template">
</script>

<script type="text/template" id="payment-modal-template">
    <table class="table table-striped table-bordered">
        <tr>
            <th>Pay To</th>
            <td><%-lender.name%></td>
        </tr>
        <tr>
            <th>Due On</th>
            <td><%-moment(due_date).format('LLLL')%></td>
        </tr>
        <tr>
            <th>Amount</th>
            <td><%-due_amount%></td>
        </tr>
        <tr>
            <th>Notes</th>
            <td><%-payment.notes%></td>
        </tr>
        <% if(payment_ref) { %>
            <tr>
                <th>Paid On</th>
                <td><%-moment(paid_date).format('LLLL')%></td>
            </tr>
            <tr>
                <th>Payment Reference</th>
                <td><%-payment_ref%></td>
            </tr>
        <% } %>
    </table>
    <% if(!payment_ref) { %>
        Payment reference number (required): <br/><br/>
    <% } %>
</script>


@stop
