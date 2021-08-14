"
I am a Spec presenter to show signals recorded by a FFICallLogger.
"
Class {
	#name : #FFICallLoggerPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'table',
		'refreshDeferrer',
		'logger',
		'toolbar',
		'startButton',
		'stopButton'
	],
	#category : #'FFICallLogger-UI'
}

{ #category : #specs }
FFICallLoggerPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		add: #toolbar expand: false;
		add: #table;
		yourself
]

{ #category : #initialization }
FFICallLoggerPresenter >> initializeColumns [

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
		addColumn: ((SpStringTableColumn
			title: 'Arguments'
			evaluated: [ :each |
				String streamContents: [:s |
					each arguments
						do: [:address | address printOn: s ]
						separatedBy: [ s nextPutAll: ', ' ] ] ])
			yourself).
		
]

{ #category : #initialization }
FFICallLoggerPresenter >> initializeContextMenu [

	table contextMenu: [
		| selectedSignal |
		selectedSignal := table selectedItem.
		
		SpMenuPresenter new 
			addItem: [ :item |
				item
					name: 'Inspect signal';
					action: [ selectedSignal inspect ] ];
			addItem: [ :item |
				item
					name: 'Add as ignored function';
					action: [ 
						logger addIgnoreRule: [ :signal | signal functionName = selectedSignal functionName ] ] ];
			addItem: [ :item |
				item
					name: 'Add as ignored module';
					action: [ 
						logger addIgnoreRule: [ :signal | signal moduleName = selectedSignal moduleName ] ] ];
			addItem: [ :item |
				item
					name: 'Add as ignored process';
					action: [ 
						logger addIgnoreRule: [ :signal | signal processId = selectedSignal processId ] ] ];
			yourself

		] 
]

{ #category : #initialization }
FFICallLoggerPresenter >> initializePresenters [ 
	"We assume the logger was set previously."

	toolbar := self newToolbar.
	self initializeToolbar.

	table := self newTable.
	self initializeColumns.
	self initializeContextMenu.
	
	"Trigger initial refresh"
	refreshDeferrer schedule.

]

{ #category : #initialization }
FFICallLoggerPresenter >> initializeToolbar [

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
			label: 'Reset calls';
			icon: (self iconNamed: #refresh);
			action: [ logger reset ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Reset ignored';
			icon: (self iconNamed: #refresh);
			action: [ logger resetIgnored ];
			yourself)
]

{ #category : #accessing }
FFICallLoggerPresenter >> refresh [

	table items: logger recordings reverse.
	startButton enabled: logger isRunning not.
	stopButton enabled: logger isRunning.

]

{ #category : #initialization }
FFICallLoggerPresenter >> setModelBeforeInitialization: aLogger [

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
