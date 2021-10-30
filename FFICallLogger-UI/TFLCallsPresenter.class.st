"
I am a Spec presenter to show signals recorded by a TFLCallLogger.
"
Class {
	#name : #TFLCallsPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'refreshDeferrer',
		'logger',
		'toolbar',
		'statusBar',
		'callsTable',
		'stackList'
	],
	#category : #'FFICallLogger-UI-Core'
}

{ #category : #specs }
TFLCallsPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		  add: #toolbar expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 65 percent;
				   add: #callsTable;
				   add: #stackList;
				   yourself);
		  add: #statusBar expand: false;
		  yourself
]

{ #category : #actions }
TFLCallsPresenter >> doExportTableAsCsv [
			
	| target |
	target := 'recordings.csv' asFileReference nextVersion.
	
	SpTable2CSVExporter new export: callsTable to: target.
	
	self inform: 'Exported to ', target fullName.
]

{ #category : #actions }
TFLCallsPresenter >> doExportTableAsTxt [
			
	| target |
	target := 'recordings.txt' asFileReference nextVersion.
	
	SpTable2TXTExporter new export: callsTable to: target.
	
	self inform: 'Exported to ', target fullName.
]

{ #category : #initialization }
TFLCallsPresenter >> initializeColumns [

	callsTable
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
			title: 'Function'
			evaluated: [ :each | each functionName ])
			width: 150;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Answer'
			evaluated: [ :each | each answer asString ])
			width: 70;
			yourself);
		addColumn: (SpStringTableColumn
			title: 'Arguments'
			evaluated: [ :each | each arguments asCommaString ]).

]

{ #category : #initialization }
TFLCallsPresenter >> initializeContextMenu [

	callsTable contextMenu: [
		| selectedSignal |
		selectedSignal := callsTable selectedItem.
		
		self newMenu
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
							action: [ logger addFilter: #functionName deny: selectedSignal functionName ] ];
					addItem: [ :item |
						item
							name: ('Only record calls to "{1}" module' format: { selectedSignal moduleName });
							action: [ logger addFilter: #moduleName deny: selectedSignal moduleName ] ];
					addItem: [ :item |
						item
							name: ('Only record calls from "{1}" process' format: { selectedSignal processId });
							action: [ logger addFilter: #processId deny: selectedSignal processId ] ] ]

			] 
]

{ #category : #initialization }
TFLCallsPresenter >> initializePresenters [ 
	"We assume the logger was set previously."

	toolbar := self newToolbar.
	self initializeToolbar.

	statusBar := self newLabel.

	stackList := self newList
		whenActivatedDo: [ :selection |
			selection selectedItem method browse ];
		yourself.
	
	callsTable := self newTable.
	self initializeColumns.
	self initializeContextMenu.
	callsTable
		whenSelectionChangedDo: [
			self refreshStackList.
			self refreshStatusBar ];
		whenActivatedDo: [ :selection |
			selection selectedItem inspect ].
	
	"Trigger initial refresh"
	refreshDeferrer schedule.

]

{ #category : #initialization }
TFLCallsPresenter >> initializeToolbar [

	toolbar
		addItem: (SpToolbarButtonPresenter new
			label: 'Clear calls';
			icon: (self iconNamed: #refresh);
			action: [ logger reset ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Go to end';
			icon: (self iconNamed: #down);
			action: [ self scrollToEndOfTable ];
			yourself);

		addItemRight: (SpToolbarButtonPresenter new
			label: 'Export CSV';
			icon: (self iconNamed: #smallSave);
			action: [ self doExportTableAsCsv ];
			yourself);
		addItemRight: (SpToolbarButtonPresenter new
			label: 'Export TXT';
			icon: (self iconNamed: #smallSave);
			action: [ self doExportTableAsTxt ];
			yourself)
]

{ #category : #accessing }
TFLCallsPresenter >> refresh [

	callsTable items: logger recordings.

	self
		refreshStackList;
		refreshStatusBar

]

{ #category : #accessing }
TFLCallsPresenter >> refreshStackList [

	stackList items: (callsTable selectedItem
		ifNil: [ #() ]
		ifNotNil: [ :aSignal | aSignal stack ])

]

{ #category : #accessing }
TFLCallsPresenter >> refreshStatusBar [

	statusBar label: self statusBarMessage
]

{ #category : #actions }
TFLCallsPresenter >> scrollToEndOfTable [

	callsTable verticalAlignment desiredVisibleRow: callsTable items size
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

	| count |
	count := logger recordings size.

	^ String streamContents: [ :stream |
		stream
			nextPutAll: '[LOG] Recordings: ';
			print: count.
		
		stream
			nextPutAll: '; filtered: ';
			print: logger numberOfFilteredSignals.

		logger recordings ifNotEmpty: [ :rs |
			| ms rate |
			ms := (rs last timestamp - rs first timestamp) asMilliSeconds.
			stream
				nextPutAll: '; lapse: ';
				print: ms;
				nextPutAll: 'ms'.

			rate := 1000 * count / ms.
			stream
				nextPutAll: '; per sec: ';
				print: rate asInteger.

			callsTable selectedItem ifNotNil: [ :signal |
				count := rs count: [ :each | each functionName = signal functionName ].
				stream nextPutAll: (('    |    [SELECTION] Recordings with same function: {1} ({2}%)') format: {
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
