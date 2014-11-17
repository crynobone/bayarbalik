@extends('layouts.default')
@section('content')
    <div id="navbar"></div>
    <div class="text-center" id="output">
        <h1 class="lead">BayarBalik.my</h1>
        <div class="lead-buttons">
            <a href="#iou" class="btn btn-primary btn-lg">
                I Owe Someone
            </a>
            <a href="#uome" class="btn btn-primary btn-lg">
                Someone Owes Me
            </a>
        </div>
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
            <div class="col-sm-4">
                <h3>Weekly</h3>
                <h2><%-numeral(weekly).format('0,0.00')%></h2>
                <h3>Monthly</h3>
                <h2><%-numeral(monthly).format('0,0.00')%></h2>
                <h3>Someday</h3>
                <h2><%-numeral(someday).format('0,0.00')%></h2>
            </div>
            <div class="col-sm-8">
                <h3>Track new debt</h3>
                <form role="form">
                    <div class="form-group">
                        <label class="control-label lead" for="loan_from">I Owe</label>
                        <input class="form-control text-center" name="loan_from" id="loan_from" placeholder="Person" type="text" required>
                    </div>
                    <div class="form-group">
                        <label class="control-label lead" for="loan_amount">The Sum Of</label>
                        <input class="form-control recalculate text-center" name="loan_amount" id="loan_amount" placeholder="Sum Owed" type="number" required value="1000" step="100">
                    </div>
                    <div class="form-group">
                        <label class="control-label lead" for="payment_interval">Which I Plan To Repay</label>
                        <div>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate" name="payment_interval" id="inlineRadio1" value="Week"> Weekly
                            </label>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate" name="payment_interval" id="inlineRadio2" value="Month" checked> Monthly
                            </label>
                            <label class="radio-inline">
                                <input type="radio" class="recalculate" name="payment_interval" id="inlineRadio3" value="Someday"> Someday
                            </label>
                        </div>
                    </div>
                    <div class="form-group not-someday">
                        <label class="control-label lead" for="intervals">Over</label>
                        <input class=" recalculate" id="intervals" name="intervals" min="1" max="120" type="range" value="6" required>
                        <h3><span id="nomonths">6</span> <span class="unit">Month</span>s @<span id="monthly">166.67</span>/<span class="unit">Month</span></h3>
                    </div>
                    <div class="form-group">
                        <label class="control-label lead" for="additional_notes">Additional Notes</label>
                        <input class="form-control text-center" name="additional_notes" id="additional_notes" placeholder="Account Number" type="text">
                    </div>
                    <button type="submit" class="btn btn-default btn-lg btn-primary">Save</button>
                </form>
            </div>
        </div>
    </div>
</script>

<script type="text/template" id="uome-index-template">
</script>


@stop
