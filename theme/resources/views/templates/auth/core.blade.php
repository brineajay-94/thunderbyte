@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-900']
])

@section('meta')
    @parent
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
@endsection

@section('container')
    <div id="app"></div>
@endsection