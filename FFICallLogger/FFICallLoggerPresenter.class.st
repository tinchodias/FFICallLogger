Class {
	#name : #FFICallLoggerPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'table',
		'refreshDeferrer',
		'logger',
		'toolbar'
	],
	#category : #FFICallLogger
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
			width: 60;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Time'
			evaluated: [ :each | each timestamp asTime asString ])
			width: 90;
			yourself);
		addColumn: ((SpStringTableColumn
			title: 'Function'
			evaluated: [ :each | each target functionName asString ])
			width: 250;
			yourself);
		addColumn: (SpStringTableColumn
			title: 'Address'
			evaluated: [ :each | String streamContents: [ :s | each target address printOn: s ] ]);
		addColumn: (SpStringTableColumn
			title: 'Process'
			evaluated: [ :each | each processId asString ]);
		addColumn: ((SpStringTableColumn
			title: 'Module'
			evaluated: [ :each | each target moduleName asString ])
			width: 70;
			yourself).
		
]

{ #category : #initialization }
FFICallLoggerPresenter >> initializeContextMenu [

	table
		contextMenu: (SpMenuPresenter new 
			addItem: [ :item |
				item
					name: 'Add as ignored process';
					action: [ 
						logger addIgnoredProcessId: table selectedItem processId ] ];
			addItem: [ :item |
				item
					name: 'Add as ignored module';
"					icon: (self iconNamed: #glamorousRemove);"
					action: [ 
						logger addIgnoredModule: table selectedItem target moduleName ] ];
			addItem: [ :item |
				item
					name: 'Add as ignored address';
					action: [ 
						logger addIgnoredAddress: table selectedItem target address] ];
			addItem: [ :item |
				item
					name: 'Add ALL as ignored addresses';
					action: [ table items do: [ :each |
							logger addIgnoredAddress: each target address ] ] ];
			addItem: [ :item |
				item
					name: 'Reset';
					action: [
						logger reset.
						refreshDeferrer schedule ] ];
			yourself).
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
		addItem: (SpToolbarButtonPresenter new
			label: 'Start';
			icon: (self iconNamed: #smallOk);
			action: [ logger start ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Stop';
			icon: (self iconNamed: #smallCancel);
			action: [ logger stop ];
			yourself)
]

{ #category : #initialization }
FFICallLoggerPresenter >> setModelBeforeInitialization: aLogger [

	logger := aLogger.

	"We assume that deferrer won't be scheduled before the table is initialized."
	refreshDeferrer := MinMaxDeferrer
		value: [ table items: logger recordings reverse ]
		notBefore: 50 milliSeconds
		notAfter: 100 milliSeconds.

	logger announcer weak
		when: Announcement
		send: #schedule
		to: refreshDeferrer

]
