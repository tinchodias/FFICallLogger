"
I listen FFI calls and summarize them on Transcript regularly (every second).

Example of use:

```
t := TFLCallsPerSecondTracer new.

t start.
t stop.
```

Now, `Transcript` should be showing something like:

```
""
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
""
```

"
Class {
	#name : #TFLCallsPerSecondTracer,
	#superclass : #Object,
	#instVars : [
		'functionCounter'
	],
	#category : #'FFICallLogger-UI'
}

{ #category : #initialization }
TFLCallsPerSecondTracer >> initialize [

	super initialize.

	functionCounter := TFLFunctionCyclicCounter newEvery: 1 second
]

{ #category : #tracing }
TFLCallsPerSecondTracer >> start [

	functionCounter announcer
		when: TFLFunctionCyclicCounterAnnouncement
		send: #trace:
		to: self.

	functionCounter start
]

{ #category : #tracing }
TFLCallsPerSecondTracer >> stop [

	functionCounter stop.
	
	functionCounter announcer unsubscribe: self.

]

{ #category : #tracing }
TFLCallsPerSecondTracer >> trace: aTFLFunctionCyclicCounterAnnouncement [

	| rows |
	rows := Array streamContents: [ :stream |
		stream nextPut: #('#' 'calls/s').
		aTFLFunctionCyclicCounterAnnouncement functionNamesAndCountsAdjusted
			do: [ :each |
				stream nextPut: {
					each first.
					each second printShowingDecimalPlaces: 2 } ] ].

	Transcript clear.
	TFLMarkdownTablePrinter new
		stream: Transcript;
		rows: rows;
		isColumnLeftAlignedBlock: [ :columnIndex | columnIndex = 1 ];
		write.
	Transcript flush.

]
