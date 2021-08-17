"
I am a Spec presenter to show signals recorded by a TFLCallLogger.
"
Class {
	#name : #TFLCallsPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'table',
		'refreshDeferrer',
		'logger',
		'toolbar',
		'startButton',
		'stopButton',
		'statusBar'
	],
	#category : #'FFICallLogger-UI-Core'
}

{ #category : #specs }
TFLCallsPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		add: #toolbar expand: false;
		add: #table;
		add: #statusBar expand: false;
		yourself
]

{ #category : #actions }
TFLCallsPresenter >> doExportTable [
			
	| target |
	target := 'recordings.csv' asFileReference nextVersion.
	
	SpTable2CSVExporter new export: table to: target.
	
	self inform: 'Exported filters to ', target fullName.
]

{ #category : #initialization }
TFLCallsPresenter >> initializeColumns [

	table
		addColumn: ((SpStringTableColumn
			title: 'Date'
			evaluated: [ :each | each timestamp asDate ddmmyyyy ])
			width: 65;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Time'
			evaluated: [ :each | each timestamp asTime asString ])
			width: 112;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Process'
			evaluated: [ :each | each processId ])
			width: 95;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Module'
			evaluated: [ :each | each moduleName ])
			width: 70;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Answer'
			evaluated: [ :each | String streamContents: [ :s | each answer printOn: s ] ])
			width: 70;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Function'
			evaluated: [ :each | each functionName ])
			width: 150;
			yourself);
		addColumn: (SpStringTableColumn
			title: 'Arguments'
			evaluated: [ :each | each arguments asCommaString ]).

]

{ #category : #initialization }
TFLCallsPresenter >> initializeContextMenu [

	table contextMenu: [
		| selectedSignal |
		selectedSignal := table selectedItem.
		
		(self instantiate: SpMenuPresenter)
			addItem: [ :item |
				item
					name: 'Inspect signal';
					action: [ selectedSignal inspect ] ];
			addItem: [ :item |
				item
					name: 'Browse sender';
					action: [ selectedSignal sender browse ] ];
			addGroup: [ :aGroup |
				aGroup
					addItem: [ :item |
						item
							name: ('Don''t record calls with same function and arguments');
							action: [ logger addFilterSignalsLike: selectedSignal ] ].


				aGroup
					addItem: [ :item |
						item
							name: ('Don''t record calls to "{1}" function' format: { selectedSignal functionName });
							action: [ logger addFilter: #functionName equals: selectedSignal functionName ] ];
					addItem: [ :item |
						item
							name: ('Don''t record calls to "{1}" module' format: { selectedSignal moduleName });
							action: [ logger addFilter: #moduleName equals: selectedSignal moduleName ] ];
					addItem: [ :item |
						item
							name: ('Don''t record calls from "{1}" process' format: { selectedSignal processId });
							action: [ logger addFilter: #processId equals: selectedSignal processId ] ].
						
				selectedSignal arguments do: [ :each |
					aGroup
						addItem: [ :item |
							item
								name: ('Don''t record calls including "{1}" as argument' format: { each });
								action: [ logger addFilterHasArgumentLike: each ] ]
							]
				
				];
			addGroup: [ :aGroup |
				aGroup
					addItem: [ :item |
						item
							name: ('Only record calls to "{1}" function' format: { selectedSignal functionName });
							action: [ logger addFilter: #functionName equals: selectedSignal functionName ] ];
					addItem: [ :item |
						item
							name: ('Only record calls to "{1}" module' format: { selectedSignal moduleName });
							action: [ logger addFilter: #moduleName equals: selectedSignal moduleName ] ];
					addItem: [ :item |
						item
							name: ('Only record calls from "{1}" process' format: { selectedSignal processId });
							action: [ logger addFilter: #processId equals: selectedSignal processId ] ] ]

			] 
]

{ #category : #initialization }
TFLCallsPresenter >> initializePresenters [ 
	"We assume the logger was set previously."

	toolbar := self newToolbar.
	self initializeToolbar.

	statusBar := self newStatusBar.

	table := self newTable.
	self initializeColumns.
	self initializeContextMenu.
	table whenSelectionChangedDo: [ self refreshStatusBar ].
	
	"Trigger initial refresh"
	refreshDeferrer schedule.

]

{ #category : #initialization }
TFLCallsPresenter >> initializeToolbar [

	toolbar
		addItem: (startButton := SpToolbarButtonPresenter new
			label: 'Start';
			icon: (self iconNamed: #smallOk);
			action: [ logger start ];
			yourself);
		addItem: (stopButton := SpToolbarButtonPresenter new
			label: 'Stop';
			icon: (self iconNamed: #smallCancel);
			action: [ logger stop ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Clear calls';
			icon: (self iconNamed: #refresh);
			action: [ logger reset ];
			yourself);
		addItemRight: (SpToolbarButtonPresenter new
			label: 'Install on TF';
			icon: (self iconNamed: #down);
			action: [ TFLCallLogger install ];
			yourself);
		addItemRight: (SpToolbarButtonPresenter new
			label: 'Export CSV';
			icon: (self iconNamed: #smallSave);
			action: [ self doExportTable ];
			yourself)
]

{ #category : #accessing }
TFLCallsPresenter >> refresh [

	table items: logger recordings reverse.

	startButton enabled: logger isRunning not.
	stopButton enabled: logger isRunning.

	self refreshStatusBar
]

{ #category : #accessing }
TFLCallsPresenter >> refreshStatusBar [

	statusBar pushMessage: self statusBarMessage
]

{ #category : #initialization }
TFLCallsPresenter >> setModelBeforeInitialization: aLogger [

	logger := aLogger.

	"We assume that deferrer won't be scheduled before the table is initialized."
	refreshDeferrer := MinMaxDeferrer
		value: (MessageSend receiver: self selector: #refresh)
		notBefore: 100 milliSeconds
		notAfter:  500 milliSeconds.

	logger announcer weak
		when: Announcement
		send: #schedule
		to: refreshDeferrer

]

{ #category : #accessing }
TFLCallsPresenter >> statusBarMessage [

	^ String streamContents: [ :stream |
		stream
			nextPutAll: '[LOG] Recordings: ';
			print: logger recordings size.
		
		stream
			nextPutAll: '; filtered: ';
			print: logger numberOfFilteredSignals.

		logger recordings ifNotEmpty: [ :rs |
			| duration |
			duration := rs last timestamp - rs first timestamp.
			stream
				nextPutAll: '; interval: ';
				print: duration asSeconds;
				nextPut: $s.

			table selectedItem ifNotNil: [ :signal |
				| count |
				count := rs count: [ :each | each functionName = signal functionName ].
				stream nextPutAll: ((' | [SELECTION] Recordings with same function: {1} ({2}%)') format: {
					count.
					(count / rs size * 100) asInteger
					}).

				count := rs count: [ :each | each moduleName = signal moduleName ].
				stream nextPutAll: (('; same module: {1} ({2}%)') format: {
					count.
					(count / rs size * 100) asInteger
					}).

				count := rs count: [ :each | each processId = signal processId ].
				stream nextPutAll: (('; same process: {1} ({2}%)') format: {
					count.
					(count / rs size * 100) asInteger
					})

				]
			].
		]
]
