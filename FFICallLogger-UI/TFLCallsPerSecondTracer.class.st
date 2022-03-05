"
I listen a TFLFunctionCuonter and trace its output regularly, every second.

Example of use:

~~~
t := TFLCallsPerSecondTracer new.

t start.
t stop.
~~~

Now, Transcript should be showing something like:

~~~
| #                 | calls/s |
|-------------------|---------|
| SDL_GetWindowSize |  545.36 |
| SDL_PollEvent     |  261.22 |
| SDL_GetModState   |   56.83 |
| SDL_RenderPresent |    9.97 |
| SDL_RenderCopy    |    9.97 |
| SDL_LockTexture   |    4.99 |
| SDL_UnlockTexture |    4.99 |
| SDL_GetMouseState |    1.99 |
| SDL_FreeCursor    |    1.00 |
| SDL_SetCursor     |    1.00 |
| SDL_CreateCursor  |    1.00 |
~~~

"
Class {
	#name : #TFLCallsPerSecondTracer,
	#superclass : #Object,
	#instVars : [
		'traceLoopProcess'
	],
	#category : #'FFICallLogger-UI'
}

{ #category : #accessing }
TFLCallsPerSecondTracer >> forkTraceLoop [

	traceLoopProcess ifNotNil: [
		self error: 'Already started' ].

	traceLoopProcess := [

		[	| aCounter startMS stopMS |
			aCounter := TFLFunctionCounter new.

			"Count FFI calls during a second, and measure the exact number of
			milliseconds to adjust the output."
			startMS := Time millisecondClockValue.
			aCounter runDuring: [ 1 second wait ].
			stopMS := Time millisecondClockValue.

			"Schedule output after this process yields the Processor, to 
			minimize the number of lost (uncounted) FFI calls."
			[ self trace: aCounter elapsedMS: (stopMS - startMS) ]
				forkNamed: 'Calls Per Second Tracer - Update'
		] repeat.
	
	] forkNamed: 'Calls Per Second Tracer - Loop'

]

{ #category : #accessing }
TFLCallsPerSecondTracer >> start [

	"Ensure installed on the system"
	TFLFunctionCounter install.

	self forkTraceLoop.

]

{ #category : #accessing }
TFLCallsPerSecondTracer >> stop [

	traceLoopProcess ifNil: [ ^self ].
	
	traceLoopProcess terminate.
	traceLoopProcess := nil.

	TFLFunctionCounter uninstall.
]

{ #category : #accessing }
TFLCallsPerSecondTracer >> trace: aTFLFunctionCounter elapsedMS: elapsedMS [

	| functionNamesSeries callsPerSecondSeries aDictionary df |
	self flag: #todo. "Split this UI code, and keep the rest of the class as model."
	
	aDictionary := aTFLFunctionCounter functionNamesAndCounts.

	functionNamesSeries := aDictionary keys asDataSeries.
	callsPerSecondSeries := (aDictionary values
		collect: [ :value | 1000 * value / elapsedMS ]) asDataSeries
			name: 'calls/s';
			yourself.
	
	df := (DataFrame withRowNames: functionNamesSeries)
		addColumn: callsPerSecondSeries;
		sortDescendingBy: callsPerSecondSeries name;
		yourself.

	Transcript clear.
	DataFrameMarkdownPrinter new
		stringBlockClosure: [ :o | o printShowingDecimalPlaces: 2 ];
		stream: Transcript;
		dataFrame: df;
		write.
	Transcript flush.

]